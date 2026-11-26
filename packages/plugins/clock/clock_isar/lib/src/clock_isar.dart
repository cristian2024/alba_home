import 'package:clock_domain/clock_domain.dart';
import 'package:core_di/core_di.dart';
import 'package:storage_isar/adapter.dart';

import 'isar_night_schedule_repository.dart';
import 'models/isar_night_schedule.dart';

/// Adaptador Isar del reloj. Quien compone la app solo lo elige, dentro de
/// `IsarStorage(features: <IsarFeature>[ClockIsar()])`; con la base abierta
/// registra `NightScheduleRepository` en el `ServiceLocator`.
class ClockIsar implements IsarFeature {
  const ClockIsar();

  @override
  List<CollectionSchema<dynamic>> get schemas => const <CollectionSchema<dynamic>>[IsarNightScheduleSchema];

  @override
  void register(ServiceLocator services, Isar isar) =>
      services.registerSingleton<NightScheduleRepository>(IsarNightScheduleRepository(isar));
}
