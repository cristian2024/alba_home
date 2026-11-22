/// Dobles de prueba y tests de contrato de `core_alarm_scheduler`.
library;

import 'dart:async';

import 'package:core_utils/core_utils.dart';

import 'core_alarm_scheduler.dart';

export 'src/testing/alarm_scheduler_contract.dart';

/// [AlarmScheduler] en memoria. Las alarmas no suenan solas: el test las
/// dispara con [fire] o con [fireDue] tras avanzar el reloj. Cumple
/// `alarmSchedulerContract`.
class InMemoryAlarmScheduler implements AlarmScheduler {
  InMemoryAlarmScheduler({Clock clock = const SystemClock(), AlarmPermissions permissions = AlarmPermissions.granted})
      : _clock = clock,
        _permissions = permissions;

  final Clock _clock;
  final Map<String, ScheduledAlarm> _scheduled = <String, ScheduledAlarm>{};
  final List<ScheduledAlarm> _ringing = <ScheduledAlarm>[];
  final StreamController<List<ScheduledAlarm>> _ringingChanges =
      StreamController<List<ScheduledAlarm>>.broadcast();
  AlarmPermissions _permissions;

  /// Permisos que concedería el usuario al pedirlos; `null` deja los actuales.
  AlarmPermissions? permissionsAfterRequest;

  /// Cuántas veces se pidieron los permisos.
  int permissionRequests = 0;

  /// Cambia los permisos actuales (p. ej. Android bloquea las alarmas exactas).
  set currentPermissions(AlarmPermissions permissions) => _permissions = permissions;

  /// Hace sonar ya la alarma programada [id]. Si no existe, no hace nada.
  void fire(String id) {
    final ScheduledAlarm? alarm = _scheduled.remove(id);
    if (alarm == null) {
      return;
    }
    _ringing.add(alarm);
    _emitRinging();
  }

  /// Hace sonar todas las alarmas cuya hora ya llegó según el reloj, por
  /// orden de hora.
  void fireDue() {
    final DateTime now = _clock.nowUtc();
    final List<ScheduledAlarm> due = _sorted(_scheduled.values.where((ScheduledAlarm a) => !a.at.isAfter(now)));
    for (final ScheduledAlarm alarm in due) {
      fire(alarm.id);
    }
  }

  @override
  Future<void> schedule(ScheduledAlarm alarm) async {
    AlarmValidation.check(alarm, _clock.nowUtc());
    _removeRinging(alarm.id);
    _scheduled[alarm.id] = alarm;
  }

  @override
  Future<void> cancel(String id) async {
    _scheduled.remove(id);
    _removeRinging(id);
  }

  @override
  Future<void> stop(String id) async => _removeRinging(id);

  @override
  Future<List<ScheduledAlarm>> scheduled() async => _sorted(_scheduled.values);

  @override
  Stream<List<ScheduledAlarm>> watchRinging() => _replayCurrent(() => _ringingSnapshot, _ringingChanges.stream);

  @override
  Future<AlarmPermissions> permissions() async => _permissions;

  @override
  Future<AlarmPermissions> requestPermissions() async {
    permissionRequests++;
    _permissions = permissionsAfterRequest ?? _permissions;
    return _permissions;
  }

  /// Cierra el stream de alarmas sonando.
  Future<void> close() => _ringingChanges.close();

  List<ScheduledAlarm> get _ringingSnapshot => List<ScheduledAlarm>.unmodifiable(_ringing);

  void _removeRinging(String id) {
    final int before = _ringing.length;
    _ringing.removeWhere((ScheduledAlarm alarm) => alarm.id == id);
    if (_ringing.length != before) {
      _emitRinging();
    }
  }

  void _emitRinging() => _ringingChanges.add(_ringingSnapshot);

  static List<ScheduledAlarm> _sorted(Iterable<ScheduledAlarm> alarms) =>
      alarms.toList()..sort((ScheduledAlarm a, ScheduledAlarm b) => a.at.compareTo(b.at));
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
