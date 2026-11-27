import 'dart:async';

import 'package:clock_contract/clock_contract.dart';
import 'package:clock_domain/clock_domain.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:core_di/core_di.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_frame_contract/photo_frame_contract.dart';

import 'ambient_feed.dart';
import 'clock_dependencies.dart';
import 'domain/night_mode_service.dart';
import 'domain/night_schedule_use_cases.dart';
import 'i18n/strings.g.dart' as i18n;
import 'presentation/clock/clock_cubit.dart';
import 'presentation/clock/clock_screen.dart';
import 'presentation/clock/photo_luminance.dart';
import 'presentation/clock_routes.dart';
import 'presentation/common/clock_ambient.dart';
import 'presentation/night_schedule/night_schedule_cubit.dart';
import 'presentation/night_schedule/night_schedule_screen.dart';

/// Plugin del reloj.
///
/// Toma del `ServiceLocator` de la app:
/// - `NightScheduleRepository` (obligatorio), que registra el adaptador que
///   elige la app (`ClockIsar`).
/// - `Clock`, `WallClock`, `CurrentPhotoQuery` y `AmbientFeed` (opcionales:
///   sin fotos no hay foto de fondo; sin feed, ni bloques ni banners).
///
/// Registra en su scope `NightModeQuery`, que usa la app para el tono de
/// noche. Es [AmbientStatusSource] del bloque «Modo noche» mientras se
/// acerca la noche.
///
/// Mantener la hora abre [settingsRoute]; mientras no haya ajustes, la app
/// pasa la pantalla que quiera.
class ClockPlugin extends HomePlugin implements HomePluginEntryRoute, AmbientStatusSource {
  ClockPlugin({
    required ServiceLocator locator,
    required String settingsRoute,
    LocalizationCoordinator? localization,
    PhotoLuminance photoLuminance = const DecodedPhotoLuminance(),
    Duration? refreshEvery = const Duration(seconds: 20),
    Duration? tick = const Duration(seconds: 1),
  })  : _locator = locator,
        _settingsRoute = settingsRoute,
        _localization = localization ?? LocalizationCoordinator.instance,
        _photoLuminance = photoLuminance,
        _refreshEvery = refreshEvery,
        _tick = tick;

  static const String pluginId = 'clock';

  final ServiceLocator _locator;
  final String _settingsRoute;
  final LocalizationCoordinator _localization;
  final PhotoLuminance _photoLuminance;

  /// Cada cuánto recalcula la fase de noche; `null`, nunca (tests).
  final Duration? _refreshEvery;

  /// Cada cuánto mira la hora la pantalla; `null`, nunca (tests).
  final Duration? _tick;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  StreamSubscription<NightPhase>? _phaseSubscription;
  Timer? _refreshTimer;

  ClockDependencies get _dependencies => _locator.get<ClockDependencies>();

  @override
  String get id => pluginId;

  @override
  String get nameKey => 'clock.name';

  @override
  String get descriptionKey => 'clock.description';

  @override
  IconData get icon => AppIcons.sun.iconData;

  @override
  String get version => '0.1.0';

  @override
  String get entryRoute => ClockRoutes.base;

  @override
  Future<bool> isAvailable() async => true;

  /// Registra el idioma y las traducciones del plugin. Es idempotente.
  void registerLocalization() {
    _localization.register(
      pluginId,
      (String code) => i18n.LocaleSettings.setLocaleRawSync(code),
      translate: (String key) {
        final Object? value = i18n.clockStrings[key];
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
        final NightScheduleRepository repository = locator.get<NightScheduleRepository>();
        final Clock clock = locator.isRegistered<Clock>() ? locator.get<Clock>() : const SystemClock();
        final WallClock wallClock =
            locator.isRegistered<WallClock>() ? locator.get<WallClock>() : const SystemWallClock();
        final NightModeService nightMode = NightModeService(repository: repository, clock: clock, wallClock: wallClock);
        await nightMode.start();
        locator
          ..registerSingleton<ClockDependencies>(
            ClockDependencies(
              clock: clock,
              wallClock: wallClock,
              nightMode: nightMode,
              saveSchedule: SaveNightSchedule(repository),
              photoLuminance: _photoLuminance,
              photos: locator.isRegistered<CurrentPhotoQuery>() ? locator.get<CurrentPhotoQuery>() : null,
              ambient: locator.isRegistered<AmbientFeed>() ? locator.get<AmbientFeed>() : null,
            ),
          )
          ..registerSingleton<NightModeQuery>(nightMode, dispose: (NightModeQuery query) => nightMode.dispose());
        // Sin la primera emisión, que repite la fase de ahora.
        _phaseSubscription = nightMode.watchPhase().skip(1).listen((NightPhase phase) => _changes.add(null));
        _localization.languageCode.addListener(_onLanguageChanged);
        final Duration? every = _refreshEvery;
        if (every != null) {
          _refreshTimer = Timer.periodic(every, (Timer timer) => nightMode.refresh());
        }
      },
    );
  }

  void _onLanguageChanged() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  @override
  Stream<List<AmbientStatus>> watchStatuses() {
    List<AmbientStatus> current() => ClockAmbient.statuses(
          phase: _dependencies.nightMode.current,
          wallClock: _dependencies.wallClock,
        );
    StreamSubscription<void>? subscription;
    late final StreamController<List<AmbientStatus>> controller;
    controller = StreamController<List<AmbientStatus>>(
      onListen: () {
        controller.add(current());
        subscription = _changes.stream.listen((void _) => controller.add(current()), onDone: controller.close);
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
          path: ClockRoutes.base,
          builder: (BuildContext context, GoRouterState state) {
            final AppThemeColors theme = AppThemeColors.of(context);
            return BlocProvider<ClockCubit>(
              create: (BuildContext context) => ClockCubit(
                _dependencies,
                scrimLuminance: _luminance(theme.photoScrimEnd.withValues(alpha: 1)),
                textLuminance: _luminance(theme.textOnPhoto),
                tick: _tick,
              ),
              child: ClockScreen(
                wallClock: _dependencies.wallClock,
                onOpenSettings: () => context.push(_settingsRoute),
                onOpenRoute: (String route) => context.push(route),
              ),
            );
          },
        ),
        GoRoute(
          path: ClockRoutes.nightSchedule,
          builder: (BuildContext context, GoRouterState state) => BlocProvider<NightScheduleCubit>(
            create: (BuildContext context) => NightScheduleCubit(_dependencies),
            child: NightScheduleScreen(onBack: () => _leave(context)),
          ),
        ),
      ];

  static double _luminance(Color color) => PhotoScrim.luminance(
        (color.r * 255).round(),
        (color.g * 255).round(),
        (color.b * 255).round(),
      );

  /// Vuelve atrás o, si es la primera pantalla, al reloj.
  static void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(ClockRoutes.base);
    }
  }

  @override
  Future<void> dispose() async {
    _refreshTimer?.cancel();
    _localization.languageCode.removeListener(_onLanguageChanged);
    // Sin esperar a la cancelación: con el reloj simulado de testWidgets no
    // termina.
    unawaited(_phaseSubscription?.cancel());
    _phaseSubscription = null;
    if (_locator.hasScope(pluginId)) {
      await _locator.dropScope(pluginId);
    }
  }
}
