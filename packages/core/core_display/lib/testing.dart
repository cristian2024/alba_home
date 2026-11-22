/// Dobles de prueba y tests de contrato de `core_display`.
library;

import 'core_display.dart';

export 'src/testing/display_control_contract.dart';

/// [DisplayControl] en memoria: guarda el estado sin tocar la pantalla.
/// Cumple `displayControlContract`.
class InMemoryDisplayControl implements DisplayControl {
  InMemoryDisplayControl({DisplayState initial = const DisplayState()}) : _state = initial;

  DisplayState _state;

  /// Estado actual, sin esperar.
  DisplayState get state => _state;

  @override
  Future<DisplayState> current() async => _state;

  @override
  Future<void> setKeepScreenOn(bool keepOn) async =>
      _state = DisplayState(keepScreenOn: keepOn, brightness: _state.brightness, immersive: _state.immersive);

  @override
  Future<void> setBrightness(double brightness) async {
    DisplayValidation.brightness(brightness);
    _state = DisplayState(keepScreenOn: _state.keepScreenOn, brightness: brightness, immersive: _state.immersive);
  }

  @override
  Future<void> resetBrightness() async =>
      _state = DisplayState(keepScreenOn: _state.keepScreenOn, immersive: _state.immersive);

  @override
  Future<void> setImmersive(bool immersive) async =>
      _state = DisplayState(keepScreenOn: _state.keepScreenOn, brightness: _state.brightness, immersive: immersive);
}
