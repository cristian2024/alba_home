import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../alarm_dependencies.dart';
import '../../domain/use_cases/ringing_use_cases.dart';

/// Lo que suena o está pospuesto; `ringing` es `null` si ya no hay nada.
class RingingState extends Equatable {
  const RingingState({this.ringing, this.loaded = false});

  final RingingAlarm? ringing;
  final bool loaded;

  @override
  List<Object?> get props => <Object?>[ringing?.alarm, ringing?.session, loaded];
}

/// Sigue la alarma que suena y la pospone o la apaga.
class RingingCubit extends Cubit<RingingState> {
  RingingCubit(this._dependencies) : super(const RingingState()) {
    _subscription = _dependencies.watchRinging().listen(
          (RingingAlarm? ringing) => emit(RingingState(ringing: ringing, loaded: true)),
        );
  }

  final AlarmDependencies _dependencies;
  late final StreamSubscription<RingingAlarm?> _subscription;

  Future<void> snooze() => _dependencies.snooze();

  Future<void> dismiss() => _dependencies.dismiss();

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
