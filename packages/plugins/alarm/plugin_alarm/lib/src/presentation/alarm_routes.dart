/// Rutas del plugin. Son absolutas y planas para que la app las añada tal
/// cual a su `GoRouter`.
abstract final class AlarmRoutes {
  static const String base = '/alarm';
  static const String create = '$base/new';
  static const String editPattern = '$base/:id/edit';
  static const String ringing = '$base/ringing';
  static const String snoozed = '$base/snoozed';

  static String edit(String alarmId) => '$base/${Uri.encodeComponent(alarmId)}/edit';
}
