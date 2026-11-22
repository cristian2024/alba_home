# alba

App de Alba: el punto de composición que ensambla los plugins (reloj, alarma, batería, sonidos, cocina y fotos) y elige sus adaptadores. Corre en horizontal sobre el Mate 20 Lite y, en la fase 5, actuará como launcher.

## Estado

Por ahora muestra el nombre sobre negro y prepara el `ServiceLocator`. El tema, el reloj y la navegación llegan con `design_system` y los plugins.

## Uso

```bash
melos bs
cd apps/alba && flutter run
```

APK de release: `melos run build:apk` desde la raíz.

## Android

- `minSdk` 24 (el teléfono tiene Android 10).
- Orientación horizontal (`sensorLandscape`).
- Identificador provisional `com.example.alba`, que se revisa antes del APK de release.

## Tests

`flutter test` en esta carpeta, o `melos run test` desde la raíz.
