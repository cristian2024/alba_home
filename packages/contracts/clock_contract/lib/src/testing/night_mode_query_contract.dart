import 'package:async/async.dart';
import 'package:test/test.dart';

import '../night_mode_query.dart';
import '../night_phase.dart';

/// Tests de contrato de [NightModeQuery]. Toda implementación debe pasarlos.
///
/// - [create] devuelve una consulta de día.
/// - [setPhase] lleva la consulta a una fase.
/// - [dispose], si se da, la libera al terminar.
void nightModeQueryContract(
  String implementation, {
  required Future<NightModeQuery> Function() create,
  required Future<void> Function(NightModeQuery query, NightPhase phase) setPhase,
  Future<void> Function(NightModeQuery query)? dispose,
}) {
  group('NightModeQuery ($implementation)', () {
    late NightModeQuery query;
    final NightPhase dusk = NightPhase(
      stage: NightStage.dusk,
      darkness: 0.5,
      nightStartsAt: DateTime.utc(2026, 11, 19, 3, 30),
    );

    setUp(() async => query = await create());
    tearDown(() async => dispose?.call(query));

    test('empieza de día', () async {
      expect(await query.watchPhase().first, NightPhase.day);
    });

    test('emite cada cambio de fase', () async {
      final StreamQueue<NightPhase> phases = StreamQueue<NightPhase>(query.watchPhase());
      expect(await phases.next, NightPhase.day);

      await setPhase(query, dusk);
      await expectLater(phases, emitsThrough(dusk));
      await setPhase(query, NightPhase.night);
      await expectLater(phases, emitsThrough(NightPhase.night));
      await phases.cancel();
    });

    test('un suscriptor nuevo recibe la fase actual', () async {
      await setPhase(query, NightPhase.night);

      expect(await query.watchPhase().first, NightPhase.night);
    });
  });
}
