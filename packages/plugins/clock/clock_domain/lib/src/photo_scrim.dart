import 'dart:math' as math;

/// La opacidad del degradado sobre la foto, para que la hora se lea a 7:1
/// o más (The Two-Metre Rule de `DESIGN.md`).
///
/// El diseño usa un degradado al 72 % (8,0:1 medido con una foto de nieve).
/// Con fotos aún más claras sube lo justo; nunca baja del 72 %.
abstract final class PhotoScrim {
  /// Opacidad del diseño.
  static const double baseline = 0.72;

  /// Contraste mínimo de la hora.
  static const double targetContrast = 7;

  /// Opacidad del final del degradado para una foto cuya banda inferior
  /// tiene luminancia relativa [photoLuminance] (0 a 1), con el degradado de
  /// luminancia [scrimLuminance] y la hora de [textLuminance].
  ///
  /// Flutter mezcla en sRGB, no en luz lineal: la mezcla se calcula sobre el
  /// gris sRGB equivalente a cada luminancia.
  static double opacityFor({
    required double photoLuminance,
    required double scrimLuminance,
    required double textLuminance,
  }) {
    // El fondo más claro que aún da [targetContrast] con el texto.
    final double maxBackground = (textLuminance + 0.05) / targetContrast - 0.05;
    final double photo = toSrgb(photoLuminance);
    final double scrim = toSrgb(scrimLuminance);
    final double limit = toSrgb(math.max(0, maxBackground));
    if (photo <= limit || photo <= scrim) {
      return baseline;
    }
    final double needed = (photo - limit) / (photo - scrim);
    return math.min(1, math.max(baseline, needed));
  }

  /// Valor sRGB (0 a 1) de un gris con luminancia relativa [luminance].
  static double toSrgb(double luminance) => luminance <= 0.0031308
      ? luminance * 12.92
      : 1.055 * math.pow(luminance, 1 / 2.4).toDouble() - 0.055;

  /// Luminancia relativa de un gris sRGB [value] (0 a 1).
  static double fromSrgb(double value) =>
      value <= 0.04045 ? value / 12.92 : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

  /// Contraste WCAG entre dos luminancias relativas.
  static double contrast(double a, double b) =>
      (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);

  /// Luminancia relativa (WCAG) de un color sRGB de 8 bits por canal.
  static double luminance(int red, int green, int blue) =>
      0.2126 * _linear(red) + 0.7152 * _linear(green) + 0.0722 * _linear(blue);

  /// Luminancia media de los píxeles [rgba] (4 bytes por píxel, como los da
  /// `Image.toByteData` en `rawRgba`). `0` si no hay píxeles.
  static double averageLuminance(List<int> rgba) {
    final int pixels = rgba.length ~/ 4;
    if (pixels == 0) {
      return 0;
    }
    double total = 0;
    for (int i = 0; i < pixels * 4; i += 4) {
      total += luminance(rgba[i], rgba[i + 1], rgba[i + 2]);
    }
    return total / pixels;
  }

  static double _linear(int channel) => fromSrgb(channel / 255);
}
