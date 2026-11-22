import 'package:equatable/equatable.dart';

/// Cómo está la pantalla mientras la app está delante.
class DisplayState extends Equatable {
  const DisplayState({this.keepScreenOn = false, this.brightness, this.immersive = false});

  /// Si la pantalla se mantiene encendida sin apagarse por inactividad.
  final bool keepScreenOn;

  /// Brillo fijado por la app, de 0 a 1; `null` usa el del sistema.
  final double? brightness;

  /// Si las barras de estado y de navegación están ocultas.
  final bool immersive;

  @override
  List<Object?> get props => <Object?>[keepScreenOn, brightness, immersive];

  @override
  bool get stringify => true;
}
