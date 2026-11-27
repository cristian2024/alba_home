import 'package:bloc/bloc.dart';
import 'package:clock_domain/clock_domain.dart';
import 'package:equatable/equatable.dart';

import '../../clock_dependencies.dart';

/// El horario que se edita y si la última elección no valía.
class NightScheduleState extends Equatable {
  const NightScheduleState({required this.start, required this.end, this.sameTime = false});

  final LocalTime start;
  final LocalTime end;

  /// La última elección hacía empezar y terminar la noche a la vez: no se
  /// guardó.
  final bool sameTime;

  @override
  List<Object?> get props => <Object?>[start, end, sameTime];
}

/// Horario de noche (08.2): cada cambio de rueda se guarda al momento; no
/// hay botón de guardar.
class NightScheduleCubit extends Cubit<NightScheduleState> {
  NightScheduleCubit(this._dependencies)
      : super(
          NightScheduleState(
            start: _dependencies.nightMode.schedule.start,
            end: _dependencies.nightMode.schedule.end,
          ),
        );

  final ClockDependencies _dependencies;

  Future<void> setStartHour(int hour) => _save(start: LocalTime(hour, state.start.minute));

  Future<void> setStartMinute(int minute) => _save(start: LocalTime(state.start.hour, minute));

  Future<void> setEndHour(int hour) => _save(end: LocalTime(hour, state.end.minute));

  Future<void> setEndMinute(int minute) => _save(end: LocalTime(state.end.hour, minute));

  Future<void> _save({LocalTime? start, LocalTime? end}) async {
    final LocalTime newStart = start ?? state.start;
    final LocalTime newEnd = end ?? state.end;
    final bool saved = await _dependencies.saveSchedule(start: newStart, end: newEnd);
    if (!isClosed) {
      emit(NightScheduleState(start: newStart, end: newEnd, sameTime: !saved));
    }
  }
}
