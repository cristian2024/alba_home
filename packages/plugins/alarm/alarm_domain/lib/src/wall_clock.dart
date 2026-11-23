/// Traduce entre instantes UTC y la hora de reloj de pared del aparato. El
/// dominio guarda instantes en UTC; las alarmas se piensan en hora local.
abstract interface class WallClock {
  /// La fecha y hora local de [utc].
  DateTime toLocal(DateTime utc);

  /// El instante UTC de la hora local [year]-[month]-[day] [hour]:[minute].
  /// Normaliza fechas fuera de rango (día 32 → día 1 del mes siguiente).
  DateTime localToUtc(int year, int month, int day, int hour, int minute);
}

/// La zona horaria del sistema, con sus cambios de horario.
class SystemWallClock implements WallClock {
  const SystemWallClock();

  @override
  DateTime toLocal(DateTime utc) => utc.toLocal();

  @override
  DateTime localToUtc(int year, int month, int day, int hour, int minute) =>
      DateTime(year, month, day, hour, minute).toUtc();
}

/// Una zona con diferencia fija respecto a UTC (Colombia es UTC−5 todo el
/// año). Sirve también en los tests, que no dependen de la zona de la máquina.
class FixedOffsetWallClock implements WallClock {
  const FixedOffsetWallClock(this.offset);

  /// Hora local menos UTC (−5 h en Colombia).
  final Duration offset;

  /// La hora local se representa con un `DateTime` en UTC desplazado: sus
  /// campos (año, día, hora) son los locales.
  @override
  DateTime toLocal(DateTime utc) => utc.toUtc().add(offset);

  @override
  DateTime localToUtc(int year, int month, int day, int hour, int minute) =>
      DateTime.utc(year, month, day, hour, minute).subtract(offset);
}
