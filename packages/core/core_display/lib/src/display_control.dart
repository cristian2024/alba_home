import 'display_state.dart';

/// Controla la pantalla del aparato mientras la app está delante: mantenerla
/// encendida, el brillo (p. ej. el mínimo de noche) y el modo inmersivo.
abstract interface class DisplayControl {
  /// Estado actual.
  Future<DisplayState> current();

  /// Mantiene la pantalla encendida o deja que se apague por inactividad.
  Future<void> setKeepScreenOn(bool keepOn);

  /// Fija el brillo de la app, de 0 a 1. Lanza [ArgumentError] fuera de rango.
  Future<void> setBrightness(double brightness);

  /// Vuelve al brillo del sistema.
  Future<void> resetBrightness();

  /// Oculta o muestra las barras del sistema.
  Future<void> setImmersive(bool immersive);
}
