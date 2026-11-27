/// Rutas del plugin. Son absolutas y planas para que la app las añada tal
/// cual a su `GoRouter`.
abstract final class ClockRoutes {
  static const String base = '/clock';
  static const String nightSchedule = '$base/night-schedule';
}
