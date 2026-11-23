/// Dobles de prueba y tests de contrato de `alarm_domain`.
library;

import 'dart:async';

import 'alarm_domain.dart';

export 'src/testing/alarm_repository_contract.dart';

/// [AlarmRepository] en memoria. Cumple `alarmRepositoryContract`.
class InMemoryAlarmRepository implements AlarmRepository {
  final Map<String, Alarm> _alarms = <String, Alarm>{};
  final StreamController<List<Alarm>> _alarmChanges = StreamController<List<Alarm>>.broadcast();
  final StreamController<AlarmSession?> _sessionChanges = StreamController<AlarmSession?>.broadcast();
  AlarmSession? _session;

  List<Alarm> get _sorted => _alarms.values.toList()..sort((Alarm a, Alarm b) => a.time.compareTo(b.time));

  @override
  Stream<List<Alarm>> watchAlarms() => _replayCurrent(() => _sorted, _alarmChanges.stream);

  @override
  Future<List<Alarm>> getAlarms() async => _sorted;

  @override
  Future<Alarm?> getAlarm(String id) async => _alarms[id];

  @override
  Future<void> saveAlarm(Alarm alarm) async {
    _alarms[alarm.id] = alarm;
    _alarmChanges.add(_sorted);
  }

  @override
  Future<void> deleteAlarm(String id) async {
    if (_alarms.remove(id) == null) {
      return;
    }
    _alarmChanges.add(_sorted);
    if (_session?.alarmId == id) {
      await saveSession(null);
    }
  }

  @override
  Stream<AlarmSession?> watchSession() => _replayCurrent(() => _session, _sessionChanges.stream);

  @override
  Future<AlarmSession?> getSession() async => _session;

  @override
  Future<void> saveSession(AlarmSession? session) async {
    _session = session;
    _sessionChanges.add(session);
  }

  /// Cierra los streams.
  Future<void> close() async {
    await _alarmChanges.close();
    await _sessionChanges.close();
  }
}

/// Emite [current] al suscribirse y después [changes], suscribiéndose a
/// [changes] en el mismo momento para no perder nada.
Stream<T> _replayCurrent<T>(T Function() current, Stream<T> changes) {
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
