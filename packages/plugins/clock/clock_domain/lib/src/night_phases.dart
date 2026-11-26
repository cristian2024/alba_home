import 'package:clock_contract/clock_contract.dart';
import 'package:wall_clock/wall_clock.dart';

import 'local_time.dart';
import 'night_schedule.dart';

/// Calcula la fase de noche de un instante según el horario.
abstract final class NightPhases {
  /// La fase en [now] (UTC) con [schedule] en la hora local de [wallClock].
  ///
  /// - Entre `start` y `end`: noche.
  /// - En los 30 min anteriores a `start`: atardecer, de 0 a 1, con la hora
  ///   a la que empieza la noche.
  /// - En los 15 min posteriores a `end`: amanecer, de 1 a 0.
  /// - El resto: día.
  static NightPhase at(DateTime now, NightSchedule schedule, WallClock wallClock) {
    final DateTime utc = now.toUtc();
    final DateTime today = wallClock.toLocal(utc);
    NightPhase? dusk;
    NightPhase? dawn;
    // La noche que empezó ayer, la de hoy y la de mañana (si empieza pasada la
    // medianoche, su atardecer cae hoy).
    for (int day = -1; day <= 1; day++) {
      final DateTime start = _instant(wallClock, today, day, schedule.start);
      final DateTime end = _instant(wallClock, today, schedule.crossesMidnight ? day + 1 : day, schedule.end);
      if (!utc.isBefore(start) && utc.isBefore(end)) {
        return NightPhase.night;
      }
      final DateTime duskStart = start.subtract(NightSchedule.duskLength);
      if (!utc.isBefore(duskStart) && utc.isBefore(start)) {
        dusk = NightPhase(
          stage: NightStage.dusk,
          darkness: _fraction(utc.difference(duskStart), NightSchedule.duskLength),
          nightStartsAt: start,
        );
      }
      final DateTime dawnEnd = end.add(NightSchedule.dawnLength);
      if (!utc.isBefore(end) && utc.isBefore(dawnEnd)) {
        dawn = NightPhase(
          stage: NightStage.dawn,
          darkness: 1 - _fraction(utc.difference(end), NightSchedule.dawnLength),
        );
      }
    }
    return dusk ?? dawn ?? NightPhase.day;
  }

  static DateTime _instant(WallClock wallClock, DateTime today, int day, LocalTime time) =>
      wallClock.localToUtc(today.year, today.month, today.day + day, time.hour, time.minute);

  static double _fraction(Duration part, Duration whole) => part.inMicroseconds / whole.inMicroseconds;
}
