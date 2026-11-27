import 'night_schedule.dart';

/// Dónde se guarda el horario de noche. Toda implementación pasa
/// `nightScheduleRepositoryContract` de `package:clock_domain/testing.dart`.
abstract interface class NightScheduleRepository {
  /// El horario guardado, o [NightSchedule.standard] si aún no hay ninguno.
  Future<NightSchedule> get();

  Future<void> save(NightSchedule schedule);

  /// Emite el horario al suscribirse y cada vez que se guarda otro.
  Stream<NightSchedule> watch();
}
