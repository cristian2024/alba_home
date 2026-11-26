import 'package:async/async.dart';
import 'package:test/test.dart';

import '../alarm.dart';
import '../alarm_repository.dart';
import '../alarm_session.dart';
import '../alarm_time.dart';
import '../weekday.dart';

/// Tests de contrato de [AlarmRepository]. Toda implementación debe pasarlos.
///
/// [create] devuelve un repositorio vacío para cada test; [dispose], si se
/// da, lo libera al terminar.
void alarmRepositoryContract(
  String implementation, {
  required Future<AlarmRepository> Function() create,
  Future<void> Function(AlarmRepository repository)? dispose,
}) {
  group('AlarmRepository ($implementation)', () {
    late AlarmRepository repository;

    final Alarm work = Alarm(
      id: '6f1c9a52-6d0e-4b8e-9c55-0f8f4a1e2b31',
      time: AlarmTime(6, 30),
      label: 'Trabajo',
      soundId: 'sunrise',
      repeat: Weekday.weekdays,
      rise: const Duration(seconds: 90),
      snooze: const Duration(minutes: 5),
      maxSnoozes: 2,
      vibrate: false,
    );
    final Alarm nap = Alarm(
      id: '0c1e7f6e-38a4-4c2a-8c6e-5b1d2f0a9e77',
      time: AlarmTime(16, 30),
      label: '',
      soundId: 'bell',
      onceAt: DateTime.utc(2026, 11, 18, 21, 30),
    );
    final Alarm early = Alarm(
      id: 'b8d2a5e4-1f3c-4a7b-9e0d-2c6f8a1b3d55',
      time: AlarmTime(5, 0),
      label: 'Temprano',
      soundId: 'bell',
      enabled: false,
    );
    final AlarmSession session = AlarmSession(
      alarmId: work.id,
      startedAt: DateTime.utc(2026, 11, 18, 11, 30),
      snoozesUsed: 1,
      snoozedUntil: DateTime.utc(2026, 11, 18, 11, 40),
    );

    setUp(() async => repository = await create());
    tearDown(() async => dispose?.call(repository));

    test('empieza vacío', () async {
      expect(await repository.getAlarms(), isEmpty);
      expect(await repository.getSession(), isNull);
      expect(await repository.watchAlarms().first, isEmpty);
      expect(await repository.watchSession().first, isNull);
    });

    test('guarda las alarmas con todos sus datos y las ordena por hora', () async {
      await repository.saveAlarm(nap);
      await repository.saveAlarm(work);
      await repository.saveAlarm(early);

      expect(await repository.getAlarms(), <Alarm>[early, work, nap]);
      expect(await repository.getAlarm(work.id), work);
      expect(await repository.getAlarm('desconocida'), isNull);
    });

    test('guardar con el mismo id sustituye', () async {
      await repository.saveAlarm(work);
      final Alarm moved = work.copyWith(time: AlarmTime(7, 0), repeat: Weekday.everyDay, enabled: false);

      await repository.saveAlarm(moved);

      expect(await repository.getAlarms(), <Alarm>[moved]);
    });

    test('borrar quita la alarma y su sesión, y no falla con un id desconocido', () async {
      await repository.saveAlarm(work);
      await repository.saveAlarm(nap);
      await repository.saveSession(session);

      await repository.deleteAlarm(work.id);
      await repository.deleteAlarm('desconocida');

      expect(await repository.getAlarms(), <Alarm>[nap]);
      expect(await repository.getSession(), isNull);
    });

    test('borrar otra alarma no toca la sesión', () async {
      await repository.saveAlarm(work);
      await repository.saveAlarm(nap);
      await repository.saveSession(session);

      await repository.deleteAlarm(nap.id);

      expect(await repository.getSession(), session);
    });

    test('guarda y borra la sesión', () async {
      await repository.saveSession(session);
      expect(await repository.getSession(), session);

      final AlarmSession ringing = session.ringAgain();
      await repository.saveSession(ringing);
      expect(await repository.getSession(), ringing);

      await repository.saveSession(null);
      expect(await repository.getSession(), isNull);
    });

    test('watchAlarms y watchSession emiten cada cambio', () async {
      final StreamQueue<List<Alarm>> alarms = StreamQueue<List<Alarm>>(repository.watchAlarms());
      final StreamQueue<AlarmSession?> sessions = StreamQueue<AlarmSession?>(repository.watchSession());
      expect(await alarms.next, isEmpty);
      expect(await sessions.next, isNull);

      await repository.saveAlarm(work);
      await expectLater(alarms, emitsThrough(<Alarm>[work]));
      await repository.saveSession(session);
      await expectLater(sessions, emitsThrough(session));
      await repository.deleteAlarm(work.id);
      await expectLater(alarms, emitsThrough(isEmpty));
      await expectLater(sessions, emitsThrough(isNull));

      await alarms.cancel();
      await sessions.cancel();
    });
  });
}
