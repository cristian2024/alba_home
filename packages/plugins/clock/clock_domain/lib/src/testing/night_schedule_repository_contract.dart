import 'package:async/async.dart';
import 'package:test/test.dart';

import '../local_time.dart';
import '../night_schedule.dart';
import '../night_schedule_repository.dart';

/// Tests de contrato de [NightScheduleRepository]. Toda implementación debe
/// pasarlos.
///
/// - [create] devuelve un repositorio vacío.
/// - [dispose], si se da, lo libera al terminar.
void nightScheduleRepositoryContract(
  String implementation, {
  required Future<NightScheduleRepository> Function() create,
  Future<void> Function(NightScheduleRepository repository)? dispose,
}) {
  group('NightScheduleRepository ($implementation)', () {
    late NightScheduleRepository repository;
    final NightSchedule late = NightSchedule(start: LocalTime(23, 15), end: LocalTime(7, 0));

    setUp(() async => repository = await create());
    tearDown(() async => dispose?.call(repository));

    test('vacío da el horario de Penpot', () async {
      expect(await repository.get(), NightSchedule.standard());
      expect(await repository.watch().first, NightSchedule.standard());
    });

    test('guarda y sustituye el horario', () async {
      await repository.save(late);
      expect(await repository.get(), late);

      final NightSchedule sameDay = NightSchedule(start: LocalTime(0, 30), end: LocalTime(6, 0));
      await repository.save(sameDay);
      expect(await repository.get(), sameDay);
    });

    test('watch emite el actual y cada horario guardado', () async {
      final StreamQueue<NightSchedule> schedules = StreamQueue<NightSchedule>(repository.watch());
      expect(await schedules.next, NightSchedule.standard());

      await repository.save(late);
      await expectLater(schedules, emitsThrough(late));
      await schedules.cancel();
    });
  });
}
