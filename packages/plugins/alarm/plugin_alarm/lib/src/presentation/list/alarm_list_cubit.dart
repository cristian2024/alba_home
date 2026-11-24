import 'dart:async';

import 'package:alarm_contract/alarm_contract.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../alarm_dependencies.dart';
import '../../domain/use_cases/alarm_use_cases.dart';

/// Estado de la lista de alarmas.
class AlarmListState extends Equatable {
  const AlarmListState({
    required this.now,
    this.entries = const <AlarmListEntry>[],
    this.next,
    this.canRing = true,
    this.loaded = false,
  });

  /// Hora con la que se calculó todo, en UTC.
  final DateTime now;
  final List<AlarmListEntry> entries;
  final NextAlarm? next;

  /// Si Android deja sonar las alarmas (03.7).
  final bool canRing;
  final bool loaded;

  @override
  List<Object?> get props => <Object?>[now, entries.map((AlarmListEntry e) => (e.alarm, e.nextRing)).toList(), next, canRing, loaded];
}

/// Sigue las alarmas, la próxima y el permiso, y recalcula «suena en…» cada
/// minuto.
class AlarmListCubit extends Cubit<AlarmListState> {
  AlarmListCubit(this._dependencies, {Duration tick = const Duration(minutes: 1)})
      : super(AlarmListState(now: _dependencies.clock.nowUtc())) {
    _subscriptions
      ..add(_dependencies.repository.watchAlarms().listen((List<Alarm> alarms) {
        _alarms = alarms;
        _emit();
      }))
      ..add(_dependencies.nextAlarm.watchNextAlarm().listen((NextAlarm? next) {
        _next = next;
        _emit();
      }))
      ..add(_dependencies.nextAlarm.watchCanRing().listen((bool canRing) {
        _canRing = canRing;
        _emit();
      }));
    _timer = Timer.periodic(tick, (Timer timer) => _emit());
  }

  final AlarmDependencies _dependencies;
  final List<StreamSubscription<Object?>> _subscriptions = <StreamSubscription<Object?>>[];
  late final Timer _timer;
  List<Alarm>? _alarms;
  NextAlarm? _next;
  bool _canRing = true;

  void _emit() {
    final List<Alarm>? alarms = _alarms;
    if (alarms == null || isClosed) {
      return;
    }
    final DateTime now = _dependencies.clock.nowUtc();
    emit(
      AlarmListState(
        now: now,
        entries: _dependencies.entries(alarms, now),
        next: _next,
        canRing: _canRing,
        loaded: true,
      ),
    );
  }

  Future<void> setEnabled(String id, {required bool enabled}) => _dependencies.setEnabled(id, enabled: enabled);

  /// Pide a Android el permiso de alarmas exactas y vuelve a leerlo.
  Future<void> requestPermission() async {
    await _dependencies.scheduler.requestPermissions();
    await _dependencies.nextAlarm.refresh();
  }

  @override
  Future<void> close() async {
    _timer.cancel();
    for (final StreamSubscription<Object?> subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    return super.close();
  }
}
