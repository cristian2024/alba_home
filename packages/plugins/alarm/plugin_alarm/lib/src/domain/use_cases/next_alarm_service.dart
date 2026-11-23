import 'dart:async';

import 'package:alarm_contract/alarm_contract.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_utils/core_utils.dart';

/// [NextAlarmQuery] del plugin: la próxima alarma (la pospuesta, si la hay) y
/// si Android deja sonar. El reloj y la batería lo usan.
///
/// La próxima vez se recalcula cuando cambian las alarmas o la sesión, y con
/// [refresh] (el plugin lo llama cada minuto y al volver a la app, que es
/// cuando pasa la hora o cambian los permisos).
class NextAlarmService implements NextAlarmQuery {
  NextAlarmService({
    required AlarmRepository repository,
    required AlarmScheduler scheduler,
    required Clock clock,
    required WallClock wallClock,
  })  : _repository = repository,
        _scheduler = scheduler,
        _clock = clock,
        _wallClock = wallClock;

  final AlarmRepository _repository;
  final AlarmScheduler _scheduler;
  final Clock _clock;
  final WallClock _wallClock;
  final StreamController<NextAlarm?> _next = StreamController<NextAlarm?>.broadcast();
  final StreamController<bool> _canRing = StreamController<bool>.broadcast();
  final List<StreamSubscription<Object?>> _subscriptions = <StreamSubscription<Object?>>[];

  List<Alarm> _alarms = const <Alarm>[];
  AlarmSession? _session;
  NextAlarm? _currentNext;
  bool _currentCanRing = true;

  /// Empieza a seguir las alarmas y la sesión, y lee los permisos.
  Future<void> start() async {
    _alarms = await _repository.getAlarms();
    _session = await _repository.getSession();
    _subscriptions
      ..add(_repository.watchAlarms().listen((List<Alarm> alarms) {
        _alarms = alarms;
        _recompute();
      }))
      ..add(_repository.watchSession().listen((AlarmSession? session) {
        _session = session;
        _recompute();
      }));
    await refresh();
  }

  /// Recalcula la próxima alarma con la hora actual y vuelve a leer los
  /// permisos.
  Future<void> refresh() async {
    _recompute();
    final bool canRing = (await _scheduler.permissions()).canRing;
    if (canRing != _currentCanRing) {
      _currentCanRing = canRing;
      _canRing.add(canRing);
    }
  }

  void _recompute() {
    final NextAlarm? next = _compute();
    if (next != _currentNext) {
      _currentNext = next;
      _next.add(next);
    }
  }

  NextAlarm? _compute() {
    final AlarmSession? session = _session;
    if (session != null && session.isSnoozed) {
      final Alarm? snoozed = _alarms.where((Alarm alarm) => alarm.id == session.alarmId).firstOrNull;
      if (snoozed != null) {
        return NextAlarm(alarmId: snoozed.id, ringsAt: session.snoozedUntil!, label: snoozed.label, isSnoozed: true);
      }
    }
    final (Alarm, DateTime)? soonest = NextRing.soonest(
      _alarms.where((Alarm alarm) => alarm.id != session?.alarmId),
      _clock.nowUtc(),
      _wallClock,
    );
    return soonest == null ? null : NextAlarm(alarmId: soonest.$1.id, ringsAt: soonest.$2, label: soonest.$1.label);
  }

  /// La próxima alarma ahora mismo.
  NextAlarm? get current => _currentNext;

  /// Si Android deja sonar ahora mismo (según la última lectura).
  bool get canRing => _currentCanRing;

  @override
  Stream<NextAlarm?> watchNextAlarm() => _replay(() => _currentNext, _next.stream);

  @override
  Stream<bool> watchCanRing() => _replay(() => _currentCanRing, _canRing.stream);

  Future<void> dispose() async {
    // Sin esperar a las cancelaciones: con el reloj simulado de testWidgets
    // no terminan.
    for (final StreamSubscription<Object?> subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    await _next.close();
    await _canRing.close();
  }

  static Stream<T> _replay<T>(T Function() current, Stream<T> changes) {
    StreamSubscription<T>? subscription;
    late final StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () {
        controller.add(current());
        subscription = changes.listen(controller.add, onDone: controller.close);
      },
      // No devuelve el futuro de cancel(): `first` lo esperaría y, con el
      // reloj simulado de testWidgets, no se completa.
      onCancel: () {
        unawaited(subscription?.cancel());
      },
    );
    return controller.stream;
  }
}
