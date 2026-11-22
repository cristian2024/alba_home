import 'battery_status.dart';

/// Lee el estado de la batería del aparato.
abstract interface class BatteryReader {
  /// Lectura actual.
  Future<BatteryStatus> current();

  /// Emite la lectura actual al suscribirse y una nueva cada vez que cambia
  /// el nivel, el estado de carga o la temperatura. No repite lecturas
  /// iguales seguidas.
  Stream<BatteryStatus> watchStatus();
}
