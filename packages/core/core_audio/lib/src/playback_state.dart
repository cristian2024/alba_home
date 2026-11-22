import 'package:equatable/equatable.dart';

import 'audio_track.dart';

/// Lo que está sonando ahora.
class PlaybackState extends Equatable {
  const PlaybackState({this.track, this.volume = 1, this.loop = true});

  /// Nada sonando, con el volumen al máximo.
  static const PlaybackState idle = PlaybackState();

  /// Sonido en reproducción; `null` si no suena nada.
  final AudioTrack? track;

  /// Volumen entre 0 y 1. Con un fundido en curso, el valor al que llega.
  final double volume;

  /// Si el sonido vuelve a empezar al terminar.
  final bool loop;

  bool get isPlaying => track != null;

  @override
  List<Object?> get props => <Object?>[track, volume, loop];

  @override
  bool get stringify => true;
}
