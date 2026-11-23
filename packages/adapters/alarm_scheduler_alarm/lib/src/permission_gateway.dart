import 'package:permission_handler/permission_handler.dart';

/// Los permisos que necesita una alarma, detrás de una interfaz para poder
/// probar el adaptador sin dispositivo.
abstract interface class PermissionGateway {
  /// Alarmas exactas (Android 12 o posterior; antes, siempre concedido).
  Future<bool> exactAlarms();

  /// Notificaciones (Android 13 o posterior; antes, siempre concedido).
  Future<bool> notifications();

  Future<bool> requestExactAlarms();

  Future<bool> requestNotifications();
}

/// [PermissionGateway] sobre `permission_handler`.
class PermissionHandlerGateway implements PermissionGateway {
  const PermissionHandlerGateway();

  @override
  Future<bool> exactAlarms() => Permission.scheduleExactAlarm.isGranted;

  @override
  Future<bool> notifications() => Permission.notification.isGranted;

  @override
  Future<bool> requestExactAlarms() async => (await Permission.scheduleExactAlarm.request()).isGranted;

  @override
  Future<bool> requestNotifications() async => (await Permission.notification.request()).isGranted;
}
