/// Comprobaciones de argumentos que comparten las implementaciones de
/// `AudioPlayback`, para que todas fallen igual.
abstract final class AudioValidation {
  /// Lanza [ArgumentError] si [volume] no está entre 0 y 1.
  static void volume(double volume) {
    if (volume.isNaN || volume < 0 || volume > 1) {
      throw ArgumentError.value(volume, 'volume', 'debe estar entre 0 y 1');
    }
  }

  /// Lanza [ArgumentError] si [duration] es negativa.
  static void fade(Duration duration, String name) {
    if (duration.isNegative) {
      throw ArgumentError.value(duration, name, 'no puede ser negativo');
    }
  }
}
