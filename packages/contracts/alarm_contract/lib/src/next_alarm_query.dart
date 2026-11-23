import 'next_alarm.dart';

/// Capacidad que registra la alarma: cuál es la próxima y si puede sonar.
/// La usa, por ejemplo, la batería para avisar «No llega a la alarma».
abstract interface class NextAlarmQuery {
  /// La próxima alarma, o `null` si no hay ninguna activa. Emite al
  /// suscribirse y cada vez que cambia.
  Stream<NextAlarm?> watchNextAlarm();

  /// Si Android deja sonar las alarmas a su hora (permiso de alarmas
  /// exactas). Emite al suscribirse y cada vez que cambia.
  Stream<bool> watchCanRing();
}
