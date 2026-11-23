import 'package:alarm_contract/alarm_contract.dart';
import 'package:alarm_contract/testing.dart';
import 'package:test/test.dart';

void main() {
  nextAlarmQueryContract(
    'InMemoryNextAlarmQuery',
    create: () async => InMemoryNextAlarmQuery(),
    setNext: (NextAlarmQuery query, NextAlarm? next) async => (query as InMemoryNextAlarmQuery).next = next,
    setCanRing: (NextAlarmQuery query, {required bool canRing}) async =>
        (query as InMemoryNextAlarmQuery).canRing = canRing,
    dispose: (NextAlarmQuery query) => (query as InMemoryNextAlarmQuery).close(),
  );

  final DateTime at = DateTime.utc(2026, 11, 19, 11, 30);

  test('InMemoryNextAlarmQuery empieza con lo que se le pasa', () async {
    final NextAlarm work = NextAlarm(alarmId: 'work', ringsAt: at, label: 'Trabajo');
    final InMemoryNextAlarmQuery query = InMemoryNextAlarmQuery(next: work, canRing: false);

    expect(query.next, work);
    expect(query.canRing, isFalse);
    await query.close();
  });

  test('NextAlarm se compara por valor', () {
    final NextAlarm work = NextAlarm(alarmId: 'work', ringsAt: at, label: 'Trabajo');

    expect(work, NextAlarm(alarmId: 'work', ringsAt: at, label: 'Trabajo'));
    expect(work, isNot(NextAlarm(alarmId: 'work', ringsAt: at, label: 'Trabajo', isSnoozed: true)));
    expect(work.toString(), contains('Trabajo'));
  });

  test('los eventos guardan sus datos y la hora en UTC', () {
    final AlarmRang rang = AlarmRang(alarmId: 'work', label: 'Trabajo', rangAt: at.toLocal());
    final AlarmSnoozed snoozed = AlarmSnoozed(alarmId: 'work', until: at.add(const Duration(minutes: 10)), snoozedAt: at);
    final AlarmDismissed dismissed = AlarmDismissed(alarmId: 'work', dismissedAt: at);

    expect(rang.rangAt, at);
    expect(rang.rangAt.isUtc, isTrue);
    expect(rang.label, 'Trabajo');
    expect(snoozed.until, at.add(const Duration(minutes: 10)));
    expect(snoozed.alarmId, 'work');
    expect(dismissed.alarmId, 'work');
    expect(dismissed.emittedAt, at);
  });
}
