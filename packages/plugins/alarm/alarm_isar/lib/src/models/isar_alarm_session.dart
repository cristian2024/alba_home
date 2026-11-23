import 'package:storage_isar/adapter.dart';

part 'isar_alarm_session.g.dart';

/// La alarma que suena o está pospuesta. Solo hay una fila, con [isarId] fijo.
@collection
class IsarAlarmSession {
  static const int singletonId = 1;

  Id isarId = singletonId;

  late String alarmId;
  late DateTime startedAt;
  late int snoozesUsed;
  DateTime? snoozedUntil;
}
