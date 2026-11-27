import 'package:clock_domain/clock_domain.dart';

/// Guarda el horario de noche (08.2). Lo rechaza si empieza y termina a la
/// misma hora.
class SaveNightSchedule {
  const SaveNightSchedule(this._repository);

  final NightScheduleRepository _repository;

  /// Guarda el horario de [start] a [end]. Devuelve `false`, sin guardar, si
  /// son la misma hora.
  Future<bool> call({required LocalTime start, required LocalTime end}) async {
    if (start == end) {
      return false;
    }
    await _repository.save(NightSchedule(start: start, end: end));
    return true;
  }
}
