import 'package:core_audio/core_audio.dart';
import 'package:core_audio/testing.dart';
import 'package:test/test.dart';

const AudioTrack _rain = AudioTrack(id: 'rain', asset: 'rain.ogg');
const AudioTrack _waves = AudioTrack(id: 'waves', asset: 'waves.ogg');
const AudioTrack _missing = AudioTrack(id: 'missing', asset: 'missing.ogg');

void main() {
  audioPlaybackContract(
    'InMemoryAudioPlayback',
    create: () => InMemoryAudioPlayback(unplayableAssets: <String>{_missing.asset}),
    track: _rain,
    otherTrack: _waves,
    unplayableTrack: _missing,
  );

  group('InMemoryAudioPlayback', () {
    test('registra la duración de cada fundido', () async {
      final InMemoryAudioPlayback player = InMemoryAudioPlayback();

      await player.play(_rain, fadeIn: const Duration(seconds: 2));
      await player.setVolume(0.5);
      await player.stop(fadeOut: const Duration(minutes: 1));
      await player.stop(fadeOut: const Duration(minutes: 1));

      expect(player.fades, <Duration>[const Duration(seconds: 2), Duration.zero, const Duration(minutes: 1)]);
      await player.dispose();
    });
  });

  group('modelos', () {
    test('AudioTrack y PlaybackState se comparan por valor', () {
      expect(const AudioTrack(id: 'rain', asset: 'rain.ogg'), _rain);
      expect(const PlaybackState(track: _rain, volume: 0.5), const PlaybackState(track: _rain, volume: 0.5));
      expect(const PlaybackState(track: _rain), isNot(const PlaybackState(track: _rain, loop: false)));
      expect(_rain.toString(), contains('rain.ogg'));
    });

    test('AudioPlaybackException nombra el sonido y la causa', () {
      expect(const AudioPlaybackException(_rain).toString(), contains('rain.ogg'));
      expect(const AudioPlaybackException(_rain, 'códec').toString(), contains('códec'));
    });

    test('AudioValidation rechaza NaN', () {
      expect(() => AudioValidation.volume(double.nan), throwsArgumentError);
      expect(() => AudioValidation.volume(0), returnsNormally);
      expect(() => AudioValidation.volume(1), returnsNormally);
    });
  });
}
