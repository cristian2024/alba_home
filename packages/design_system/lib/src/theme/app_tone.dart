/// Sobre qué fondo va un componente. Elige entre las variantes de Penpot
/// (`Status/Capsule/Photo-Warning`, `Alert/Banner/Night`…).
enum AppTone {
  /// Sobre el lienzo o una superficie del tema claro u oscuro.
  surface,

  /// Sobre la foto del reloj, con el degradado detrás: texto claro, velo y
  /// borde blancos translúcidos.
  photo,

  /// Modo noche: ámbar sobre negro, sin blanco ni color saturado.
  night,
}

/// Urgencia de un estado o aviso: normal, aviso (ocre) o peligro
/// (terracota; rojo de noche).
enum AppUrgency { normal, warning, urgent }
