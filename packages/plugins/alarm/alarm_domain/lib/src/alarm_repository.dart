import 'alarm.dart';
import 'alarm_session.dart';

/// Guarda las alarmas y la que está sonando o pospuesta.
abstract interface class AlarmRepository {
  /// Todas las alarmas, por hora del día. Emite al suscribirse y en cada
  /// cambio.
  Stream<List<Alarm>> watchAlarms();

  /// Las alarmas, por hora del día.
  Future<List<Alarm>> getAlarms();

  Future<Alarm?> getAlarm(String id);

  /// Crea o sustituye por id.
  Future<void> saveAlarm(Alarm alarm);

  /// Borra la alarma [id] y su sesión, si la tiene. Sin ella no hace nada.
  Future<void> deleteAlarm(String id);

  /// La alarma que suena o está pospuesta; `null` si ninguna. Emite al
  /// suscribirse y en cada cambio.
  Stream<AlarmSession?> watchSession();

  Future<AlarmSession?> getSession();

  /// Guarda la sesión (solo hay una a la vez) o la borra con `null`.
  Future<void> saveSession(AlarmSession? session);
}
