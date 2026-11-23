/// Dobles de prueba y tests de contrato de `alarm_contract`.
library;

import 'dart:async';

import 'alarm_contract.dart';

export 'src/testing/next_alarm_query_contract.dart';

/// [NextAlarmQuery] en memoria: el test fija la próxima alarma y el permiso.
/// Cumple `nextAlarmQueryContract`.
class InMemoryNextAlarmQuery implements NextAlarmQuery {
  InMemoryNextAlarmQuery({NextAlarm? next, bool canRing = true}) : _next = next, _canRing = canRing;

  final StreamController<NextAlarm?> _nextChanges = StreamController<NextAlarm?>.broadcast();
  final StreamController<bool> _canRingChanges = StreamController<bool>.broadcast();
  NextAlarm? _next;
  bool _canRing;

  NextAlarm? get next => _next;

  set next(NextAlarm? value) {
    _next = value;
    _nextChanges.add(value);
  }

  bool get canRing => _canRing;

  set canRing(bool value) {
    _canRing = value;
    _canRingChanges.add(value);
  }

  @override
  Stream<NextAlarm?> watchNextAlarm() => _replayCurrent(() => _next, _nextChanges.stream);

  @override
  Stream<bool> watchCanRing() => _replayCurrent(() => _canRing, _canRingChanges.stream);

  /// Cierra los streams.
  Future<void> close() async {
    await _nextChanges.close();
    await _canRingChanges.close();
  }
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
