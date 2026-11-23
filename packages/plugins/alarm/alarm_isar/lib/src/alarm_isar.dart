import 'package:alarm_domain/alarm_domain.dart';
import 'package:core_di/core_di.dart';
import 'package:storage_isar/adapter.dart';

import 'isar_alarm_repository.dart';
import 'models/isar_alarm.dart';
import 'models/isar_alarm_session.dart';

/// Adaptador Isar de la alarma. Quien compone la app solo lo elige, dentro de
/// `IsarStorage(features: <IsarFeature>[AlarmIsar()])`; con la base abierta
/// registra `AlarmRepository` en el `ServiceLocator`.
class AlarmIsar implements IsarFeature {
  const AlarmIsar();

  @override
  List<CollectionSchema<dynamic>> get schemas => const <CollectionSchema<dynamic>>[
        IsarAlarmSchema,
        IsarAlarmSessionSchema,
      ];

  @override
  void register(ServiceLocator services, Isar isar) =>
      services.registerSingleton<AlarmRepository>(IsarAlarmRepository(isar));
}
