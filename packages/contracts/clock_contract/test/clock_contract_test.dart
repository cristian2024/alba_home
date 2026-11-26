import 'package:clock_contract/clock_contract.dart';
import 'package:clock_contract/testing.dart';
import 'package:test/test.dart';

void main() {
  nightModeQueryContract(
    'InMemoryNightModeQuery',
    create: () async => InMemoryNightModeQuery(),
    setPhase: (NightModeQuery query, NightPhase phase) async => (query as InMemoryNightModeQuery).phase = phase,
    dispose: (NightModeQuery query) => (query as InMemoryNightModeQuery).close(),
  );

  test('InMemoryNightModeQuery empieza con lo que se le pasa', () async {
    final InMemoryNightModeQuery query = InMemoryNightModeQuery(phase: NightPhase.night);

    expect(query.phase, NightPhase.night);
    await query.close();
  });

  test('NightPhase se compara por valor y dice si es de noche', () {
    final DateTime at = DateTime.utc(2026, 11, 19, 3, 30);
    const NightPhase dawn = NightPhase(stage: NightStage.dawn, darkness: 0.25);

    expect(NightPhase.night.isNight, isTrue);
    expect(NightPhase.day.isNight, isFalse);
    expect(dawn.isNight, isFalse);
    expect(
      NightPhase(stage: NightStage.dusk, darkness: 0.5, nightStartsAt: at),
      NightPhase(stage: NightStage.dusk, darkness: 0.5, nightStartsAt: at),
    );
    expect(dawn, isNot(const NightPhase(stage: NightStage.dawn, darkness: 0.5)));
    expect(dawn.toString(), contains('dawn'));
  });
}
