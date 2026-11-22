import 'audio_track.dart';
import 'playback_state.dart';

/// Reproduce un sonido cada vez, normalmente en bucle, con volumen y
/// fundidos. Cada reproductor es un canal: quien necesite dos sonidos a la
/// vez usa dos reproductores.
///
/// Las operaciones terminan cuando el cambio está aplicado, fundido incluido:
/// `await stop(fadeOut: const Duration(minutes: 1))` vuelve al cabo de un
/// minuto, ya en silencio.
abstract interface class AudioPlayback {
  /// Estado actual.
  PlaybackState get state;

  /// Emite el estado actual al suscribirse y cada cambio después.
  Stream<PlaybackState> watchState();

  /// Empieza a reproducir [track], sustituyendo lo que sonara antes.
  ///
  /// Con [fadeIn], sube desde 0 hasta [volume] en ese tiempo. Lanza
  /// [ArgumentError] si [volume] no está entre 0 y 1 o [fadeIn] es negativo,
  /// y [AudioPlaybackException] si el sonido no se puede cargar (entonces
  /// queda en silencio).
  Future<void> play(AudioTrack track, {double volume = 1, bool loop = true, Duration fadeIn = Duration.zero});

  /// Cambia el volumen, de golpe o con un fundido de [fade]. Sin nada sonando,
  /// guarda el valor para la próxima reproducción. Lanza [ArgumentError] con
  /// valores fuera de rango.
  Future<void> setVolume(double volume, {Duration fade = Duration.zero});

  /// Detiene el sonido, de golpe o bajando en [fadeOut]. Sin nada sonando no
  /// hace nada. Conserva el volumen para la próxima reproducción.
  Future<void> stop({Duration fadeOut = Duration.zero});

  /// Libera el reproductor. Después, `play`, `setVolume` y `stop` lanzan
  /// [StateError] y `watchState` termina.
  Future<void> dispose();
}
