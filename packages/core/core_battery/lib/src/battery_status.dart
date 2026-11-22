import 'package:equatable/equatable.dart';

/// Si la batería recibe corriente.
enum BatteryChargeState {
  /// Enchufado y cargando.
  charging,

  /// Sin cargador.
  discharging,

  /// Enchufado y al 100 %.
  full,

  /// Enchufado pero sin cargar (p. ej. por temperatura o por la protección de
  /// carga del sistema).
  notCharging,

  /// El sistema no lo informa.
  unknown,
}

/// Lectura de la batería en un momento dado.
class BatteryStatus extends Equatable {
  const BatteryStatus({required this.level, required this.state, this.temperatureCelsius})
      : assert(level >= 0 && level <= 100, 'level va de 0 a 100');

  /// Porcentaje de carga, de 0 a 100.
  final int level;

  final BatteryChargeState state;

  /// Temperatura de la batería en grados Celsius; `null` si el sistema no la
  /// da.
  final double? temperatureCelsius;

  /// Si el cargador está conectado, cargue o no.
  bool get isPluggedIn =>
      state == BatteryChargeState.charging || state == BatteryChargeState.full || state == BatteryChargeState.notCharging;

  @override
  List<Object?> get props => <Object?>[level, state, temperatureCelsius];

  @override
  bool get stringify => true;
}
