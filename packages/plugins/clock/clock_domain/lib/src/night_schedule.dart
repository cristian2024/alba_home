import 'package:equatable/equatable.dart';

import 'local_time.dart';

/// Cuándo es de noche (08.2): empieza a [start] y termina a [end], en hora
/// local. Si [end] es antes que [start], la noche cruza la medianoche.
///
/// La pantalla se funde a negro y ámbar en los [duskLength] anteriores a
/// [start] y vuelve al día en los [dawnLength] posteriores a [end].
class NightSchedule extends Equatable {
  NightSchedule({required this.start, required this.end}) {
    if (start == end) {
      throw ArgumentError('La noche no puede empezar y terminar a la misma hora');
    }
  }

  /// De 22:30 a 6:45, como en Penpot.
  factory NightSchedule.standard() => NightSchedule(start: LocalTime(22, 30), end: LocalTime(6, 45));

  static const Duration duskLength = Duration(minutes: 30);
  static const Duration dawnLength = Duration(minutes: 15);

  final LocalTime start;
  final LocalTime end;

  /// Si la noche pasa por la medianoche (22:30 a 6:45).
  bool get crossesMidnight => end.compareTo(start) < 0;

  NightSchedule copyWith({LocalTime? start, LocalTime? end}) =>
      NightSchedule(start: start ?? this.start, end: end ?? this.end);

  @override
  List<Object?> get props => <Object?>[start, end];

  @override
  bool get stringify => true;
}
