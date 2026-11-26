import 'dart:io';

import 'package:clock_domain/clock_domain.dart';
import 'package:clock_domain/testing.dart';
import 'package:clock_isar/clock_isar.dart';
import 'package:clock_isar/src/isar_night_schedule_repository.dart';
import 'package:core_di/core_di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage_isar/adapter.dart';
import 'package:storage_isar/storage_isar.dart';
import 'package:storage_isar/testing.dart';

/// El reloj sobre Isar tal como lo compone una app: [IsarStorage] con
/// [ClockIsar], en un locator propio y un directorio temporal.
class _TestStorage {
  _TestStorage._(this.services, this._directory);

  final ServiceLocator services;
  final Directory _directory;

  NightScheduleRepository get repository => services.get<NightScheduleRepository>();

  static Future<_TestStorage> open() async {
    final Directory directory = Directory.systemTemp.createTempSync('clock_isar_test');
    final ServiceLocator services = ServiceLocator();
    await IsarStorage(directory: directory.path, features: const <IsarFeature>[ClockIsar()]).register(services);
    return _TestStorage._(services, directory);
  }

  Future<void> close() async {
    await services.reset();
    _directory.deleteSync(recursive: true);
  }
}

void main() {
  setUpAll(initializeIsarForTests);

  final Map<NightScheduleRepository, _TestStorage> storages = <NightScheduleRepository, _TestStorage>{};
  nightScheduleRepositoryContract(
    'Isar',
    create: () async {
      final _TestStorage storage = await _TestStorage.open();
      storages[storage.repository] = storage;
      return storage.repository;
    },
    dispose: (NightScheduleRepository repository) => storages.remove(repository)!.close(),
  );

  test('ClockIsar aporta su colección y registra el repositorio Isar', () async {
    final _TestStorage storage = await _TestStorage.open();
    addTearDown(storage.close);

    expect(
      const ClockIsar().schemas.map((CollectionSchema<dynamic> schema) => schema.name),
      <String>['IsarNightSchedule'],
    );
    expect(storage.repository, isA<IsarNightScheduleRepository>());
  });
}
