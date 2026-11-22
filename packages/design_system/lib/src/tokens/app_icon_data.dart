import 'package:flutter/foundation.dart';

/// Un icono de Penpot: su nombre y el trazado SVG en una caja de 24. Las
/// constantes de `AppIcons` son únicas, así que se comparan por identidad.
@immutable
class AppIconData {
  const AppIconData(this.name, this.pathData);

  /// Nombre en Penpot (`battery-low`).
  final String name;

  /// Trazado SVG absoluto con los comandos M, L, H, V, Q y Z.
  final String pathData;

  /// Lado de la caja del trazado.
  static const double viewBox = 24;

  @override
  String toString() => 'AppIconData($name)';
}
