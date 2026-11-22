/// Dobles de prueba y tests de contrato de `core_audio`.
library;

import 'dart:async';

import 'core_audio.dart';

export 'src/testing/audio_playback_contract.dart';

/// [AudioPlayback] en memoria: no suena, pero lleva el estado como un
/// reproductor real y aplica los fundidos al instante. Cumple
/// `audioPlaybackContract`.
class InMemoryAudioPlayback implements AudioPlayback {
  /// [unplayableAssets]: assets que fallan al reproducir, para probar el caso
  /// «no se pudo reproducir».
  InMemoryAudioPlayback({Set<String> unplayableAssets = const <String>{}})
      : _unplayableAssets = unplayableAssets;

  final Set<String> _unplayableAssets;
  final StreamController<PlaybackState> _changes = StreamController<PlaybackState>.broadcast();
  final List<Duration> _fades = <Duration>[];
  PlaybackState _state = PlaybackState.idle;
  bool _disposed = false;

  /// Duración de cada fundido pedido (entrada, cambio de volumen o salida), en
  /// orden; `Duration.zero` cuando fue de golpe.
  List<Duration> get fades => List<Duration>.unmodifiable(_fades);

  @override
  PlaybackState get state => _state;

  @override
  Stream<PlaybackState> watchState() {
    if (_disposed) {
      return const Stream<PlaybackState>.empty();
    }
    return _replayCurrent(() => _state, _changes.stream);
  }

  @override
  Future<void> play(AudioTrack track, {double volume = 1, bool loop = true, Duration fadeIn = Duration.zero}) async {
    _checkNotDisposed();
    AudioValidation.volume(volume);
    AudioValidation.fade(fadeIn, 'fadeIn');
    if (_unplayableAssets.contains(track.asset)) {
      _emit(PlaybackState(volume: _state.volume, loop: _state.loop));
      throw AudioPlaybackException(track);
    }
    _fades.add(fadeIn);
    _emit(PlaybackState(track: track, volume: volume, loop: loop));
  }

  @override
  Future<void> setVolume(double volume, {Duration fade = Duration.zero}) async {
    _checkNotDisposed();
    AudioValidation.volume(volume);
    AudioValidation.fade(fade, 'fade');
    _fades.add(fade);
    _emit(PlaybackState(track: _state.track, volume: volume, loop: _state.loop));
  }

  @override
  Future<void> stop({Duration fadeOut = Duration.zero}) async {
    _checkNotDisposed();
    AudioValidation.fade(fadeOut, 'fadeOut');
    if (!_state.isPlaying) {
      return;
    }
    _fades.add(fadeOut);
    _emit(PlaybackState(volume: _state.volume, loop: _state.loop));
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _changes.close();
  }

  void _emit(PlaybackState state) {
    if (state == _state) {
      return;
    }
    _state = state;
    _changes.add(state);
  }

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('InMemoryAudioPlayback ya se liberó');
    }
  }
}

/// Emite [current] al suscribirse y después [changes]. Se suscribe a
/// [changes] en el mismo momento, así que no pierde lo que llegue antes de
/// que el consumidor pida el siguiente evento.
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
