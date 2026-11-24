import 'package:equatable/equatable.dart';

/// Hora de reloj de pared a la que suena una alarma («6:30»), sin fecha ni
/// zona: la convierte a un instante [WallClock].
class AlarmTime extends Equatable implements Comparable<AlarmTime> {
  /// Lanza [ArgumentError] si [hour] no va de 0 a 23 o [minute] de 0 a 59.
  AlarmTime(this.hour, this.minute) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', 'va de 0 a 23');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(minute, 'minute', 'va de 0 a 59');
    }
  }

  final int hour;
  final int minute;

  /// Minutos desde medianoche.
  int get minutesOfDay => hour * 60 + minute;

  @override
  int compareTo(AlarmTime other) => minutesOfDay.compareTo(other.minutesOfDay);

  @override
  List<Object?> get props => <Object?>[hour, minute];

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
