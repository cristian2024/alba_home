import 'package:core_battery/core_battery.dart';
import 'package:core_battery/testing.dart';
import 'package:test/test.dart';

void main() {
  batteryReaderContract(
    'InMemoryBatteryReader',
    create: InMemoryBatteryReader.new,
    change: (BatteryReader reader, BatteryStatus status) async => (reader as InMemoryBatteryReader).set(status),
    dispose: (BatteryReader reader) => (reader as InMemoryBatteryReader).close(),
  );

  group('InMemoryBatteryReader', () {
    test('empieza con la lectura inicial', () async {
      const BatteryStatus low = BatteryStatus(level: 9, state: BatteryChargeState.discharging);
      final InMemoryBatteryReader reader = InMemoryBatteryReader(initial: low);

      expect(await reader.current(), low);
      await reader.close();
    });
  });

  group('BatteryStatus', () {
    test('isPluggedIn es cierto con el cargador conectado, cargue o no', () {
      bool plugged(BatteryChargeState state) => BatteryStatus(level: 50, state: state).isPluggedIn;

      expect(plugged(BatteryChargeState.charging), isTrue);
      expect(plugged(BatteryChargeState.full), isTrue);
      expect(plugged(BatteryChargeState.notCharging), isTrue);
      expect(plugged(BatteryChargeState.discharging), isFalse);
      expect(plugged(BatteryChargeState.unknown), isFalse);
    });

    test('se compara por valor', () {
      const BatteryStatus a = BatteryStatus(level: 80, state: BatteryChargeState.charging, temperatureCelsius: 35);

      expect(a, const BatteryStatus(level: 80, state: BatteryChargeState.charging, temperatureCelsius: 35));
      expect(a, isNot(const BatteryStatus(level: 80, state: BatteryChargeState.charging)));
      expect(a.toString(), contains('80'));
    });

    test('rechaza niveles fuera de 0 a 100', () {
      expect(() => BatteryStatus(level: 101, state: BatteryChargeState.full), throwsA(isA<AssertionError>()));
    });
  });
}
