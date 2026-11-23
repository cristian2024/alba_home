import 'dart:async';

import 'package:alarm_contract/alarm_contract.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:core_di/core_di.dart';
import 'package:core_events/core_events.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'alarm_dependencies.dart';
import 'domain/use_cases/alarm_use_cases.dart';
import 'domain/use_cases/next_alarm_service.dart';
import 'domain/use_cases/ringing_use_cases.dart';
import 'domain/use_cases/sync_alarm_schedule.dart';
import 'i18n/strings.g.dart' as i18n;
import 'presentation/alarm_routes.dart';
import 'presentation/common/alarm_ambient.dart';
import 'presentation/common/alarm_format.dart';
import 'presentation/edit/alarm_edit_cubit.dart';
import 'presentation/edit/alarm_edit_screen.dart';
import 'presentation/list/alarm_list_cubit.dart';
import 'presentation/list/alarm_list_screen.dart';
import 'presentation/ringing/alarm_ringing_screen.dart';
import 'presentation/ringing/alarm_snoozed_screen.dart';
import 'presentation/ringing/ringing_cubit.dart';

/// Plugin de alarma.
///
/// Toma del `ServiceLocator` de la app:
/// - `AlarmRepository` y `AlarmScheduler` (obligatorios), que registran los
///   adaptadores que elige la app (`AlarmIsar` y `AlarmSchedulerModule`).
/// - `Clock`, `IdGenerator`, `WallClock` y `EventBus` (opcionales: si faltan
///   usa los suyos).
///
/// Registra en su scope `NextAlarmQuery`, que usan el reloj y la batería, y
/// publica `AlarmRang`, `AlarmSnoozed` y `AlarmDismissed`. Para el reloj es
/// además [AmbientStatusSource] (la próxima alarma) y [AmbientAlertSource]
/// (la alarma sonando y el aviso de permiso).
class AlarmPlugin extends HomePlugin implements HomePluginEntryRoute, AmbientStatusSource, AmbientAlertSource {
  AlarmPlugin({
    required ServiceLocator locator,
    LocalizationCoordinator? localization,
    Duration? refreshEvery = const Duration(minutes: 1),
  })  : _locator = locator,
        _localization = localization ?? LocalizationCoordinator.instance,
        _refreshEvery = refreshEvery;

  static const String pluginId = 'alarm';

  final ServiceLocator _locator;
  final LocalizationCoordinator _localization;
  /// Cada cuánto recalcula la próxima alarma y relee el permiso; `null`, nunca
  /// (los tests lo hacen a mano).
  final Duration? _refreshEvery;
  final StreamController<void> _ambientChanges = StreamController<void>.broadcast();
  final List<StreamSubscription<Object?>> _subscriptions = <StreamSubscription<Object?>>[];
  Timer? _refreshTimer;

  NextAlarm? _next;
  bool _canRing = true;
  RingingAlarm? _ringing;

  AlarmDependencies get _dependencies => _locator.get<AlarmDependencies>();

  @override
  String get id => pluginId;

  @override
  String get nameKey => 'alarm.name';

  @override
  String get descriptionKey => 'alarm.description';

  @override
  IconData get icon => AppIcons.alarm.iconData;

  @override
  String get version => '0.1.0';

  @override
  String get entryRoute => AlarmRoutes.base;

  @override
  Future<bool> isAvailable() async => true;

  /// Registra el idioma y las traducciones del plugin. Es idempotente.
  void registerLocalization() {
    _localization.register(
      pluginId,
      (String code) => i18n.LocaleSettings.setLocaleRawSync(code),
      translate: (String key) {
        final Object? value = i18n.alarmStrings[key];
        return value is String ? value : null;
      },
      override: (String code, Map<String, Object?> overrides) =>
          i18n.LocaleSettings.instance.overrideTranslationsFromMapSync(
            locale: i18n.AppLocaleUtils.parse(code),
            isFlatMap: false,
            map: overrides,
          ),
    );
  }

