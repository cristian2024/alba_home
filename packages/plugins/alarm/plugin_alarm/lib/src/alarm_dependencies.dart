import 'package:alarm_domain/alarm_domain.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_utils/core_utils.dart';

import 'domain/use_cases/alarm_use_cases.dart';
import 'domain/use_cases/next_alarm_service.dart';
import 'domain/use_cases/ringing_use_cases.dart';

/// Todo lo que necesitan las pantallas del plugin. El plugin lo registra en
/// su scope de `core_di` durante `initialize()`.
class AlarmDependencies {
  const AlarmDependencies({
    required this.repository,
    required this.scheduler,
    required this.clock,
    required this.wallClock,
    required this.createAlarm,
    required this.updateAlarm,
    required this.deleteAlarm,
    required this.setEnabled,
    required this.entries,
    required this.snooze,
    required this.dismiss,
    required this.watchRinging,
    required this.nextAlarm,
  });

  final AlarmRepository repository;
  final AlarmScheduler scheduler;
  final Clock clock;
  final WallClock wallClock;
  final CreateAlarm createAlarm;
  final UpdateAlarm updateAlarm;
  final DeleteAlarm deleteAlarm;
  final SetAlarmEnabled setEnabled;
  final GetAlarmEntries entries;
  final SnoozeRingingAlarm snooze;
  final DismissAlarm dismiss;
  final WatchRingingAlarm watchRinging;
  final NextAlarmService nextAlarm;
}
