/// Adaptador Isar del reloj. Quien compone la app solo elige [ClockIsar]; el
/// plugin pide `NightScheduleRepository` al `ServiceLocator` sin saber que
/// detrás hay Isar.
library;

export 'src/clock_isar.dart';
