import 'package:storage_isar/adapter.dart';

part 'isar_alarm.g.dart';

/// Una alarma en Isar.
@collection
class IsarAlarm {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id; // UUID v4

  late int hour;
  late int minute;
  late String label;

  /// Días de repetición por índice de `Weekday` (0 lunes … 6 domingo).
  List<int> repeat = <int>[];

  late bool enabled;
  late String soundId;
  late int riseSeconds;
  late int snoozeSeconds;
  late int maxSnoozes;
  late bool vibrate;
}
