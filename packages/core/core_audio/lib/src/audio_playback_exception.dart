import 'audio_track.dart';

/// No se pudo reproducir [track]: falta el archivo, está dañado o el sistema
/// no lo admite.
class AudioPlaybackException implements Exception {
  const AudioPlaybackException(this.track, [this.cause]);

  final AudioTrack track;

  /// Error original del motor de audio, para el registro.
  final Object? cause;

  @override
  String toString() => 'AudioPlaybackException: no se pudo reproducir ${track.id} (${track.asset})'
      '${cause == null ? '' : ': $cause'}';
}
