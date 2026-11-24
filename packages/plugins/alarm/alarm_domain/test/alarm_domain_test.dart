import 'package:alarm_domain/alarm_domain.dart';
import 'package:alarm_domain/testing.dart';
import 'package:test/test.dart';

/// Colombia, UTC−5 todo el año.
const WallClock bogota = FixedOffsetWallClock(Duration(hours: -5));

/// Hora local de Bogotá como instante UTC.
DateTime local(int year, int month, int day, int hour, [int minute = 0]) =>
    bogota.localToUtc(year, month, day, hour, minute);

Alarm alarmAt(int hour, int minute, {Set<Weekday> repeat = const <Weekday>{}, bool enabled = true}) => Alarm(
      id: 'a-$hour-$minute',
      time: AlarmTime(hour, minute),
      label: 'Trabajo',
      soundId: 'sunrise',
      repeat: repeat,
      enabled: enabled,
    );

void main() {
  alarmRepositoryContract(
    'InMemoryAlarmRepository',
    create: () async => InMemoryAlarmRepository(),
    dispose: (AlarmRepository repository) => (repository as InMemoryAlarmRepository).close(),
  );

  group('Weekday', () {
    test('of usa el día de la semana de la fecha', () {
      expect(Weekday.of(DateTime.utc(2026, 11, 16)), Weekday.monday);
      expect(Weekday.of(DateTime.utc(2026, 11, 22)), Weekday.sunday);
    });

    test('conjuntos de las fichas de 03.4', () {
      expect(Weekday.weekdays, hasLength(5));
      expect(Weekday.weekend, <Weekday>{Weekday.saturday, Weekday.sunday});
      expect(Weekday.everyDay, Weekday.values.toSet());
    });
  });

  group('AlarmTime', () {
    test('valida la hora y el minuto', () {
      expect(() => AlarmTime(24, 0), throwsArgumentError);
      expect(() => AlarmTime(-1, 0), throwsArgumentError);
      expect(() => AlarmTime(6, 60), throwsArgumentError);
      expect(() => AlarmTime(6, -1), throwsArgumentError);
    });

    test('se compara por valor y por minutos del día', () {
      expect(AlarmTime(6, 30), AlarmTime(6, 30));
      expect(AlarmTime(6, 30).minutesOfDay, 390);
      expect(AlarmTime(6, 30).compareTo(AlarmTime(16, 30)), isNegative);
      expect(AlarmTime(6, 5).toString(), '06:05');
    });
  });

  group('Alarm', () {
    test('valores por defecto de 03.3: sube en 1 min, pospone 10 min hasta 3 veces', () {
      final Alarm alarm = alarmAt(6, 30);

      expect(alarm.rise, const Duration(minutes: 1));
      expect(alarm.snooze, const Duration(minutes: 10));
      expect(alarm.maxSnoozes, 3);
      expect(alarm.vibrate, isTrue);
      expect(alarm.enabled, isTrue);
      expect(alarm.isRepeating, isFalse);
    });

    test('copyWith cambia solo lo pedido', () {
      final Alarm alarm = alarmAt(6, 30);
      final Alarm changed = alarm.copyWith(
        time: AlarmTime(7, 0),
        label: 'Gimnasio',
        repeat: Weekday.weekend,
        enabled: false,
        soundId: 'bell',
        rise: Duration.zero,
        snooze: const Duration(minutes: 5),
        maxSnoozes: 1,
        vibrate: false,
      );

      expect(alarm.copyWith(), alarm);
      expect(changed.id, alarm.id);
      expect(changed.time, AlarmTime(7, 0));
      expect(changed.label, 'Gimnasio');
      expect(changed.isRepeating, isTrue);
      expect(changed.enabled, isFalse);
      expect(changed.soundId, 'bell');
      expect(changed.rise, Duration.zero);
      expect(changed.snooze, const Duration(minutes: 5));
      expect(changed.maxSnoozes, 1);
      expect(changed.vibrate, isFalse);
      expect(changed.toString(), contains('Gimnasio'));
    });

    test('armedFor guarda el instante en UTC; cambiar hora, días o activación lo borra', () {
      final DateTime at = DateTime.utc(2026, 11, 19, 11, 30);
      final Alarm armed = alarmAt(6, 30).armedFor(at.toLocal());

      expect(armed.onceAt, at);
      expect(armed.onceAt!.isUtc, isTrue);
      expect(armed.copyWith(label: 'Otra', soundId: 'bell').onceAt, at);
      expect(armed.copyWith(time: AlarmTime(6, 30), repeat: <Weekday>{}, enabled: true).onceAt, at);
      expect(armed.copyWith(time: AlarmTime(7, 0)).onceAt, isNull);
      expect(armed.copyWith(repeat: Weekday.weekend).onceAt, isNull);
      expect(armed.copyWith(enabled: false).onceAt, isNull);
      expect(armed, isNot(alarmAt(6, 30)));
    });
  });

  group('WallClock', () {
    test('FixedOffsetWallClock convierte en los dos sentidos', () {
      final DateTime utc = DateTime.utc(2026, 11, 18, 11, 30);

      expect(bogota.toLocal(utc).hour, 6);
      expect(bogota.localToUtc(2026, 11, 18, 6, 30), utc);
      expect(bogota.localToUtc(2026, 11, 31, 6, 30), DateTime.utc(2026, 12, 1, 11, 30));
    });

    test('SystemWallClock usa la zona del sistema', () {
      final DateTime utc = DateTime.utc(2026, 11, 18, 11, 30);
      const WallClock system = SystemWallClock();

      expect(system.toLocal(utc), utc.toLocal());
      final DateTime local = utc.toLocal();
      expect(system.localToUtc(local.year, local.month, local.day, local.hour, local.minute), utc);
    });
  });

  group('NextRing.after', () {
    // Miércoles 18 de noviembre de 2026, 23:17 en Bogotá (como en 03.1: suena en 7 h 13 min).
    final DateTime now = local(2026, 11, 18, 23, 17);

    test('una alarma desactivada no suena', () {
      expect(NextRing.after(alarmAt(6, 30, enabled: false), now, bogota), isNull);
    });

    test('sin repetición: hoy si aún no pasó la hora', () {
      expect(NextRing.after(alarmAt(23, 45), now, bogota), local(2026, 11, 18, 23, 45));
    });

    test('sin repetición: mañana si ya pasó (o es justo ahora)', () {
      expect(NextRing.after(alarmAt(6, 30), now, bogota), local(2026, 11, 19, 6, 30));
      expect(NextRing.after(alarmAt(23, 17), now, bogota), local(2026, 11, 19, 23, 17));
    });

    test('de lunes a viernes, el miércoles por la noche: el jueves', () {
      final DateTime? next = NextRing.after(alarmAt(6, 30, repeat: Weekday.weekdays), now, bogota);

      expect(next, local(2026, 11, 19, 6, 30));
      expect(next!.difference(now), const Duration(hours: 7, minutes: 13));
    });

    test('de lunes a viernes, el viernes por la noche: el lunes', () {
      final DateTime friday = local(2026, 11, 20, 22);

      expect(NextRing.after(alarmAt(6, 30, repeat: Weekday.weekdays), friday, bogota), local(2026, 11, 23, 6, 30));
    });

    test('fin de semana, el miércoles: el sábado', () {
      expect(NextRing.after(alarmAt(9, 0, repeat: Weekday.weekend), now, bogota), local(2026, 11, 21, 9));
    });

    test('solo el miércoles y ya pasó la hora: el miércoles siguiente', () {
      final Alarm wednesday = alarmAt(6, 30, repeat: <Weekday>{Weekday.wednesday});

      expect(NextRing.after(wednesday, now, bogota), local(2026, 11, 25, 6, 30));
    });

    test('hoy sí cuenta si es un día marcado y aún no pasó la hora', () {
      final Alarm wednesday = alarmAt(23, 30, repeat: <Weekday>{Weekday.wednesday});

      expect(NextRing.after(wednesday, now, bogota), local(2026, 11, 18, 23, 30));
    });

    test('cruza el cambio de mes y de año', () {
      final DateTime newYearsEve = local(2026, 12, 31, 23);

      expect(NextRing.after(alarmAt(6, 30), newYearsEve, bogota), local(2027, 1, 1, 6, 30));
    });
  });

  group('NextRing.soonest', () {
    final DateTime now = local(2026, 11, 18, 23, 17);

    test('la activa que suena antes, o null', () {
      final Alarm work = alarmAt(6, 30, repeat: Weekday.weekdays);
      final Alarm weekend = alarmAt(9, 0, repeat: Weekday.weekend);
      final Alarm off = alarmAt(5, 0, enabled: false);

      expect(NextRing.soonest(<Alarm>[weekend, off, work], now, bogota), (work, local(2026, 11, 19, 6, 30)));
      expect(NextRing.soonest(<Alarm>[off], now, bogota), isNull);
      expect(NextRing.soonest(<Alarm>[], now, bogota), isNull);
    });

    test('con dos a la misma hora, la primera', () {
      final Alarm first = alarmAt(6, 30);
      final Alarm second = Alarm(id: 'otra', time: AlarmTime(6, 30), label: '', soundId: 'bell');

      expect(NextRing.soonest(<Alarm>[first, second], now, bogota)!.$1, first);
    });
  });

  group('AlarmSession', () {
    final Alarm alarm = alarmAt(6, 30);
    final DateTime rang = DateTime.utc(2026, 11, 19, 11, 30);
    final AlarmSession session = AlarmSession(alarmId: alarm.id, startedAt: rang);

    test('al sonar no está pospuesta y le quedan todas las posposiciones', () {
      expect(session.isSnoozed, isFalse);
      expect(session.snoozesLeft(alarm), 3);
      expect(session.canSnooze(alarm), isTrue);
    });

    test('posponer suma una vez y fija hasta cuándo', () {
      final AlarmSession snoozed = session.snooze(alarm, rang.add(const Duration(minutes: 1)));

      expect(snoozed.isSnoozed, isTrue);
      expect(snoozed.snoozesUsed, 1);
      expect(snoozed.snoozedUntil, rang.add(const Duration(minutes: 11)));
      expect(snoozed.snoozesLeft(alarm), 2);
      expect(snoozed.startedAt, rang);
    });

    test('al volver a sonar conserva las veces usadas', () {
      final AlarmSession again = session.snooze(alarm, rang).ringAgain();

      expect(again.isSnoozed, isFalse);
      expect(again.snoozesUsed, 1);
    });

    test('no deja posponer más del máximo', () {
      AlarmSession current = session;
      for (int i = 0; i < 3; i++) {
        current = current.snooze(alarm, rang).ringAgain();
      }

      expect(current.canSnooze(alarm), isFalse);
      expect(current.snoozesLeft(alarm), 0);
      expect(() => current.snooze(alarm, rang), throwsStateError);
    });

    test('se compara por valor', () {
      expect(AlarmSession(alarmId: alarm.id, startedAt: rang), session);
      expect(session.toString(), contains(alarm.id));
    });
  });

  group('afterDismiss', () {
    test('sin repetición la desactiva; con repetición la deja igual', () {
      expect(afterDismiss(alarmAt(16, 30)).enabled, isFalse);
      final Alarm work = alarmAt(6, 30, repeat: Weekday.weekdays);
      expect(afterDismiss(work), work);
    });
  });
}
