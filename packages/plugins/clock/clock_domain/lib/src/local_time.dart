import 'package:equatable/equatable.dart';

/// Una hora del día en hora local, sin fecha (22:30).
class LocalTime extends Equatable implements Comparable<LocalTime> {
  LocalTime(this.hour, this.minute) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Hora no válida: $hour:$minute');
    }
  }

  final int hour;
  final int minute;

  /// Minutos desde la medianoche.
  int get minutesOfDay => hour * 60 + minute;

  @override
  int compareTo(LocalTime other) => minutesOfDay.compareTo(other.minutesOfDay);

  @override
  List<Object?> get props => <Object?>[hour, minute];

  @override
  bool get stringify => true;
}
