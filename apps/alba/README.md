# alba

App de Alba: el punto de composición que ensambla los plugins (reloj, alarma, batería, sonidos, cocina y fotos) y elige sus adaptadores. Corre en horizontal sobre el Mate 20 Lite y, en la fase 5, actuará como launcher.

## Estado

Compone la alarma:

- **Adaptadores** (`lib/src/alba_composition.dart`): `IsarStorage` con `AlarmIsar` y `AlarmSchedulerModule` (paquete `alarm`). Es el único sitio que nombra tecnologías.
- **Plugins**: `AlarmPlugin`, con su ciclo de vida (`PluginLifecycleManager`). Un plugin que falla al iniciar no impide arrancar a los demás.
- **Avisos**: `AmbientHost` junta los avisos de los plugins y `AmbientAlertNavigator` abre la pantalla del que gana a pantalla completa (la alarma sonando), esté donde esté la app.
- **Idioma**: el del sistema (español o inglés); las páginas abiertas cambian de idioma con `LanguageRebuilder`.

Mientras no exista el reloj, el inicio lleva a la lista de alarmas. El aviso genérico (sin pantalla propia), los banners y las cápsulas los dibujará el reloj.

## Uso

```bash
melos bs
cd apps/alba && flutter run
```

APK de release: `melos run build:apk` desde la raíz.

## Android

- `minSdk` 24 (el teléfono tiene Android 10) y `compileSdk` 37, que exige `permission_handler`.
- Los permisos de `alarm` (alarmas exactas, primer plano, pantalla completa, arranque al encender, notificaciones) llegan con su manifiesto.
- Orientación horizontal (`sensorLandscape`).
- Identificador provisional `com.example.alba`, que se revisa antes del APK de release.

## Tests

`flutter test` en esta carpeta, o `melos run test` desde la raíz. Los tests arrancan la app real con los adaptadores en memoria.
