import 'package:alarm_contract/alarm_contract.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_events/core_events.dart';
import 'package:core_utils/core_utils.dart';

import 'sync_alarm_schedule.dart';

/// Lo que suena ahora: la alarma y su sesión.
class RingingAlarm {
  const RingingAlarm({required this.alarm, required this.session});

  final Alarm alarm;
  final AlarmSession session;
}

/// Llamado cuando Android empieza a sonar [scheduledId]: abre la sesión (o la
/// retoma tras una posposición) y publica [AlarmRang]. Ignora lo que no es
/// una alarma guardada (p. ej. un temporizador de cocina).
class HandleAlarmRang {
  HandleAlarmRang(this._repository, this._events, this._clock);

  final AlarmRepository _repository;
  final EventBus _events;
  final Clock _clock;

  Future<void> call(String scheduledId) async {
    final Alarm? alarm = await _repository.getAlarm(scheduledId);
    if (alarm == null) {
      return;
    }
    final DateTime now = _clock.nowUtc();
    final AlarmSession? current = await _repository.getSession();
    if (current != null && current.alarmId == alarm.id && !current.isSnoozed) {
      return;
    }
    final AlarmSession session = current != null && current.alarmId == alarm.id
        ? current.ringAgain()
        : AlarmSession(alarmId: alarm.id, startedAt: now);
    await _repository.saveSession(session);
    _events.publish(AlarmRang(alarmId: alarm.id, label: alarm.label, rangAt: now));
  }
}

/// Pospone la alarma que suena: vuelve a sonar dentro de su `snooze`. No hace
/// nada si no suena ninguna o ya no le quedan posposiciones.
class SnoozeRingingAlarm {
  SnoozeRingingAlarm(this._repository, this._sync, this._events, this._clock);

  final AlarmRepository _repository;
  final SyncAlarmSchedule _sync;
  final EventBus _events;
  final Clock _clock;

  /// Devuelve la sesión pospuesta, o `null` si no se pudo posponer.
  Future<AlarmSession?> call() async {
    final AlarmSession? session = await _repository.getSession();
    if (session == null || session.isSnoozed) {
      return null;
    }
    final Alarm? alarm = await _repository.getAlarm(session.alarmId);
    if (alarm == null || !session.canSnooze(alarm)) {
      return null;
    }
    final DateTime now = _clock.nowUtc();
    final AlarmSession snoozed = session.snooze(alarm, now);
    await _repository.saveSession(snoozed);
    // Programar el mismo id deja de sonar y la deja pendiente.
    await _sync();
    _events.publish(AlarmSnoozed(alarmId: alarm.id, until: snoozed.snoozedUntil!, snoozedAt: now));
    return snoozed;
  }
}

/// Apaga la alarma que suena o está pospuesta: cierra la sesión, desactiva
/// las de una sola vez y programa la próxima de las que se repiten.
class DismissAlarm {
  DismissAlarm(this._repository, this._scheduler, this._sync, this._events, this._clock);

  final AlarmRepository _repository;
  final AlarmScheduler _scheduler;
  final SyncAlarmSchedule _sync;
  final EventBus _events;
  final Clock _clock;

  Future<void> call() async {
    final AlarmSession? session = await _repository.getSession();
    if (session == null) {
      return;
    }
    await _scheduler.stop(session.alarmId);
    await _scheduler.cancel(session.alarmId);
    await _repository.saveSession(null);
    final Alarm? alarm = await _repository.getAlarm(session.alarmId);
    if (alarm != null) {
      await _repository.saveAlarm(afterDismiss(alarm));
    }
    await _sync();
    _events.publish(AlarmDismissed(alarmId: session.alarmId, dismissedAt: _clock.nowUtc()));
  }
}

/// La alarma que suena o está pospuesta, con su sesión; `null` si ninguna.
class WatchRingingAlarm {
  WatchRingingAlarm(this._repository);

  final AlarmRepository _repository;

  Stream<RingingAlarm?> call() => _repository.watchSession().asyncMap((AlarmSession? session) async {
        if (session == null) {
          return null;
        }
        final Alarm? alarm = await _repository.getAlarm(session.alarmId);
        return alarm == null ? null : RingingAlarm(alarm: alarm, session: session);
      });
}

/// Escucha lo que Android hace sonar y lo pasa a [HandleAlarmRang]. Devuelve
/// la suscripción para cancelarla al liberar el plugin.
class ListenToRinging {
  ListenToRinging(this._scheduler, this._handle);

  final AlarmScheduler _scheduler;
  final HandleAlarmRang _handle;

  Stream<void> call() => _scheduler.watchRinging().asyncExpand(
        (List<ScheduledAlarm> ringing) => Stream<void>.fromFutures(<Future<void>>[
          for (final ScheduledAlarm alarm in ringing) _handle(alarm.id),
        ]),
      );
}
