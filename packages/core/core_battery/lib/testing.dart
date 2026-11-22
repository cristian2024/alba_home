/// Dobles de prueba y tests de contrato de `core_battery`.
library;

import 'dart:async';

import 'core_battery.dart';

export 'src/testing/battery_reader_contract.dart';

/// [BatteryReader] en memoria: la lectura la fija el test con [set]. Cumple
/// `batteryReaderContract`.
class InMemoryBatteryReader implements BatteryReader {
  InMemoryBatteryReader({
    BatteryStatus initial = const BatteryStatus(level: 100, state: BatteryChargeState.full, temperatureCelsius: 30),
  }) : _status = initial;

  final StreamController<BatteryStatus> _changes = StreamController<BatteryStatus>.broadcast();
  BatteryStatus _status;

  /// Cambia la lectura. Si es igual a la actual, no emite.
  void set(BatteryStatus status) {
    if (status == _status) {
      return;
    }
    _status = status;
    _changes.add(status);
  }

  @override
  Future<BatteryStatus> current() async => _status;

  @override
  Stream<BatteryStatus> watchStatus() => _replayCurrent(() => _status, _changes.stream);

  /// Cierra el stream de lecturas.
  Future<void> close() => _changes.close();
}

/// Emite [current] al suscribirse y después [changes], suscribiéndose a
/// [changes] en el mismo momento para no perder nada.
Stream<T> _replayCurrent<T>(T Function() current, Stream<T> changes) {
  StreamSubscription<T>? subscription;
  late final StreamController<T> controller;
  controller = StreamController<T>(
    onListen: () {
      controller.add(current());
      subscription = changes.listen(controller.add, onDone: controller.close);
    },
    // No devuelve el futuro de cancel(): `first` lo esperaría y, con el
    // reloj simulado de testWidgets, no se completa.
    onCancel: () {
      unawaited(subscription?.cancel());
    },
  );
  return controller.stream;
}
