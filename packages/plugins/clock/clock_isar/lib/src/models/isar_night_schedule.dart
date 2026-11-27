import 'package:storage_isar/adapter.dart';

part 'isar_night_schedule.g.dart';

/// El horario de noche. Solo hay una fila, con [isarId] fijo.
@collection
class IsarNightSchedule {
  static const int singletonId = 1;

  Id isarId = singletonId;

  late int startHour;
  late int startMinute;
  late int endHour;
  late int endMinute;
}
