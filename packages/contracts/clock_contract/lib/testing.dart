/// Dobles de prueba y tests de contrato de `clock_contract`.
library;

import 'dart:async';

import 'clock_contract.dart';

export 'src/testing/night_mode_query_contract.dart';

/// [NightModeQuery] en memoria: el test fija la fase. Cumple
/// `nightModeQueryContract`.
class InMemoryNightModeQuery implements NightModeQuery {
  InMemoryNightModeQuery({NightPhase phase = NightPhase.day}) : _phase = phase;

  final StreamController<NightPhase> _changes = StreamController<NightPhase>.broadcast();
  NightPhase _phase;

  NightPhase get phase => _phase;

  set phase(NightPhase value) {
    _phase = value;
    _changes.add(value);
  }

  @override
  Stream<NightPhase> watchPhase() {
    StreamSubscription<NightPhase>? subscription;
    late final StreamController<NightPhase> controller;
    controller = StreamController<NightPhase>(
      onListen: () {
        controller.add(_phase);
        subscription = _changes.stream.listen(controller.add, onDone: controller.close);
      },
      // No devuelve el futuro de cancel(): `first` lo esperaría y, con el
      // reloj simulado de testWidgets, no se completa.
      onCancel: () {
        unawaited(subscription?.cancel());
      },
    );
    return controller.stream;
  }

  /// Cierra el stream.
  Future<void> close() => _changes.close();
}
