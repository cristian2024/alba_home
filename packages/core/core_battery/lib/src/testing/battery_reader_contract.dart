import 'package:async/async.dart';
import 'package:test/test.dart';

import '../battery_reader.dart';
import '../battery_status.dart';

/// Tests de contrato de [BatteryReader]. Toda implementación debe pasarlos.
///
/// - [create] devuelve un lector nuevo para cada test.
/// - [change], si se da, cambia la lectura del aparato a [status] (en un
///   doble; en el aparato real no se puede forzar y se omite).
/// - [dispose], si se da, libera el lector al terminar cada test.
///
/// ```dart
/// batteryReaderContract(
///   'InMemoryBatteryReader',
///   create: InMemoryBatteryReader.new,
///   change: (BatteryReader r, BatteryStatus s) async => (r as InMemoryBatteryReader).set(s),
/// );
/// ```
void batteryReaderContract(
  String implementation, {
  required BatteryReader Function() create,
  Future<void> Function(BatteryReader reader, BatteryStatus status)? change,
  Future<void> Function(BatteryReader reader)? dispose,
}) {
  group('BatteryReader ($implementation)', () {
    late BatteryReader reader;

    setUp(() => reader = create());
    tearDown(() async => dispose?.call(reader));

    test('current da un nivel entre 0 y 100 y una temperatura razonable', () async {
      final BatteryStatus status = await reader.current();

      expect(status.level, inInclusiveRange(0, 100));
      final double? temperature = status.temperatureCelsius;
      if (temperature != null) {
        expect(temperature, inInclusiveRange(-40, 100));
      }
    });

    test('watchStatus emite la lectura actual al suscribirse', () async {
      expect(await reader.watchStatus().first, await reader.current());
    });

    if (change != null) {
      test('watchStatus emite cada cambio sin repetir lecturas iguales', () async {
        const BatteryStatus low = BatteryStatus(level: 18, state: BatteryChargeState.discharging, temperatureCelsius: 31);
        const BatteryStatus plugged = BatteryStatus(level: 18, state: BatteryChargeState.charging, temperatureCelsius: 31);
        const BatteryStatus hot = BatteryStatus(level: 19, state: BatteryChargeState.charging, temperatureCelsius: 43);
        final StreamQueue<BatteryStatus> statuses = StreamQueue<BatteryStatus>(reader.watchStatus());
        await statuses.next;

        await change(reader, low);
        await change(reader, low);
        await change(reader, plugged);
        await change(reader, hot);

        await expectLater(statuses, emitsInOrder(<BatteryStatus>[low, plugged, hot]));
        expect(await reader.current(), hot);
        await statuses.cancel();
      });
    }
  });
}
