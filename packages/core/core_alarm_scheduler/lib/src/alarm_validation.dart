import 'scheduled_alarm.dart';

/// Comprobaciones que comparten las implementaciones de `AlarmScheduler`,
/// para que todas rechacen lo mismo.
abstract final class AlarmValidation {
  /// Lanza [ArgumentError] si [alarm] no se puede programar en [nowUtc].
  static void check(ScheduledAlarm alarm, DateTime nowUtc) {
    if (!alarm.at.isUtc) {
      throw ArgumentError.value(alarm.at, 'at', 'debe estar en UTC');
    }
    if (!alarm.at.isAfter(nowUtc)) {
      throw ArgumentError.value(alarm.at, 'at', 'debe ser posterior a $nowUtc');
    }
    if (alarm.volume.isNaN || alarm.volume < 0 || alarm.volume > 1) {
      throw ArgumentError.value(alarm.volume, 'volume', 'debe estar entre 0 y 1');
    }
    if (alarm.fadeIn.isNegative) {
      throw ArgumentError.value(alarm.fadeIn, 'fadeIn', 'no puede ser negativo');
    }
  }
}
