import 'package:equatable/equatable.dart';

/// La foto que toca mostrar: un archivo local del teléfono.
class CurrentPhoto extends Equatable {
  const CurrentPhoto({required this.id, required this.filePath});

  /// Identificador estable de la foto dentro de la presentación.
  final String id;

  /// Ruta absoluta del archivo.
  final String filePath;

  @override
  List<Object?> get props => <Object?>[id, filePath];

  @override
  bool get stringify => true;
}
