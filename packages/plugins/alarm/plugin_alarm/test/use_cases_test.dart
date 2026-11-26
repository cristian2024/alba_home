import 'dart:async';

import 'package:alarm_contract/alarm_contract.dart';
import 'package:alarm_contract/testing.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:alarm_domain/testing.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_alarm_scheduler/testing.dart';
import 'package:core_events/testing.dart';
import 'package:core_utils/core_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_alarm/src/domain/alarm_sound.dart';
import 'package:plugin_alarm/src/domain/use_cases/alarm_use_cases.dart';
import 'package:plugin_alarm/src/domain/use_cases/next_alarm_service.dart';
import 'package:plugin_alarm/src/domain/use_cases/ringing_use_cases.dart';
import 'package:plugin_alarm/src/domain/use_cases/sync_alarm_schedule.dart';

const WallClock bogota = FixedOffsetWallClock(Duration(hours: -5));

/// Miércoles 18 de noviembre de 2026, 23:17 en Bogotá.
final DateTime t0 = bogota.localToUtc(2026, 11, 18, 23, 17);

DateTime local(int day, int hour, [int minute = 0]) => bogota.localToUtc(2026, 11, day, hour, minute);

class _SequenceIds implements IdGenerator {
  int _next = 1;

  @override
  String newId() => 'alarm-${_next++}';
}

/// Todo lo que necesitan los casos de uso, con dobles en memoria.
class _World {
  _World() {
    sync = SyncAlarmSchedule(
      repository: repository,
      scheduler: scheduler,
      clock: clock,
      wallClock: bogota,
      texts: (Alarm alarm) => (title: alarm.label.isEmpty ? 'Alarma' : alarm.label, body: null),
    );
  }

  final InMemoryAlarmRepository repository = InMemoryAlarmRepository();
  final FixedClock clock = FixedClock(t0);
  late final InMemoryAlarmScheduler scheduler = InMemoryAlarmScheduler(clock: clock);
  final RecordingEventBus events = RecordingEventBus();
  final _SequenceIds ids = _SequenceIds();
  late final SyncAlarmSchedule sync;

  CreateAlarm get create => CreateAlarm(repository, ids, sync);
  HandleAlarmRang get handleRang => HandleAlarmRang(repository, events, clock);
  SnoozeRingingAlarm get snooze => SnoozeRingingAlarm(repository, sync, events, clock);
  DismissAlarm get dismiss => DismissAlarm(repository, scheduler, sync, events, clock);

  Future<void> dispose() async {
    await repository.close();
    await scheduler.close();
    await events.dispose();
  }
}

