# core_display

Contrato para controlar la pantalla mientras la app está delante: mantenerla encendida, fijar el brillo (p. ej. el mínimo de noche) y ocultar las barras del sistema. Dart puro. El adaptador real es `display_android`.

## Contenido

- `DisplayControl`: `current()`, `setKeepScreenOn`, `setBrightness` (0 a 1), `resetBrightness` (vuelve al brillo del sistema) y `setImmersive`.
- `DisplayState`: `keepScreenOn`, `brightness` (`null` es el del sistema) e `immersive`.
- `DisplayValidation`: rechaza brillos fuera de 0 a 1.

## Uso

```dart
await display.setKeepScreenOn(true);
await display.setImmersive(true);
await display.setBrightness(0.02); // Noche.
```

## Tests

`package:core_display/testing.dart` trae `displayControlContract`, que toda implementación debe pasar y que deja la pantalla como estaba al terminar, e `InMemoryDisplayControl`.

```sh
dart test
```
