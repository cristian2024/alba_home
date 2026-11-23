import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';

/// Lo que el adaptador usa del paquete `alarm`, detrás de una interfaz para
/// poder probar el adaptador sin dispositivo.
abstract interface class AlarmBackend {
  Future<void> init();

  /// Programa o sustituye por id. Devuelve si el sistema lo aceptó.
  Future<bool> set(AlarmSettings settings);

  Future<void> stop(int id);

  /// Programadas y sonando.
  Future<List<AlarmSettings>> getAlarms();

  /// Las que suenan ahora; emite al suscribirse y en cada cambio.
  Stream<Set<AlarmSettings>> watchRinging();
}

/// [AlarmBackend] sobre el paquete `alarm`.
class AlarmPackageBackend implements AlarmBackend {
  const AlarmPackageBackend();

  @override
  Future<void> init() => Alarm.init();

  @override
  Future<bool> set(AlarmSettings settings) => Alarm.set(alarmSettings: settings);

  @override
  Future<void> stop(int id) => Alarm.stop(id);

  @override
  Future<List<AlarmSettings>> getAlarms() => Alarm.getAlarms();

  @override
  Stream<Set<AlarmSettings>> watchRinging() => Alarm.ringing.map((AlarmSet set) => set.alarms);
}
