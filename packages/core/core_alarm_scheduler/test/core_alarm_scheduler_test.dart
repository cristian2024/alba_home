import 'package:async/async.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_alarm_scheduler/testing.dart';
import 'package:core_utils/core_utils.dart';
import 'package:test/test.dart';

void main() {
  alarmSchedulerContract(
    'InMemoryAlarmScheduler',
    create: (Clock clock) => InMemoryAlarmScheduler(clock: clock),
    trigger: (AlarmScheduler scheduler, String id) async => (scheduler as InMemoryAlarmScheduler).fire(id),
    dispose: (AlarmScheduler scheduler) => (scheduler as InMemoryAlarmScheduler).close(),
  );

  group('InMemoryAlarmScheduler', () {
    final DateTime t0 = DateTime.utc(2026, 11, 18, 22);
    late FixedClock clock;
    late InMemoryAlarmScheduler scheduler;

    ScheduledAlarm at(String id, DateTime when) =>
        ScheduledAlarm(id: id, at: when, title: id, soundAsset: 'sounds/sunrise.ogg');

    setUp(() {
      clock = FixedClock(t0);
      scheduler = InMemoryAlarmScheduler(clock: clock);
    });
    tearDown(() => scheduler.close());

    test('fireDue hace sonar, por hora, las alarmas que ya tocan', () async {
      final ScheduledAlarm first = at('first', t0.add(const Duration(hours: 8)));
      final ScheduledAlarm second = at('second', t0.add(const Duration(hours: 8, minutes: 30)));
      final ScheduledAlarm later = at('later', t0.add(const Duration(hours: 10)));
      await scheduler.schedule(second);
      await scheduler.schedule(later);
      await scheduler.schedule(first);
      final StreamQueue<List<ScheduledAlarm>> ringing = StreamQueue<List<ScheduledAlarm>>(scheduler.watchRinging());
      expect(await ringing.next, isEmpty);

      clock.advance(const Duration(hours: 9));
      scheduler.fireDue();

      await expectLater(ringing, emitsThrough(<ScheduledAlarm>[first, second]));
      expect(await scheduler.scheduled(), <ScheduledAlarm>[later]);
      await ringing.cancel();
    });

    test('fire de un id desconocido no hace nada', () async {
      scheduler.fire('desconocida');

      expect(await scheduler.watchRinging().first, isEmpty);
    });

    test('los permisos se pueden cambiar y pedir', () async {
      scheduler.currentPermissions =
          const AlarmPermissions(exactAlarms: false, notifications: true, fullScreen: true);
      expect((await scheduler.permissions()).canRing, isFalse);

      expect((await scheduler.requestPermissions()).canRing, isFalse);
      scheduler.permissionsAfterRequest = AlarmPermissions.granted;
      expect(await scheduler.requestPermissions(), AlarmPermissions.granted);
      expect(scheduler.permissionRequests, 2);
    });
  });

  group('modelos', () {
    final ScheduledAlarm alarm = ScheduledAlarm(
      id: 'work',
      at: DateTime.utc(2026, 11, 19, 6, 30),
      title: 'Trabajo',
      soundAsset: 'sounds/sunrise.ogg',
    );

    test('ScheduledAlarm se compara por valor y copyWith cambia la hora', () {
      final DateTime later = DateTime.utc(2026, 11, 19, 6, 40);

      expect(alarm.copyWith(), alarm);
      expect(alarm.copyWith(at: later).at, later);
      expect(alarm.copyWith(at: later), isNot(alarm));
      expect(alarm.toString(), contains('Trabajo'));
    });

    test('AlarmPermissions resume lo concedido', () {
      const AlarmPermissions noFullScreen = AlarmPermissions(exactAlarms: true, notifications: true, fullScreen: false);

      expect(AlarmPermissions.granted.allGranted, isTrue);
      expect(noFullScreen.canRing, isTrue);
      expect(noFullScreen.allGranted, isFalse);
      expect(noFullScreen.toString(), contains('false'));
    });

    test('AlarmValidation rechaza un volumen NaN', () {
      expect(
        () => AlarmValidation.check(
          ScheduledAlarm(id: 'a', at: DateTime.utc(2027), title: 'a', soundAsset: 's.ogg', volume: double.nan),
          DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
    });
  });
}
