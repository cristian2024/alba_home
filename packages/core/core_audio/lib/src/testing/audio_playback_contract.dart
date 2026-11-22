import 'package:async/async.dart';
import 'package:test/test.dart';

import '../audio_playback.dart';
import '../audio_playback_exception.dart';
import '../audio_track.dart';
import '../playback_state.dart';

/// Tests de contrato de [AudioPlayback]. Toda implementación debe pasarlos.
///
/// - [create] devuelve un reproductor nuevo para cada test; el contrato lo
///   libera.
/// - [track] y [otherTrack] son dos sonidos que la implementación puede
///   reproducir.
/// - [unplayableTrack], si se da, es uno que no puede cargar (p. ej. un asset
///   que no existe).
///
/// ```dart
/// audioPlaybackContract(
///   'InMemoryAudioPlayback',
///   create: () => InMemoryAudioPlayback(unplayableAssets: <String>{'missing.ogg'}),
///   track: const AudioTrack(id: 'rain', asset: 'rain.ogg'),
///   otherTrack: const AudioTrack(id: 'waves', asset: 'waves.ogg'),
///   unplayableTrack: const AudioTrack(id: 'missing', asset: 'missing.ogg'),
/// );
/// ```
void audioPlaybackContract(
  String implementation, {
  required AudioPlayback Function() create,
  required AudioTrack track,
  required AudioTrack otherTrack,
  AudioTrack? unplayableTrack,
}) {
  group('AudioPlayback ($implementation)', () {
    late AudioPlayback player;
    bool disposed = false;

    setUp(() {
      player = create();
      disposed = false;
    });
    tearDown(() async {
      if (!disposed) {
        await player.dispose();
      }
    });

    test('empieza en silencio y con el volumen al máximo', () {
      expect(player.state, PlaybackState.idle);
      expect(player.state.isPlaying, isFalse);
    });

    test('watchState emite el estado actual al suscribirse', () async {
      expect(await player.watchState().first, player.state);
    });

    test('play reproduce el sonido con el volumen y el bucle pedidos', () async {
      await player.play(track, volume: 0.4, loop: false);

      expect(player.state, PlaybackState(track: track, volume: 0.4, loop: false));
      expect(player.state.isPlaying, isTrue);
    });

    test('play sustituye lo que sonaba', () async {
      await player.play(track);
      await player.play(otherTrack, volume: 0.5);

      expect(player.state.track, otherTrack);
      expect(player.state.volume, 0.5);
    });

    test('watchState emite cada cambio', () async {
      final StreamQueue<PlaybackState> states = StreamQueue<PlaybackState>(player.watchState());
      expect(await states.next, PlaybackState.idle);

      await player.play(track, volume: 0.5);
      await expectLater(states, emitsThrough(PlaybackState(track: track, volume: 0.5)));

      await player.stop();
      await expectLater(states, emitsThrough(const PlaybackState(volume: 0.5)));
      await states.cancel();
    });

    test('setVolume cambia el volumen mientras suena', () async {
      await player.play(track);
      await player.setVolume(0.25);

      expect(player.state, PlaybackState(track: track, volume: 0.25));
    });

    test('setVolume sin nada sonando guarda el valor para la próxima reproducción', () async {
      await player.setVolume(0.3);

      expect(player.state, const PlaybackState(volume: 0.3));
    });

    test('los fundidos terminan con el valor pedido', () async {
      const Duration fade = Duration(milliseconds: 60);

      await player.play(track, volume: 0.8, fadeIn: fade);
      expect(player.state, PlaybackState(track: track, volume: 0.8));

      await player.setVolume(0.2, fade: fade);
      expect(player.state.volume, 0.2);

      await player.stop(fadeOut: fade);
      expect(player.state.isPlaying, isFalse);
    });

    test('stop deja el reproductor en silencio y conserva el volumen', () async {
      await player.play(track, volume: 0.6);
      await player.stop();

      expect(player.state, const PlaybackState(volume: 0.6));
    });

    test('stop sin nada sonando no falla', () async {
      await player.stop();

      expect(player.state, PlaybackState.idle);
    });

    test('rechaza volúmenes fuera de 0 a 1 y fundidos negativos', () async {
      expect(() => player.play(track, volume: 1.5), throwsArgumentError);
      expect(() => player.play(track, volume: -0.1), throwsArgumentError);
      expect(() => player.play(track, fadeIn: const Duration(seconds: -1)), throwsArgumentError);
      expect(() => player.setVolume(2), throwsArgumentError);
      expect(() => player.setVolume(0.5, fade: const Duration(seconds: -1)), throwsArgumentError);
      expect(() => player.stop(fadeOut: const Duration(seconds: -1)), throwsArgumentError);
      expect(player.state, PlaybackState.idle);
    });

    if (unplayableTrack != null) {
      test('un sonido que no se puede cargar lanza AudioPlaybackException y queda en silencio', () async {
        await player.play(track);

        await expectLater(
          player.play(unplayableTrack),
          throwsA(isA<AudioPlaybackException>().having((AudioPlaybackException e) => e.track, 'track', unplayableTrack)),
        );
        expect(player.state.isPlaying, isFalse);
      });
    }

    test('tras dispose, las operaciones lanzan StateError y watchState termina', () async {
      await player.dispose();
      disposed = true;

      expect(() => player.play(track), throwsStateError);
      expect(() => player.setVolume(0.5), throwsStateError);
      expect(() => player.stop(), throwsStateError);
      expect(await player.watchState().toList(), isEmpty);
    });
  });
}
