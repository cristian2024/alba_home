import 'alarm.dart';
import 'wall_clock.dart';
import 'weekday.dart';

/// Cuándo vuelve a sonar una alarma.
abstract final class NextRing {
  /// El próximo instante UTC, estrictamente después de [nowUtc], en que suena
  /// [alarm]; `null` si está desactivada.
  ///
  /// Sin días de repetición, hoy a su hora si aún no pasó y si no mañana. Con
  /// días, el primero de ellos (hoy incluido si aún no pasó la hora).
  static DateTime? after(Alarm alarm, DateTime nowUtc, WallClock wallClock) {
    if (!alarm.enabled) {
      return null;
    }
    final DateTime localNow = wallClock.toLocal(nowUtc);
    // Termina como mucho al octavo día: en ocho días seguidos está cada día de
    // la semana.
    for (int offset = 0;; offset++) {
      final DateTime candidate = wallClock.localToUtc(
        localNow.year,
        localNow.month,
        localNow.day + offset,
        alarm.time.hour,
        alarm.time.minute,
      );
      if (!candidate.isAfter(nowUtc)) {
        continue;
      }
      if (!alarm.isRepeating || alarm.repeat.contains(Weekday.of(wallClock.toLocal(candidate)))) {
        return candidate;
      }
    }
  }

  /// La alarma activa que sonará antes, con su instante; `null` si ninguna.
  /// Con dos a la misma hora, la primera de [alarms].
  static (Alarm, DateTime)? soonest(Iterable<Alarm> alarms, DateTime nowUtc, WallClock wallClock) {
    (Alarm, DateTime)? best;
    for (final Alarm alarm in alarms) {
      final DateTime? at = after(alarm, nowUtc, wallClock);
      if (at != null && (best == null || at.isBefore(best.$2))) {
        best = (alarm, at);
      }
    }
    return best;
  }
}
