import 'package:test/test.dart';

import '../display_control.dart';
import '../display_state.dart';

/// Tests de contrato de [DisplayControl]. Toda implementación debe pasarlos.
///
/// [create] devuelve un control nuevo para cada test; el contrato deja la
/// pantalla como estaba al terminar (sin mantenerla encendida, con el brillo
/// del sistema y sin modo inmersivo).
///
/// ```dart
/// displayControlContract('InMemoryDisplayControl', create: InMemoryDisplayControl.new);
/// ```
void displayControlContract(String implementation, {required DisplayControl Function() create}) {
  group('DisplayControl ($implementation)', () {
    late DisplayControl display;

    setUp(() => display = create());
    tearDown(() async {
      await display.setKeepScreenOn(false);
      await display.resetBrightness();
      await display.setImmersive(false);
    });

    test('setKeepScreenOn se refleja en current', () async {
      await display.setKeepScreenOn(true);
      expect((await display.current()).keepScreenOn, isTrue);

      await display.setKeepScreenOn(false);
      expect((await display.current()).keepScreenOn, isFalse);
    });

    test('setBrightness fija el brillo y resetBrightness vuelve al del sistema', () async {
      await display.setBrightness(0.05);
      expect((await display.current()).brightness, closeTo(0.05, 0.01));

      await display.setBrightness(1);
      expect((await display.current()).brightness, closeTo(1, 0.01));

      await display.resetBrightness();
      expect((await display.current()).brightness, isNull);
    });

    test('setBrightness rechaza valores fuera de 0 a 1', () async {
      await expectLater(display.setBrightness(1.1), throwsArgumentError);
      await expectLater(display.setBrightness(-0.1), throwsArgumentError);
      await expectLater(display.setBrightness(double.nan), throwsArgumentError);
      expect((await display.current()).brightness, isNull);
    });

    test('setImmersive se refleja en current', () async {
      await display.setImmersive(true);
      expect((await display.current()).immersive, isTrue);

      await display.setImmersive(false);
      expect((await display.current()).immersive, isFalse);
    });

    test('cada ajuste deja los demás como estaban', () async {
      await display.setKeepScreenOn(true);
      await display.setBrightness(0.5);
      await display.setImmersive(true);

      expect(await display.current(), const DisplayState(keepScreenOn: true, brightness: 0.5, immersive: true));
    });
  });
}
