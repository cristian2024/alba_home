import 'package:equatable/equatable.dart';

/// Permisos del sistema que necesita una alarma para sonar a su hora y
/// mostrarse encima de todo.
class AlarmPermissions extends Equatable {
  const AlarmPermissions({required this.exactAlarms, required this.notifications, required this.fullScreen});

  /// Todos concedidos.
  static const AlarmPermissions granted = AlarmPermissions(exactAlarms: true, notifications: true, fullScreen: true);

  /// Alarmas exactas (Android 12 o posterior). Sin él la alarma no suena a su
  /// hora: es el aviso «Las alarmas no sonarán».
  final bool exactAlarms;

  /// Notificaciones (Android 13 o posterior).
  final bool notifications;

  /// Abrir la pantalla de la alarma encima de la de bloqueo (Android 14 o
  /// posterior).
  final bool fullScreen;

  /// Si la alarma puede sonar a su hora. Sin [notifications] o [fullScreen]
  /// suena, pero puede no verse.
  bool get canRing => exactAlarms;

  bool get allGranted => exactAlarms && notifications && fullScreen;

  @override
  List<Object?> get props => <Object?>[exactAlarms, notifications, fullScreen];

  @override
  bool get stringify => true;
}