  @override
  Future<void> initialize() async {
    registerLocalization();
    await _locator.pushScope(
      pluginId,
      init: (ServiceLocator locator) async {
        final AlarmRepository repository = locator.get<AlarmRepository>();
        final AlarmScheduler scheduler = locator.get<AlarmScheduler>();
        final Clock clock = locator.isRegistered<Clock>() ? locator.get<Clock>() : const SystemClock();
        final IdGenerator ids =
            locator.isRegistered<IdGenerator>() ? locator.get<IdGenerator>() : const UuidV4Generator();
        final WallClock wallClock =
            locator.isRegistered<WallClock>() ? locator.get<WallClock>() : const SystemWallClock();
        final EventBus events = locator.isRegistered<EventBus>() ? locator.get<EventBus>() : EventBus();
        final SyncAlarmSchedule sync = SyncAlarmSchedule(
          repository: repository,
          scheduler: scheduler,
          clock: clock,
          wallClock: wallClock,
          texts: (Alarm alarm) => (
            title: AlarmFormat.label(alarm),
            body: AlarmFormat.paddedOf(alarm.time),
          ),
        );
        final NextAlarmService nextAlarm = NextAlarmService(
          repository: repository,
          scheduler: scheduler,
          clock: clock,
          wallClock: wallClock,
        );
        final HandleAlarmRang handleRang = HandleAlarmRang(repository, events, clock);
        locator
          ..registerSingleton<AlarmDependencies>(
            AlarmDependencies(
              repository: repository,
              scheduler: scheduler,
              clock: clock,
              wallClock: wallClock,
              createAlarm: CreateAlarm(repository, ids, sync),
              updateAlarm: UpdateAlarm(repository, sync),
              deleteAlarm: DeleteAlarm(repository, sync),
              setEnabled: SetAlarmEnabled(repository, sync),
              entries: GetAlarmEntries(wallClock),
              snooze: SnoozeRingingAlarm(repository, sync, events, clock),
              dismiss: DismissAlarm(repository, scheduler, sync, events, clock),
              watchRinging: WatchRingingAlarm(repository),
              nextAlarm: nextAlarm,
            ),
          )
          ..registerSingleton<NextAlarmQuery>(nextAlarm, dispose: (NextAlarmQuery query) => nextAlarm.dispose());
        await nextAlarm.start();
        await sync();
        // Lo actual ya, para que la primera emisión de cápsulas y avisos no
        // salga vacía.
        _next = nextAlarm.current;
        _canRing = nextAlarm.canRing;
        // Sin `first` sobre el stream: esperaría la cancelación de asyncMap,
        // que en testWidgets no termina.
        final AlarmSession? session = await repository.getSession();
        final Alarm? ringingAlarm = session == null ? null : await repository.getAlarm(session.alarmId);
        _ringing = session == null || ringingAlarm == null ? null : RingingAlarm(alarm: ringingAlarm, session: session);
        _subscriptions
          ..add(ListenToRinging(scheduler, handleRang)().listen(null))
          ..add(nextAlarm.watchNextAlarm().listen((NextAlarm? next) => _update(() => _next = next)))
          ..add(nextAlarm.watchCanRing().listen((bool canRing) => _update(() => _canRing = canRing)))
          ..add(WatchRingingAlarm(repository)().listen((RingingAlarm? ringing) => _update(() => _ringing = ringing)));
        _localization.languageCode.addListener(_onLanguageChanged);
        final Duration? every = _refreshEvery;
        if (every != null) {
          _refreshTimer = Timer.periodic(every, (Timer timer) => unawaited(nextAlarm.refresh()));
        }
      },
    );
  }

  void _update(void Function() change) {
    change();
    if (!_ambientChanges.isClosed) {
      _ambientChanges.add(null);
    }
  }

  void _onLanguageChanged() => _update(() {});

  @override
  Stream<List<AmbientStatus>> watchStatuses() => _replayMapped(
        () => AlarmAmbient.statuses(next: _next, canRing: _canRing, wallClock: _dependencies.wallClock),
      );

