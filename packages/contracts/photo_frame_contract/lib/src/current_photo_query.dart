import 'current_photo.dart';

/// Capacidad que registran las fotos: la que toca mostrar ahora. El reloj
/// la pone de fondo durante el día.
abstract interface class CurrentPhotoQuery {
  /// La foto actual, o `null` si no hay fotos (02.2). Emite al suscribirse y
  /// cada vez que la presentación pasa a otra.
  Stream<CurrentPhoto?> watchCurrentPhoto();
}