void main() {
  late _World world;

  setUp(() => world = _World());
  tearDown(() => world.dispose());

  group('AlarmSounds', () {
    test('byId devuelve el sonido o, si ya no existe, el de por defecto', () {
      expect(AlarmSounds.byId('bell'), AlarmSounds.bell);
      expect(AlarmSounds.byId('desconocido'), AlarmSounds.sunrise);
      expect(AlarmSounds.all, hasLength(3));
      expect(AlarmSounds.sunrise.asset, 'packages/plugin_alarm/assets/sounds/sunrise.wav');
      expect(AlarmSounds.bell, isNot(AlarmSounds.sunrise));
      expect(AlarmSounds.bell, const AlarmSound(id: 'bell', asset: 'packages/plugin_alarm/assets/sounds/bell.wav'));
    });
  });

  group('CreateAlarm', () {
    test('crea una alarma activa con id nuevo, la guarda y la programa', () async {
      final Alarm alarm = await world.create(
        AlarmDraft(time: AlarmTime(6, 30), label: '  Trabajo ', repeat: Weekday.weekdays, soundId: 'bell'),
      );

      expect(alarm.id, 'alarm-1');
      expect(alarm.label, 'Trabajo');
      expect(alarm.enabled, isTrue);
      expect(await world.repository.getAlarm('alarm-1'), alarm);
      final List<ScheduledAlarm> scheduled = await world.scheduler.scheduled();
      expect(scheduled.single.id, 'alarm-1');
      expect(scheduled.single.at, local(19, 6, 30));
      expect(scheduled.single.title, 'Trabajo');
      expect(scheduled.single.soundAsset, AlarmSounds.bell.asset);
      expect(scheduled.single.fadeIn, const Duration(minutes: 1));
    });

    test('un sonido desconocido pasa al de por defecto', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(6, 30), soundId: 'viejo'));

      expect(alarm.soundId, 'sunrise');
    });
  });

  group('UpdateAlarm', () {
    test('guarda los cambios, la activa y la reprograma', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(6, 30)));
      await SetAlarmEnabled(world.repository, world.sync)(alarm.id, enabled: false);

      final Alarm updated = await UpdateAlarm(world.repository, world.sync)(
        alarm.id,
        AlarmDraft.of(alarm.copyWith(time: AlarmTime(7, 0), label: 'Gimnasio', vibrate: false)),
      );

      expect(updated.enabled, isTrue);
      expect(updated.time, AlarmTime(7, 0));
      expect(updated.vibrate, isFalse);
      expect((await world.scheduler.scheduled()).single.at, local(19, 7));
    });

    test('lanza StateError si la alarma ya no existe', () async {
      expect(
        () => UpdateAlarm(world.repository, world.sync)('nada', AlarmDraft(time: AlarmTime(6, 30))),
        throwsStateError,
      );
    });
  });

  group('SetAlarmEnabled y DeleteAlarm', () {
    test('desactivar la cancela y activar la vuelve a programar', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(6, 30)));
      final SetAlarmEnabled setEnabled = SetAlarmEnabled(world.repository, world.sync);

      await setEnabled(alarm.id, enabled: false);
      expect(await world.scheduler.scheduled(), isEmpty);
      expect((await world.repository.getAlarm(alarm.id))!.enabled, isFalse);

      await setEnabled(alarm.id, enabled: true);
      expect(await world.scheduler.scheduled(), hasLength(1));
    });

    test('sin cambio o sin alarma no hace nada', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(6, 30)));
      final SetAlarmEnabled setEnabled = SetAlarmEnabled(world.repository, world.sync);

      await setEnabled(alarm.id, enabled: true);
      await setEnabled('nada', enabled: false);

      expect(await world.scheduler.scheduled(), hasLength(1));
    });

    test('borrar la quita del repositorio y de Android', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(6, 30)));

      await DeleteAlarm(world.repository, world.sync)(alarm.id);

      expect(await world.repository.getAlarms(), isEmpty);
      expect(await world.scheduler.scheduled(), isEmpty);
    });
  });

  group('GetAlarmEntries', () {
    test('calcula la próxima vez de cada una; null si está desactivada', () async {
      final Alarm on = Alarm(id: 'a', time: AlarmTime(6, 30), label: '', soundId: 'sunrise');
      final Alarm off = on.copyWith(enabled: false);

      final List<AlarmListEntry> entries = GetAlarmEntries(bogota)(<Alarm>[on, off], t0);

      expect(entries.first.nextRing, local(19, 6, 30));
      expect(entries.last.nextRing, isNull);
      expect(entries.last.alarm, off);
    });
  });

  group('SyncAlarmSchedule', () {
    test('cancela lo programado que ya no corresponde a ninguna alarma', () async {
      await world.scheduler.schedule(
        ScheduledAlarm(id: 'huerfana', at: local(19, 8), title: 'x', soundAsset: 'x.wav'),
      );

      await world.sync();

      expect(await world.scheduler.scheduled(), isEmpty);
    });

    test('no toca la alarma que suena y programa la pospuesta a su hora', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30)));
      world.clock.advance(const Duration(minutes: 13));
      world.scheduler.fire(alarm.id);
      await world.handleRang(alarm.id);

      await world.sync();
      expect(await world.scheduler.watchRinging().first, hasLength(1));

      await world.snooze();
      expect((await world.scheduler.scheduled()).single.at, t0.add(const Duration(minutes: 23)));
    });

    test('una posposición que venció con la app cerrada suena enseguida', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30)));
      await world.repository.saveSession(
        AlarmSession(alarmId: alarm.id, startedAt: t0, snoozesUsed: 1, snoozedUntil: t0.subtract(const Duration(minutes: 1))),
      );

      await world.sync();

      expect((await world.scheduler.scheduled()).single.at, t0.add(const Duration(seconds: 1)));
    });

    test('una de una sola vez guarda el instante para el que se programó', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30)));

      expect((await world.repository.getAlarm(alarm.id))!.onceAt, local(18, 23, 30));
      world.clock.advance(const Duration(minutes: 5));
      await world.sync();
      expect((await world.scheduler.scheduled()).single.at, local(18, 23, 30));
    });

    test('una de una sola vez que sonó con la app cerrada queda desactivada', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30)));
      world.clock.advance(const Duration(minutes: 20));

      await world.sync();

      final Alarm stored = (await world.repository.getAlarm(alarm.id))!;
      expect(stored.enabled, isFalse);
      expect(stored.onceAt, isNull);
      expect(await world.scheduler.scheduled(), isEmpty);
    });

    test('una que se repite y sonó con la app cerrada pasa a su próxima vez', () async {
      await world.create(AlarmDraft(time: AlarmTime(23, 30), repeat: Weekday.everyDay));
      world.clock.advance(const Duration(minutes: 20));

      await world.sync();

      expect((await world.scheduler.scheduled()).single.at, local(19, 23, 30));
    });

    test('no toca la que suena en Android aunque la app aún no tenga sesión', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30)));
      world.clock.advance(const Duration(minutes: 13));
      world.scheduler.fire(alarm.id);

      await world.sync();

      expect((await world.repository.getAlarm(alarm.id))!.enabled, isTrue);
      expect(await world.scheduler.watchRinging().first, hasLength(1));
    });

    test('usa el título por defecto si la alarma no tiene nombre', () async {
      await world.create(AlarmDraft(time: AlarmTime(6, 30)));

      expect((await world.scheduler.scheduled()).single.title, 'Alarma');
    });
  });

  group('sonar, posponer y apagar', () {
    test('al sonar abre la sesión y publica AlarmRang', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30), label: 'Siesta'));
      world.clock.advance(const Duration(minutes: 13));

      await world.handleRang(alarm.id);

      final AlarmSession session = (await world.repository.getSession())!;
      expect(session.alarmId, alarm.id);
      expect(session.isSnoozed, isFalse);
      expect(world.events.publishedOf<AlarmRang>().single.label, 'Siesta');
    });

    test('ignora lo que no es una alarma guardada y no repite si ya suena', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30)));

      await world.handleRang('temporizador-de-cocina');
      await world.handleRang(alarm.id);
      await world.handleRang(alarm.id);

      expect(world.events.publishedOf<AlarmRang>(), hasLength(1));
    });

    test('posponer guarda la sesión, la reprograma y publica AlarmSnoozed; al volver a sonar sigue la cuenta', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30)));
      world.clock.advance(const Duration(minutes: 13));
      world.scheduler.fire(alarm.id);
      await world.handleRang(alarm.id);

      final AlarmSession? snoozed = await world.snooze();

      expect(snoozed!.snoozesUsed, 1);
      expect(await world.scheduler.watchRinging().first, isEmpty);
      expect(world.events.publishedOf<AlarmSnoozed>().single.until, snoozed.snoozedUntil);

      world.clock.advance(const Duration(minutes: 10));
      world.scheduler.fireDue();
      await world.handleRang(alarm.id);
      final AlarmSession again = (await world.repository.getSession())!;
      expect(again.isSnoozed, isFalse);
      expect(again.snoozesUsed, 1);
    });

    test('no pospone sin sesión, si ya está pospuesta o si no quedan', () async {
      expect(await world.snooze(), isNull);

      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30), maxSnoozes: 1));
      await world.handleRang(alarm.id);
      expect(await world.snooze(), isNotNull);
      expect(await world.snooze(), isNull);

      await world.handleRang(alarm.id);
      expect(await world.snooze(), isNull);
    });

    test('no pospone si la alarma de la sesión ya no existe', () async {
      await world.repository.saveSession(AlarmSession(alarmId: 'borrada', startedAt: t0));

      expect(await world.snooze(), isNull);
    });

    test('apagar una de una sola vez la desactiva y cierra la sesión', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30)));
      world.clock.advance(const Duration(minutes: 13));
      world.scheduler.fire(alarm.id);
      await world.handleRang(alarm.id);

      await world.dismiss();

      expect(await world.repository.getSession(), isNull);
      expect((await world.repository.getAlarm(alarm.id))!.enabled, isFalse);
      expect(await world.scheduler.watchRinging().first, isEmpty);
      expect(await world.scheduler.scheduled(), isEmpty);
      expect(world.events.publishedOf<AlarmDismissed>().single.alarmId, alarm.id);
    });

    test('apagar una que se repite programa la próxima', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30), repeat: Weekday.everyDay));
      world.clock.advance(const Duration(minutes: 13));
      world.scheduler.fire(alarm.id);
      await world.handleRang(alarm.id);

      await world.dismiss();

      expect((await world.repository.getAlarm(alarm.id))!.enabled, isTrue);
      expect((await world.scheduler.scheduled()).single.at, local(19, 23, 30));
    });

    test('apagar sin sesión no hace nada; con la alarma borrada solo cierra la sesión', () async {
      await world.dismiss();
      expect(world.events.published, isEmpty);

      await world.repository.saveSession(AlarmSession(alarmId: 'borrada', startedAt: t0));
      await world.dismiss();
      expect(await world.repository.getSession(), isNull);
    });

    test('WatchRingingAlarm da la alarma con su sesión, o null', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30)));
      final WatchRingingAlarm watch = WatchRingingAlarm(world.repository);
      expect(await watch().first, isNull);

      await world.handleRang(alarm.id);
      final RingingAlarm? ringing = await watch().first;
      expect(ringing!.alarm, await world.repository.getAlarm(alarm.id));

      await world.repository.saveSession(AlarmSession(alarmId: 'borrada', startedAt: t0));
      expect(await watch().first, isNull);
    });

    test('ListenToRinging pasa cada alarma que suena a HandleAlarmRang', () async {
      final Alarm alarm = await world.create(AlarmDraft(time: AlarmTime(23, 30)));
      final StreamSubscription<void> subscription = ListenToRinging(world.scheduler, world.handleRang)().listen(null);

      world.scheduler.fire(alarm.id);
      await pumpEventQueue();

      expect(await world.repository.getSession(), isNotNull);
      await subscription.cancel();
    });
  });

  group('NextAlarmService', () {
    nextAlarmQueryContract(
      'NextAlarmService',
      create: () async {
        final _World contractWorld = _World();
        final NextAlarmService service = NextAlarmService(
          repository: contractWorld.repository,
          scheduler: contractWorld.scheduler,
          clock: contractWorld.clock,
          wallClock: bogota,
        );
        await service.start();
        _contractWorlds[service] = contractWorld;
        return service;
      },
      setNext: (NextAlarmQuery query, NextAlarm? next) async {
        final _World contractWorld = _contractWorlds[query]!;
        for (final Alarm alarm in await contractWorld.repository.getAlarms()) {
          await contractWorld.repository.deleteAlarm(alarm.id);
        }
        if (next != null) {
          final DateTime local = bogota.toLocal(next.ringsAt);
          final Alarm alarm = Alarm(
            id: next.alarmId,
            time: AlarmTime(local.hour, local.minute),
            label: next.label,
            soundId: 'sunrise',
          );
          await contractWorld.repository.saveAlarm(alarm);
          if (next.isSnoozed) {
            await contractWorld.repository.saveSession(
              AlarmSession(alarmId: alarm.id, startedAt: t0, snoozesUsed: 1, snoozedUntil: next.ringsAt),
            );
          } else {
            await contractWorld.repository.saveSession(null);
          }
        }
        await pumpEventQueue();
      },
      setCanRing: (NextAlarmQuery query, {required bool canRing}) async {
        _contractWorlds[query]!.scheduler.currentPermissions =
            AlarmPermissions(exactAlarms: canRing, notifications: true, fullScreen: true);
        await (query as NextAlarmService).refresh();
      },
      dispose: (NextAlarmQuery query) async {
        await (query as NextAlarmService).dispose();
        await _contractWorlds.remove(query)!.dispose();
      },
    );

    test('la pospuesta va primero aunque otra suene antes; la que suena no cuenta', () async {
      final NextAlarmService service = NextAlarmService(
        repository: world.repository,
        scheduler: world.scheduler,
        clock: world.clock,
        wallClock: bogota,
      );
      final Alarm work = await world.create(AlarmDraft(time: AlarmTime(6, 30), label: 'Trabajo'));
      final Alarm nap = await world.create(AlarmDraft(time: AlarmTime(23, 30), label: 'Siesta'));
      await service.start();
      expect((await service.watchNextAlarm().first)!.alarmId, nap.id);
      expect(service.current!.alarmId, nap.id);
      expect(service.canRing, isTrue);

      await world.handleRang(nap.id);
      await pumpEventQueue();
      expect((await service.watchNextAlarm().first)!.alarmId, work.id);

      world.clock.advance(const Duration(minutes: 13));
      await world.snooze();
      await pumpEventQueue();
      final NextAlarm next = (await service.watchNextAlarm().first)!;
      expect(next.alarmId, nap.id);
      expect(next.isSnoozed, isTrue);

      await service.dispose();
    });

    test('una sesión de una alarma borrada no cuenta como pospuesta', () async {
      final NextAlarmService service = NextAlarmService(
        repository: world.repository,
        scheduler: world.scheduler,
        clock: world.clock,
        wallClock: bogota,
      );
      await world.repository.saveSession(
        AlarmSession(alarmId: 'borrada', startedAt: t0, snoozedUntil: t0.add(const Duration(minutes: 5))),
      );
      await service.start();

      expect(await service.watchNextAlarm().first, isNull);
      await service.dispose();
    });
  });

  test('InMemoryNextAlarmQuery sigue disponible para quien consume la alarma', () async {
    final InMemoryNextAlarmQuery query = InMemoryNextAlarmQuery();
    expect(await query.watchCanRing().first, isTrue);
    await query.close();
  });
}

final Map<NextAlarmQuery, _World> _contractWorlds = <NextAlarmQuery, _World>{};
