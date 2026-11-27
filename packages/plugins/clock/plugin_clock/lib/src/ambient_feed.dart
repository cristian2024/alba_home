import 'package:core_contracts/core_contracts.dart';

/// Lo que el reloj necesita de los demás plugins: qué bloques de estado,
/// banner y aviso a pantalla completa se ven, y a quién pasar cada acción.
///
/// Lo implementa la app (que conoce a todos los plugins) y lo registra en el
/// `ServiceLocator`. Sin él, el reloj no muestra bloques ni banners.
abstract interface class AmbientFeed {
  /// Lo que se ve ahora. Emite al suscribirse y cada vez que cambia.
  Stream<AmbientResolution> watch();

  /// El usuario pulsó [actionId] en [alert].
  Future<void> onAction(AmbientAlert alert, String actionId);
}
