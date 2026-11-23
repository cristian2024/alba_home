import 'package:alarm_domain/alarm_domain.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_utils/core_utils.dart';

import '../alarm_sound.dart';

/// Textos de la notificación del sistema para [alarm] (título y cuerpo), ya
/// traducidos. Los pone la capa de presentación.
typedef AlarmNotificationTexts = ({String title, String? body}) Function(Alarm alarm);

/// Pone lo programado en Android de acuerdo con lo guardado: cada alarma
/// activa en su próxima hora (o en la de su posposición) y las desactivadas,
/// canceladas. No toca la alarma que está sonando.
///
/// Se ejecuta al arrancar y tras cada cambio. Es idempotente.
class SyncAlarmSchedule {
  SyncAlarmSchedule({
    required AlarmRepository repository,
    required AlarmScheduler scheduler,
    required Clock clock,
    required WallClock wallClock,
    required AlarmNotificationTexts texts,
  })  : _repository = repository,
        _scheduler = scheduler,
        _clock = clock,
        _wallClock = wallClock,
        _texts = texts;

  final AlarmRepository _repository;
  final AlarmScheduler _scheduler;
  final Clock _clock;
  final WallClock _wallClock;
  final AlarmNotificationTexts _texts;

  Future<void> call() async {
    final DateTime now = _clock.nowUtc();
    final AlarmSession? session = await _repository.getSession();
    final List<Alarm> alarms = await _repository.getAlarms();
    final Set<String> known = <String>{for (final Alarm alarm in alarms) alarm.id};

    for (final Alarm alarm in alarms) {
      if (session != null && session.alarmId == alarm.id) {
        if (session.isSnoozed) {
          await _scheduleAt(alarm, session.snoozedUntil!, now);
        }
        // Sonando: no se toca hasta que se apague o se posponga.
        continue;
      }
      final DateTime? next = NextRing.after(alarm, now, _wallClock);
      if (next == null) {
        await _scheduler.cancel(alarm.id);
      } else {
        await _scheduleAt(alarm, next, now);
      }
    }

    // Lo programado que ya no corresponde a ninguna alarma guardada.
    for (final ScheduledAlarm scheduled in await _scheduler.scheduled()) {
      if (!known.contains(scheduled.id)) {
        await _scheduler.cancel(scheduled.id);
      }
    }
  }

  Future<void> _scheduleAt(Alarm alarm, DateTime at, DateTime now) async {
    // Una posposición que venció con la app cerrada suena ya.
    final DateTime when = at.isAfter(now) ? at : now.add(const Duration(seconds: 1));
    final ({String title, String? body}) text = _texts(alarm);
    await _scheduler.schedule(
      ScheduledAlarm(
        id: alarm.id,
        at: when,
        title: text.title,
        body: text.body,
        soundAsset: AlarmSounds.byId(alarm.soundId).asset,
        fadeIn: alarm.rise,
        vibrate: alarm.vibrate,
      ),
    );
  }
}
