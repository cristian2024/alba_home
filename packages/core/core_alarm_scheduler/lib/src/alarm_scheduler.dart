import 'alarm_permissions.dart';
import 'scheduled_alarm.dart';

/// Programa alarmas exactas en el sistema: suenan a su hora aunque la app
/// esté cerrada, la pantalla apagada o el teléfono se haya reiniciado.
///
/// Cuando una alarma suena, sale de [scheduled] y pasa a [watchRinging]
/// hasta que alguien la detiene con [stop].
abstract interface class AlarmScheduler {
  /// Programa [alarm], sustituyendo la que tuviera el mismo id (también si
  /// estaba sonando: deja de sonar).
  ///
  /// Lanza [ArgumentError] si `alarm.at` no está en UTC o no es futuro, si el
  /// volumen no está entre 0 y 1 o si el fundido es negativo.
  Future<void> schedule(ScheduledAlarm alarm);

  /// Cancela la alarma [id], programada o sonando. Si no existe, no hace nada.
  Future<void> cancel(String id);

  /// Detiene la alarma [id] que está sonando. Si no suena, no hace nada.
  Future<void> stop(String id);

  /// Alarmas pendientes, de la más próxima a la más lejana.
  Future<List<ScheduledAlarm>> scheduled();

  /// Alarmas sonando ahora, en el orden en que empezaron. Emite la lista
  /// actual al suscribirse y cada cambio después.
  Stream<List<ScheduledAlarm>> watchRinging();

  /// Estado de los permisos.
  Future<AlarmPermissions> permissions();

  /// Pide los permisos que falten (puede abrir los ajustes del sistema) y
  /// devuelve cómo quedan.
  Future<AlarmPermissions> requestPermissions();
}
