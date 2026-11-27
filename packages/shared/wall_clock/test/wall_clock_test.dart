import 'package:test/test.dart';
import 'package:wall_clock/wall_clock.dart';

void main() {
  test('FixedOffsetWallClock convierte en los dos sentidos y normaliza fechas', () {
    const WallClock bogota = FixedOffsetWallClock(Duration(hours: -5));
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
}
