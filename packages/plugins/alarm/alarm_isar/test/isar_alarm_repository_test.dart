import 'dart:io';

import 'package:alarm_domain/alarm_domain.dart';
import 'package:alarm_domain/testing.dart';
import 'package:alarm_isar/alarm_isar.dart';
import 'package:alarm_isar/src/alarm_mapper.dart';
import 'package:alarm_isar/src/isar_alarm_repository.dart';
import 'package:alarm_isar/src/models/isar_alarm_session.dart';
import 'package:core_di/core_di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage_isar/adapter.dart';
import 'package:storage_isar/storage_isar.dart';
import 'package:storage_isar/testing.dart';

/// La alarma sobre Isar tal como la compone una app: [IsarStorage] con
/// [AlarmIsar], en un locator propio y un directorio temporal.
class _TestStorage {
  _TestStorage._(this.services, this._directory);

  final ServiceLocator services;
  final Directory _directory;

  AlarmRepository get repository => services.get<AlarmRepository>();

  static Future<_TestStorage> open() async {
    final Directory directory = Directory.systemTemp.createTempSync('alarm_isar_test');
    final ServiceLocator services = ServiceLocator();
    await IsarStorage(directory: directory.path, features: const <IsarFeature>[AlarmIsar()]).register(services);
    return _TestStorage._(services, directory);
  }

  Future<void> close() async {
    await services.reset();
    _directory.deleteSync(recursive: true);
  }
}

void main() {
  setUpAll(initializeIsarForTests);

  final Map<AlarmRepository, _TestStorage> storages = <AlarmRepository, _TestStorage>{};
  alarmRepositoryContract(
    'Isar',
    create: () async {
      final _TestStorage storage = await _TestStorage.open();
      storages[storage.repository] = storage;
      return storage.repository;
    },
    dispose: (AlarmRepository repository) => storages.remove(repository)!.close(),
  );

  test('AlarmIsar aporta sus colecciones y registra el repositorio Isar', () async {
    final _TestStorage storage = await _TestStorage.open();
    addTearDown(storage.close);

    expect(
      const AlarmIsar().schemas.map((CollectionSchema<dynamic> schema) => schema.name),
      <String>['IsarAlarm', 'IsarAlarmSession'],
    );
    expect(storage.repository, isA<IsarAlarmRepository>());
  });

  test('el mapeo devuelve las fechas de la sesión en UTC', () {
    final AlarmSession session = AlarmSession(
      alarmId: 'a',
      startedAt: DateTime.utc(2026, 11, 19, 11, 30),
      snoozedUntil: DateTime.utc(2026, 11, 19, 11, 40),
    );
    final IsarAlarmSession model = AlarmMapper.sessionToIsar(session)
      ..startedAt = session.startedAt.toLocal()
      ..snoozedUntil = session.snoozedUntil!.toLocal();

    final AlarmSession back = AlarmMapper.sessionFromIsar(model);
    expect(back, session);
    expect(back.startedAt.isUtc, isTrue);
  });
}
