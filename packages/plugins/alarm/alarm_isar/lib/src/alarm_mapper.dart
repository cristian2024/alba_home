import 'package:alarm_domain/alarm_domain.dart';

import 'models/isar_alarm.dart';
import 'models/isar_alarm_session.dart';

/// Conversión entre el dominio y los modelos Isar. Las fechas vuelven en UTC.
abstract final class AlarmMapper {
  static IsarAlarm toIsar(Alarm alarm) => IsarAlarm()
    ..id = alarm.id
    ..hour = alarm.time.hour
    ..minute = alarm.time.minute
    ..label = alarm.label
    ..repeat = (alarm.repeat.map((Weekday day) => day.index).toList()..sort())
    ..enabled = alarm.enabled
    ..soundId = alarm.soundId
    ..riseSeconds = alarm.rise.inSeconds
    ..snoozeSeconds = alarm.snooze.inSeconds
    ..maxSnoozes = alarm.maxSnoozes
    ..vibrate = alarm.vibrate;

  static Alarm fromIsar(IsarAlarm model) => Alarm(
        id: model.id,
        time: AlarmTime(model.hour, model.minute),
        label: model.label,
        repeat: <Weekday>{for (final int index in model.repeat) Weekday.values[index]},
        enabled: model.enabled,
        soundId: model.soundId,
        rise: Duration(seconds: model.riseSeconds),
        snooze: Duration(seconds: model.snoozeSeconds),
        maxSnoozes: model.maxSnoozes,
        vibrate: model.vibrate,
      );

  static IsarAlarmSession sessionToIsar(AlarmSession session) => IsarAlarmSession()
    ..alarmId = session.alarmId
    ..startedAt = session.startedAt.toUtc()
    ..snoozesUsed = session.snoozesUsed
    ..snoozedUntil = session.snoozedUntil?.toUtc();

  static AlarmSession sessionFromIsar(IsarAlarmSession model) => AlarmSession(
        alarmId: model.alarmId,
        startedAt: model.startedAt.toUtc(),
        snoozesUsed: model.snoozesUsed,
        snoozedUntil: model.snoozedUntil?.toUtc(),
      );
}
