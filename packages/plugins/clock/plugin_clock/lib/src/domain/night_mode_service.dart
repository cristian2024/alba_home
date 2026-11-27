import 'dart:async';

import 'package:clock_contract/clock_contract.dart';
import 'package:clock_domain/clock_domain.dart';
import 'package:core_utils/core_utils.dart';

/// [NightModeQuery] del reloj: la fase de noche según el horario guardado y
/// la hora actual. Recalcula al cambiar el horario y en cada [refresh] (el
/// plugin lo llama cada pocos segundos, porque el fundido avanza solo).
class NightModeService implements NightModeQuery {
  NightModeService({
    required NightScheduleRepository repository,
    required Clock clock,
    required WallClock wallClock,
  })  : _repository = repository,
        _clock = clock,
        _wallClock = wallClock;

  final NightScheduleRepository _repository;
  final Clock _clock;
  final WallClock _wallClock;
  final StreamController<NightPhase> _changes = StreamController<NightPhase>.broadcast();
  StreamSubscription<NightSchedule>? _subscription;

  NightSchedule _schedule = NightSchedule.standard();
  NightPhase _current = NightPhase.day;

  /// La fase ahora mismo.
  NightPhase get current => _current;

  /// El horario con el que se calcula.
  NightSchedule get schedule => _schedule;

  /// Lee el horario guardado y empieza a seguir sus cambios.
  Future<void> start() async {
    _schedule = await _repository.get();
    _current = NightPhases.at(_clock.nowUtc(), _schedule, _wallClock);
    _subscription = _repository.watch().listen((NightSchedule schedule) {
      _schedule = schedule;
      refresh();
    });
  }

  /// Recalcula la fase con la hora actual y avisa si cambió.
  void refresh() {
    final NightPhase phase = NightPhases.at(_clock.nowUtc(), _schedule, _wallClock);
    if (phase != _current) {
      _current = phase;
      if (!_changes.isClosed) {
        _changes.add(phase);
      }
    }
  }

  @override
  Stream<NightPhase> watchPhase() {
    StreamSubscription<NightPhase>? subscription;
    late final StreamController<NightPhase> controller;
    controller = StreamController<NightPhase>(
      onListen: () {
        controller.add(_current);
        subscription = _changes.stream.listen(controller.add, onDone: controller.close);
      },
      // Sin esperar a la cancelación: con el reloj simulado de testWidgets no
      // termina.
      onCancel: () {
        unawaited(subscription?.cancel());
      },
    );
    return controller.stream;
  }

  /// Deja de seguir el horario y cierra el stream.
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_changes.close());
  }
}
