import 'package:alarm_domain/alarm_domain.dart';
import 'package:storage_isar/adapter.dart';

import 'alarm_mapper.dart';
import 'models/isar_alarm.dart';
import 'models/isar_alarm_session.dart';

/// [AlarmRepository] sobre Isar. Pasa `alarmRepositoryContract`. Toda
/// escritura va en una transacción.
class IsarAlarmRepository implements AlarmRepository {
  IsarAlarmRepository(this._isar);

  final Isar _isar;

  IsarCollection<IsarAlarm> get _alarms => _isar.isarAlarms;
  IsarCollection<IsarAlarmSession> get _sessions => _isar.isarAlarmSessions;

  QueryBuilder<IsarAlarm, IsarAlarm, QAfterSortBy> get _sortedQuery =>
      _alarms.where().sortByHour().thenByMinute().thenById();

  @override
  Stream<List<Alarm>> watchAlarms() => _sortedQuery.watch(fireImmediately: true).map(_toDomain);

  @override
  Future<List<Alarm>> getAlarms() async => _toDomain(await _sortedQuery.findAll());

  @override
  Future<Alarm?> getAlarm(String id) async {
    final IsarAlarm? model = await _alarms.getById(id);
    return model == null ? null : AlarmMapper.fromIsar(model);
  }

  @override
  Future<void> saveAlarm(Alarm alarm) => _isar.writeTxn(() => _alarms.putById(AlarmMapper.toIsar(alarm)));

  @override
  Future<void> deleteAlarm(String id) => _isar.writeTxn(() async {
        await _alarms.deleteById(id);
        final IsarAlarmSession? session = await _sessions.get(IsarAlarmSession.singletonId);
        if (session?.alarmId == id) {
          await _sessions.delete(IsarAlarmSession.singletonId);
        }
      });

  @override
  Stream<AlarmSession?> watchSession() => _sessions
      .watchObject(IsarAlarmSession.singletonId, fireImmediately: true)
      .map((IsarAlarmSession? model) => model == null ? null : AlarmMapper.sessionFromIsar(model));

  @override
  Future<AlarmSession?> getSession() async {
    final IsarAlarmSession? model = await _sessions.get(IsarAlarmSession.singletonId);
    return model == null ? null : AlarmMapper.sessionFromIsar(model);
  }

  @override
  Future<void> saveSession(AlarmSession? session) => _isar.writeTxn(() async {
        if (session == null) {
          await _sessions.delete(IsarAlarmSession.singletonId);
        } else {
          await _sessions.put(AlarmMapper.sessionToIsar(session));
        }
      });

  static List<Alarm> _toDomain(List<IsarAlarm> models) => models.map(AlarmMapper.fromIsar).toList();
}
