import 'package:alarm_domain/alarm_domain.dart';
import 'package:core_utils/core_utils.dart';

import '../alarm_sound.dart';
import 'sync_alarm_schedule.dart';

/// Lo que se edita de una alarma en 03.3.
class AlarmDraft {
  const AlarmDraft({
    required this.time,
    this.label = '',
    this.repeat = const <Weekday>{},
    this.soundId = 'sunrise',
    this.rise = const Duration(minutes: 1),
    this.snooze = const Duration(minutes: 10),
    this.maxSnoozes = 3,
    this.vibrate = true,
  });

  /// Lo editable de [alarm].
  factory AlarmDraft.of(Alarm alarm) => AlarmDraft(
        time: alarm.time,
        label: alarm.label,
        repeat: alarm.repeat,
        soundId: alarm.soundId,
        rise: alarm.rise,
        snooze: alarm.snooze,
        maxSnoozes: alarm.maxSnoozes,
        vibrate: alarm.vibrate,
      );

  final AlarmTime time;
  final String label;
  final Set<Weekday> repeat;
  final String soundId;
  final Duration rise;
  final Duration snooze;
  final int maxSnoozes;
  final bool vibrate;
}

/// Crea una alarma activa con un UUID nuevo y la programa. Devuelve la
/// alarma creada.
class CreateAlarm {
  CreateAlarm(this._repository, this._ids, this._sync);

  final AlarmRepository _repository;
  final IdGenerator _ids;
  final SyncAlarmSchedule _sync;

  Future<Alarm> call(AlarmDraft draft) async {
    final Alarm alarm = Alarm(
      id: _ids.newId(),
      time: draft.time,
      label: draft.label.trim(),
      repeat: draft.repeat,
      soundId: AlarmSounds.byId(draft.soundId).id,
      rise: draft.rise,
      snooze: draft.snooze,
      maxSnoozes: draft.maxSnoozes,
      vibrate: draft.vibrate,
    );
    await _repository.saveAlarm(alarm);
    await _sync();
    return alarm;
  }
}

/// Guarda los cambios de una alarma, la activa (editar es querer que suene) y
/// la reprograma. Lanza [StateError] si ya no existe.
class UpdateAlarm {
  UpdateAlarm(this._repository, this._sync);

  final AlarmRepository _repository;
  final SyncAlarmSchedule _sync;

  Future<Alarm> call(String id, AlarmDraft draft) async {
    final Alarm? current = await _repository.getAlarm(id);
    if (current == null) {
      throw StateError('No existe la alarma $id');
    }
    final Alarm updated = current.copyWith(
      time: draft.time,
      label: draft.label.trim(),
      repeat: draft.repeat,
      soundId: AlarmSounds.byId(draft.soundId).id,
      rise: draft.rise,
      snooze: draft.snooze,
      maxSnoozes: draft.maxSnoozes,
      vibrate: draft.vibrate,
      enabled: true,
    );
    await _repository.saveAlarm(updated);
    await _sync();
    return updated;
  }
}

/// Activa o desactiva una alarma. Sin ella no hace nada.
class SetAlarmEnabled {
  SetAlarmEnabled(this._repository, this._sync);

  final AlarmRepository _repository;
  final SyncAlarmSchedule _sync;

  Future<void> call(String id, {required bool enabled}) async {
    final Alarm? alarm = await _repository.getAlarm(id);
    if (alarm == null || alarm.enabled == enabled) {
      return;
    }
    await _repository.saveAlarm(alarm.copyWith(enabled: enabled));
    await _sync();
  }
}

/// Borra una alarma (y su sesión) y la quita de Android.
class DeleteAlarm {
  DeleteAlarm(this._repository, this._sync);

  final AlarmRepository _repository;
  final SyncAlarmSchedule _sync;

  Future<void> call(String id) async {
    await _repository.deleteAlarm(id);
    await _sync();
  }
}

/// Una alarma de la lista con su próxima vez.
class AlarmListEntry {
  const AlarmListEntry({required this.alarm, required this.nextRing});

  final Alarm alarm;

  /// En UTC; `null` si está desactivada.
  final DateTime? nextRing;
}

/// Las alarmas por hora, con su próxima vez calculada en [now].
class GetAlarmEntries {
  GetAlarmEntries(this._wallClock);

  final WallClock _wallClock;

  List<AlarmListEntry> call(List<Alarm> alarms, DateTime now) => <AlarmListEntry>[
        for (final Alarm alarm in alarms) AlarmListEntry(alarm: alarm, nextRing: NextRing.after(alarm, now, _wallClock)),
      ];
}
