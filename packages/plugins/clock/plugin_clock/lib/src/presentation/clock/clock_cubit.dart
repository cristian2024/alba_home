import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clock_domain/clock_domain.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_frame_contract/photo_frame_contract.dart';

import '../../ambient_feed.dart';
import '../../clock_dependencies.dart';

/// Lo que muestra el reloj.
class ClockState extends Equatable {
  const ClockState({
    required this.now,
    required this.phase,
    this.photo,
    this.scrimOpacity = PhotoScrim.baseline,
    this.statuses = const <AmbientStatus>[],
    this.banner,
  });

  /// Ahora, en UTC, al minuto.
  final DateTime now;
  final NightPhase phase;

  /// La foto de fondo, solo si no es de noche.
  final CurrentPhoto? photo;

  /// Opacidad del degradado sobre [photo].
  final double scrimOpacity;

  /// Hasta dos bloques: el primero a la izquierda y el segundo a la derecha.
  final List<AmbientStatus> statuses;

  final AmbientAlert? banner;

  /// La foto que se ve: ninguna de noche.
  CurrentPhoto? get visiblePhoto => phase.isNight ? null : photo;

  ClockState copyWith({
    DateTime? now,
    NightPhase? phase,
    CurrentPhoto? Function()? photo,
    double? scrimOpacity,
    List<AmbientStatus>? statuses,
    AmbientAlert? Function()? banner,
  }) =>
      ClockState(
        now: now ?? this.now,
        phase: phase ?? this.phase,
        photo: photo == null ? this.photo : photo(),
        scrimOpacity: scrimOpacity ?? this.scrimOpacity,
        statuses: statuses ?? this.statuses,
        banner: banner == null ? this.banner : banner(),
      );

  @override
  List<Object?> get props => <Object?>[now, phase, photo, scrimOpacity, statuses, banner];
}

/// Sigue la hora (al minuto), la fase de noche, la foto y lo que publican los
/// demás plugins.
class ClockCubit extends Cubit<ClockState> {
  /// [scrimLuminance] y [textLuminance] son las del degradado y la hora sobre
  /// foto, para calcular la opacidad que da 7:1. Con [tick] avanza solo; sin
  /// él (tests), con [tickNow].
  ClockCubit(
    this._dependencies, {
    required double scrimLuminance,
    required double textLuminance,
    Duration? tick = const Duration(seconds: 1),
  })  : _scrimLuminance = scrimLuminance,
        _textLuminance = textLuminance,
        super(
          ClockState(
            now: _minute(_dependencies.clock.nowUtc()),
            phase: _dependencies.nightMode.current,
          ),
        ) {
    _subscriptions.add(_dependencies.nightMode.watchPhase().listen((NightPhase phase) => _emit(state.copyWith(phase: phase))));
    final CurrentPhotoQuery? photos = _dependencies.photos;
    if (photos != null) {
      _subscriptions.add(photos.watchCurrentPhoto().listen(_onPhoto));
    }
    final AmbientFeed? ambient = _dependencies.ambient;
    if (ambient != null) {
      _subscriptions.add(ambient.watch().listen(_onAmbient));
    }
    if (tick != null) {
      _timer = Timer.periodic(tick, (Timer timer) => tickNow());
    }
  }

  final ClockDependencies _dependencies;
  final double _scrimLuminance;
  final double _textLuminance;
  final List<StreamSubscription<Object?>> _subscriptions = <StreamSubscription<Object?>>[];
  Timer? _timer;

  /// Pone la hora al minuto actual.
  void tickNow() => _emit(state.copyWith(now: _minute(_dependencies.clock.nowUtc())));

  /// Pasa [actionId] del banner al plugin que lo publicó.
  Future<void> onBannerAction(String actionId) async {
    final AmbientAlert? banner = state.banner;
    final AmbientFeed? ambient = _dependencies.ambient;
    if (banner != null && ambient != null) {
      await ambient.onAction(banner, actionId);
    }
  }

  Future<void> _onPhoto(CurrentPhoto? photo) async {
    _emit(state.copyWith(photo: () => photo, scrimOpacity: PhotoScrim.baseline));
    if (photo == null) {
      return;
    }
    final double? luminance = await _dependencies.photoLuminance.of(photo.filePath);
    if (luminance == null || state.photo != photo) {
      return;
    }
    _emit(
      state.copyWith(
        scrimOpacity: PhotoScrim.opacityFor(
          photoLuminance: luminance,
          scrimLuminance: _scrimLuminance,
          textLuminance: _textLuminance,
        ),
      ),
    );
  }

  void _onAmbient(AmbientResolution resolution) =>
      _emit(state.copyWith(statuses: resolution.statuses.take(2).toList(), banner: () => resolution.banner));

  void _emit(ClockState next) {
    if (!isClosed) {
      emit(next);
    }
  }

  static DateTime _minute(DateTime utc) => DateTime.utc(utc.year, utc.month, utc.day, utc.hour, utc.minute);

  @override
  Future<void> close() {
    _timer?.cancel();
    // Sin esperar a las cancelaciones: con el reloj simulado de testWidgets
    // no terminan.
    for (final StreamSubscription<Object?> subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    return super.close();
  }
}
