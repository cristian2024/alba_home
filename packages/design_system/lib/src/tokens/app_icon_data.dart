import 'package:flutter/widgets.dart';

/// Un icono de Penpot: su nombre, su código en la fuente `AlbaIcons` y el
/// trazado SVG en una caja de 24. Las constantes de `AppIcons` son únicas, así
/// que se comparan por identidad.
@immutable
class AppIconData {
  const AppIconData(this.name, this.iconData, this.pathData);

  /// Nombre en Penpot (`battery-low`).
  final String name;

  /// El mismo icono como glifo de la fuente `AlbaIcons`, para los contratos
  /// que piden un `IconData` (`HomePlugin.icon`, cápsulas y avisos de
  /// `core_contracts`). Es constante para que Flutter pueda recortar la
  /// fuente al compilar.
  final IconData iconData;

  /// Trazado SVG absoluto con los comandos M, L, H, V, Q y Z.
  final String pathData;

  /// Lado de la caja del trazado.
  static const double viewBox = 24;

  static const String fontFamily = 'AlbaIcons';
  static const String fontPackage = 'design_system';

  /// Código del glifo en `assets/fonts/AlbaIcons.ttf`.
  int get codepoint => iconData.codePoint;

  @override
  String toString() => 'AppIconData($name)';
}
