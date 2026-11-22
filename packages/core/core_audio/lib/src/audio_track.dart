import 'package:equatable/equatable.dart';

/// Sonido que se puede reproducir: un asset de la app (p. ej. la lluvia de
/// los sonidos para dormir).
class AudioTrack extends Equatable {
  const AudioTrack({required this.id, required this.asset});

  /// Identificador estable del sonido (p. ej. `rain`).
  final String id;

  /// Ruta del asset tal como la declara el `pubspec.yaml` del paquete que lo
  /// aporta (p. ej. `packages/plugin_ambient_sounds/assets/rain.ogg`).
  final String asset;

  @override
  List<Object?> get props => <Object?>[id, asset];

  @override
  bool get stringify => true;
}
