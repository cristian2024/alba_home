/// Dobles de prueba y tests de contrato de `clock_domain`.
library;

import 'dart:async';

import 'clock_domain.dart';

export 'src/testing/night_schedule_repository_contract.dart';

/// [NightScheduleRepository] en memoria. Cumple
/// `nightScheduleRepositoryContract`.
class InMemoryNightScheduleRepository implements NightScheduleRepository {
  InMemoryNightScheduleRepository({NightSchedule? schedule}) : _schedule = schedule;

  final StreamController<NightSchedule> _changes = StreamController<NightSchedule>.broadcast();
  NightSchedule? _schedule;

  NightSchedule get _current => _schedule ?? NightSchedule.standard();

  @override
  Future<NightSchedule> get() async => _current;

  @override
  Future<void> save(NightSchedule schedule) async {
    _schedule = schedule;
    _changes.add(schedule);
  }

  @override
  Stream<NightSchedule> watch() {
    StreamSubscription<NightSchedule>? subscription;
    late final StreamController<NightSchedule> controller;
    controller = StreamController<NightSchedule>(
      onListen: () {
        controller.add(_current);
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
