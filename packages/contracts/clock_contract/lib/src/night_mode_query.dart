import 'night_phase.dart';

/// Capacidad que registra el reloj: la fase de noche según su horario. La
/// usa la app para poner el tono de noche y las horas de silencio de los
/// avisos.
abstract interface class NightModeQuery {
  /// La fase actual. Emite al suscribirse y cada vez que cambia.
  Stream<NightPhase> watchPhase();
}
