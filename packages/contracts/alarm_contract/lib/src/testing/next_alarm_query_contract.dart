import 'package:async/async.dart';
import 'package:test/test.dart';

import '../next_alarm.dart';
import '../next_alarm_query.dart';

/// Tests de contrato de [NextAlarmQuery]. Toda implementación debe pasarlos.
///
/// - [create] devuelve una consulta sin alarmas y con permiso.
/// - [setNext] cambia la próxima alarma (`null`: ninguna).
/// - [setCanRing] cambia el permiso.
/// - [dispose], si se da, libera la consulta al terminar.
void nextAlarmQueryContract(
  String implementation, {
  required Future<NextAlarmQuery> Function() create,
  required Future<void> Function(NextAlarmQuery query, NextAlarm? next) setNext,
  required Future<void> Function(NextAlarmQuery query, {required bool canRing}) setCanRing,
  Future<void> Function(NextAlarmQuery query)? dispose,
}) {
  group('NextAlarmQuery ($implementation)', () {
    late NextAlarmQuery query;
    final NextAlarm work = NextAlarm(alarmId: 'work', ringsAt: DateTime.utc(2026, 11, 19, 11, 30), label: 'Trabajo');

    setUp(() async => query = await create());
    tearDown(() async => dispose?.call(query));

    test('sin alarmas emite null y, con permiso, true', () async {
      expect(await query.watchNextAlarm().first, isNull);
      expect(await query.watchCanRing().first, isTrue);
    });

    test('emite la próxima alarma y cada cambio', () async {
      final StreamQueue<NextAlarm?> next = StreamQueue<NextAlarm?>(query.watchNextAlarm());
      expect(await next.next, isNull);

      await setNext(query, work);
      await expectLater(next, emitsThrough(work));
      final NextAlarm snoozed = NextAlarm(
        alarmId: 'work',
        ringsAt: DateTime.utc(2026, 11, 19, 11, 40),
        label: 'Trabajo',
        isSnoozed: true,
      );
      await setNext(query, snoozed);
      await expectLater(next, emitsThrough(snoozed));
      await setNext(query, null);
      await expectLater(next, emitsThrough(isNull));
      await next.cancel();
    });

    test('un suscriptor nuevo recibe el valor actual', () async {
      await setNext(query, work);
      await setCanRing(query, canRing: false);

      expect(await query.watchNextAlarm().first, work);
      expect(await query.watchCanRing().first, isFalse);
    });

    test('emite cada cambio de permiso', () async {
      final StreamQueue<bool> canRing = StreamQueue<bool>(query.watchCanRing());
      expect(await canRing.next, isTrue);

      await setCanRing(query, canRing: false);
      await expectLater(canRing, emitsThrough(isFalse));
      await setCanRing(query, canRing: true);
      await expectLater(canRing, emitsThrough(isTrue));
      await canRing.cancel();
    });
  });
}
