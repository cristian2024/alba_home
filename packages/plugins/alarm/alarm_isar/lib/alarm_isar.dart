/// Adaptador Isar de la alarma. Quien compone la app solo elige [AlarmIsar];
/// el plugin pide `AlarmRepository` al `ServiceLocator` sin saber que detrás
/// hay Isar.
library;

export 'src/alarm_isar.dart';
