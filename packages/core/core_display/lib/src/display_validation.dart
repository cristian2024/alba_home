/// Comprobaciones que comparten las implementaciones de `DisplayControl`.
abstract final class DisplayValidation {
  /// Lanza [ArgumentError] si [brightness] no está entre 0 y 1.
  static void brightness(double brightness) {
    if (brightness.isNaN || brightness < 0 || brightness > 1) {
      throw ArgumentError.value(brightness, 'brightness', 'debe estar entre 0 y 1');
    }
  }
}
