import 'package:core_display/core_display.dart';
import 'package:core_display/testing.dart';
import 'package:test/test.dart';

void main() {
  displayControlContract('InMemoryDisplayControl', create: InMemoryDisplayControl.new);

  group('InMemoryDisplayControl', () {
    test('empieza con el estado inicial y lo expone sin esperar', () async {
      const DisplayState night = DisplayState(keepScreenOn: true, brightness: 0.02, immersive: true);
      final InMemoryDisplayControl display = InMemoryDisplayControl(initial: night);

      expect(display.state, night);
      expect(await display.current(), night);
    });
  });

  group('DisplayState', () {
    test('por defecto usa el sistema y se compara por valor', () {
      expect(const DisplayState(), const DisplayState(keepScreenOn: false, immersive: false));
      expect(const DisplayState().brightness, isNull);
      expect(const DisplayState(brightness: 0.5), isNot(const DisplayState()));
      expect(const DisplayState(brightness: 0.5).toString(), contains('0.5'));
    });
  });
}
