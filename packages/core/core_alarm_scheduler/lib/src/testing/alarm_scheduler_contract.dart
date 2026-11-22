import 'package:async/async.dart';
import 'package:core_utils/core_utils.dart';
import 'package:test/test.dart';

import '../alarm_permissions.dart';
import '../alarm_scheduler.dart';
import '../scheduled_alarm.dart';

/// Tests de contrato de [AlarmScheduler]. Toda implementación debe pasarlos.
///
/// - [create] devuelve un programador vacío para cada test, con el reloj que
///   le pasa el contrato (una implementación sobre el sistema puede usar la
///   hora real: el contrato usa `SystemClock`).
/// - [trigger], si se da, hace sonar ya la alarma programada [id], como si
///   hubiera llegado su hora. Sin él se omiten los tests de alarmas sonando.
/// - [dispose], si se da, libera el programador al terminar cada test.
///
/// ```dart
/// alarmSchedulerContract(
///   'InMemoryAlarmScheduler',
///   create: (Clock clock) => InMemoryAlarmScheduler(clock: clock),
///   trigger: (AlarmScheduler s, String id) async => (s as InMemoryAlarmScheduler).fire(id),
/// );
/// ```
void alarmSchedulerContract(
  String implementation, {
  required AlarmScheduler Function(Clock clock) create,
  Future<void> Function(AlarmScheduler scheduler, String id)? trigger,
  Future<void> Function(AlarmScheduler scheduler)? dispose,
}) {
  group('AlarmScheduler ($implementation)', () {
    const Clock clock = SystemClock();
    late AlarmScheduler scheduler;

    ScheduledAlarm alarm(String id, Duration fromNow) => ScheduledAlarm(
          id: id,
          at: clock.nowUtc().add(fromNow),
          title: 'Alarma $id',
          soundAsset: 'sounds/sunrise.ogg',
          fadeIn: const Duration(minutes: 1),
        );

    setUp(() => scheduler = create(clock));
    tearDown(() async {
      for (final ScheduledAlarm pending in await scheduler.scheduled()) {
        await scheduler.cancel(pending.id);
      }
      await dispose?.call(scheduler);
    });

    test('empieza sin alarmas', () async {
      expect(await scheduler.scheduled(), isEmpty);
      expect(await scheduler.watchRinging().first, isEmpty);
    });

    test('schedule guarda la alarma con todos sus datos', () async {
      final ScheduledAlarm wakeUp = ScheduledAlarm(
        id: 'work',
        at: clock.nowUtc().add(const Duration(hours: 8)),
        title: 'Trabajo',
        body: 'Lun a vie',
        soundAsset: 'sounds/sunrise.ogg',
        volume: 0.7,
        fadeIn: const Duration(minutes: 1),
        vibrate: false,
        loop: false,
      );

      await scheduler.schedule(wakeUp);

      expect(await scheduler.scheduled(), <ScheduledAlarm>[wakeUp]);
    });

    test('scheduled ordena de la más próxima a la más lejana', () async {
      final ScheduledAlarm late = alarm('late', const Duration(hours: 9));
      final ScheduledAlarm soon = alarm('soon', const Duration(minutes: 10));

      await scheduler.schedule(late);
      await scheduler.schedule(soon);

      expect(await scheduler.scheduled(), <ScheduledAlarm>[soon, late]);
    });

    test('programar otra con el mismo id la sustituye', () async {
      await scheduler.schedule(alarm('work', const Duration(hours: 8)));
      final ScheduledAlarm moved = alarm('work', const Duration(hours: 9));

      await scheduler.schedule(moved);

      expect(await scheduler.scheduled(), <ScheduledAlarm>[moved]);
    });

    test('cancel quita la alarma y no falla con un id desconocido', () async {
      await scheduler.schedule(alarm('a', const Duration(hours: 1)));
      final ScheduledAlarm keep = alarm('b', const Duration(hours: 2));
      await scheduler.schedule(keep);

      await scheduler.cancel('a');
      await scheduler.cancel('desconocida');

      expect(await scheduler.scheduled(), <ScheduledAlarm>[keep]);
    });

    test('stop de una alarma que no suena no hace nada', () async {
      final ScheduledAlarm pending = alarm('a', const Duration(hours: 1));
      await scheduler.schedule(pending);

      await scheduler.stop('a');
      await scheduler.stop('desconocida');

      expect(await scheduler.scheduled(), <ScheduledAlarm>[pending]);
    });

    test('rechaza horas pasadas o fuera de UTC, volúmenes fuera de rango y fundidos negativos', () async {
      final DateTime future = clock.nowUtc().add(const Duration(hours: 1));
      final ScheduledAlarm valid = alarm('a', const Duration(hours: 1));

      await expectLater(scheduler.schedule(valid.copyWith(at: clock.nowUtc().subtract(const Duration(minutes: 1)))),
          throwsArgumentError);
      await expectLater(scheduler.schedule(valid.copyWith(at: future.toLocal())), throwsArgumentError);
      await expectLater(
        scheduler.schedule(ScheduledAlarm(id: 'a', at: future, title: 'a', soundAsset: 's.ogg', volume: 1.2)),
        throwsArgumentError,
      );
      await expectLater(
        scheduler.schedule(
          ScheduledAlarm(id: 'a', at: future, title: 'a', soundAsset: 's.ogg', fadeIn: const Duration(seconds: -1)),
        ),
        throwsArgumentError,
      );
      expect(await scheduler.scheduled(), isEmpty);
    });

    test('permissions y requestPermissions devuelven un estado', () async {
      expect(await scheduler.permissions(), isA<AlarmPermissions>());
      expect(await scheduler.requestPermissions(), isA<AlarmPermissions>());
    });

    if (trigger != null) {
      group('sonando', () {
        test('al sonar sale de scheduled y aparece en watchRinging', () async {
          final ScheduledAlarm wakeUp = alarm('work', const Duration(hours: 8));
          final ScheduledAlarm other = alarm('nap', const Duration(hours: 9));
          await scheduler.schedule(wakeUp);
          await scheduler.schedule(other);
          final StreamQueue<List<ScheduledAlarm>> ringing =
              StreamQueue<List<ScheduledAlarm>>(scheduler.watchRinging());
          expect(await ringing.next, isEmpty);

          await trigger(scheduler, 'work');

          await expectLater(ringing, emitsThrough(<ScheduledAlarm>[wakeUp]));
          expect(await scheduler.scheduled(), <ScheduledAlarm>[other]);
          await ringing.cancel();
        });

        test('varias sonando a la vez, en el orden en que empezaron', () async {
          final ScheduledAlarm pasta = alarm('pasta', const Duration(minutes: 10));
          final ScheduledAlarm rice = alarm('rice', const Duration(minutes: 5));
          await scheduler.schedule(pasta);
          await scheduler.schedule(rice);

          await trigger(scheduler, 'pasta');
          await trigger(scheduler, 'rice');

          expect(await scheduler.watchRinging().first, <ScheduledAlarm>[pasta, rice]);
        });

        test('stop la detiene y no vuelve a scheduled', () async {
          await scheduler.schedule(alarm('work', const Duration(hours: 8)));
          await trigger(scheduler, 'work');

          await scheduler.stop('work');

          expect(await scheduler.watchRinging().first, isEmpty);
          expect(await scheduler.scheduled(), isEmpty);
        });

        test('cancel también detiene una alarma que suena', () async {
          await scheduler.schedule(alarm('work', const Duration(hours: 8)));
          await trigger(scheduler, 'work');

          await scheduler.cancel('work');

          expect(await scheduler.watchRinging().first, isEmpty);
        });

        test('programar el mismo id mientras suena la detiene y la deja pendiente (posponer)', () async {
          await scheduler.schedule(alarm('work', const Duration(hours: 8)));
          await trigger(scheduler, 'work');
          final ScheduledAlarm snoozed = alarm('work', const Duration(minutes: 10));

          await scheduler.schedule(snoozed);

          expect(await scheduler.watchRinging().first, isEmpty);
          expect(await scheduler.scheduled(), <ScheduledAlarm>[snoozed]);
        });
      });
    }
  });
}
