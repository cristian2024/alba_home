# core_audio

Contrato para reproducir sonidos en bucle con volumen y fundidos, sin depender de un motor de audio concreto. Dart puro. Lo usan los sonidos para dormir; el adaptador real es `audio_just_audio`.

## Contenido

- `AudioPlayback`: un canal de reproducción. `play(track, volume:, loop:, fadeIn:)`, `setVolume(volume, fade:)`, `stop(fadeOut:)`, `state`, `watchState()` y `dispose()`. Las operaciones terminan cuando el cambio está aplicado, fundido incluido.
- `AudioTrack`: un sonido (id y asset).
- `PlaybackState`: qué suena, con qué volumen y si va en bucle.
- `AudioPlaybackException`: el sonido no se pudo cargar (pantalla «No se pudo reproducir»).
- `AudioValidation`: las comprobaciones de volumen y fundido que comparten las implementaciones.

## Uso

```dart
await player.play(const AudioTrack(id: 'rain', asset: 'assets/sounds/rain.ogg'), volume: 0.4);
// Apagado automático: el último minuto baja poco a poco.
await player.stop(fadeOut: const Duration(minutes: 1));
```

Para dos sonidos a la vez, dos reproductores.

## Tests

`package:core_audio/testing.dart` trae `audioPlaybackContract`, que toda implementación debe pasar, e `InMemoryAudioPlayback`, que lleva el estado sin sonar, aplica los fundidos al instante y registra su duración en `fades`.

```sh
dart test
```
