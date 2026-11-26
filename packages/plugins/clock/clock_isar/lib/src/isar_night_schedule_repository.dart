import 'package:clock_domain/clock_domain.dart';
import 'package:storage_isar/adapter.dart';

import 'models/isar_night_schedule.dart';

/// [NightScheduleRepository] sobre Isar, en una sola fila. Pasa
/// `nightScheduleRepositoryContract`.
class IsarNightScheduleRepository implements NightScheduleRepository {
  IsarNightScheduleRepository(this._isar);

  final Isar _isar;

  IsarCollection<IsarNightSchedule> get _schedules => _isar.isarNightSchedules;

  @override
  Future<NightSchedule> get() async => _toDomain(await _schedules.get(IsarNightSchedule.singletonId));

  @override
  Future<void> save(NightSchedule schedule) => _isar.writeTxn(() => _schedules.put(toIsar(schedule)));

  @override
  Stream<NightSchedule> watch() =>
      _schedules.watchObject(IsarNightSchedule.singletonId, fireImmediately: true).map(_toDomain);

  static IsarNightSchedule toIsar(NightSchedule schedule) => IsarNightSchedule()
    ..startHour = schedule.start.hour
    ..startMinute = schedule.start.minute
    ..endHour = schedule.end.hour
    ..endMinute = schedule.end.minute;

  static NightSchedule _toDomain(IsarNightSchedule? model) => model == null
      ? NightSchedule.standard()
      : NightSchedule(
          start: LocalTime(model.startHour, model.startMinute),
          end: LocalTime(model.endHour, model.endMinute),
        );
}