  @override
  Stream<List<AmbientAlert>> watchAlerts() => _replayMapped(
        () => AlarmAmbient.alerts(ringing: _ringing, next: _next, canRing: _canRing, wallClock: _dependencies.wallClock),
      );

  @override
  Future<void> onAction(String alertId, String actionId) async {
    final AlarmDependencies dependencies = _dependencies;
    switch ((alertId, actionId)) {
      case (AlarmAlertIds.ringing, AlarmAlertIds.snooze):
        await dependencies.snooze();
      case (AlarmAlertIds.ringing, AlarmAlertIds.dismiss):
        await dependencies.dismiss();
      case (AlarmAlertIds.blocked, AlarmAlertIds.activate):
        await dependencies.scheduler.requestPermissions();
        await dependencies.nextAlarm.refresh();
    }
  }

  /// Emite [current] al suscribirse y cada vez que cambia algo de lo que
  /// depende.
  Stream<T> _replayMapped<T>(T Function() current) {
    StreamSubscription<void>? subscription;
    late final StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () {
        controller.add(current());
        subscription = _ambientChanges.stream.listen((void _) => controller.add(current()), onDone: controller.close);
      },
      onCancel: () {
        unawaited(subscription?.cancel());
      },
    );
    return controller.stream;
  }

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: AlarmRoutes.base,
          builder: (BuildContext context, GoRouterState state) => BlocProvider<AlarmListCubit>(
            create: (BuildContext context) => AlarmListCubit(_dependencies),
            child: AlarmListScreen(
              wallClock: _dependencies.wallClock,
              onCreate: () => context.push(AlarmRoutes.create),
              onEdit: (String alarmId) => context.push(AlarmRoutes.edit(alarmId)),
              onBack: context.canPop() ? () => context.pop() : null,
            ),
          ),
        ),
        GoRoute(
          path: AlarmRoutes.create,
          builder: (BuildContext context, GoRouterState state) => BlocProvider<AlarmEditCubit>(
            create: (BuildContext context) => AlarmEditCubit(_dependencies),
            child: AlarmEditScreen(wallClock: _dependencies.wallClock, onDone: () => _leave(context)),
          ),
        ),
        GoRoute(
          path: AlarmRoutes.editPattern,
          builder: (BuildContext context, GoRouterState state) => BlocProvider<AlarmEditCubit>(
            create: (BuildContext context) {
              final AlarmEditCubit cubit = AlarmEditCubit(_dependencies, alarmId: state.pathParameters['id']);
              unawaited(cubit.load().then((bool found) {
                if (!found && context.mounted) {
                  _leave(context);
                }
              }));
              return cubit;
            },
            child: AlarmEditScreen(wallClock: _dependencies.wallClock, onDone: () => _leave(context)),
          ),
        ),
        GoRoute(
          path: AlarmRoutes.ringing,
          builder: (BuildContext context, GoRouterState state) => BlocProvider<RingingCubit>(
            create: (BuildContext context) => RingingCubit(_dependencies),
            child: AlarmRingingScreen(onFinished: () => _leave(context)),
          ),
        ),
        GoRoute(
          path: AlarmRoutes.snoozed,
          builder: (BuildContext context, GoRouterState state) => BlocProvider<RingingCubit>(
            create: (BuildContext context) => RingingCubit(_dependencies),
            child: AlarmSnoozedScreen(wallClock: _dependencies.wallClock, onClose: () => _leave(context)),
          ),
        ),
      ];

  /// Vuelve atrás o, si es la primera pantalla, al inicio de la app.
  static void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Future<void> dispose() async {
    _refreshTimer?.cancel();
    _localization.languageCode.removeListener(_onLanguageChanged);
    // Sin esperar a las cancelaciones: con el reloj simulado de testWidgets
    // no terminan.
    for (final StreamSubscription<Object?> subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    if (_locator.hasScope(pluginId)) {
      await _locator.dropScope(pluginId);
    }
  }
}
