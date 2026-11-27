# alba

App de Alba: el punto de composición que ensambla los plugins (reloj, alarma, batería, sonidos, cocina y fotos) y elige sus adaptadores. Corre en horizontal sobre el Mate 20 Lite y, en la fase 5, actuará como launcher.

## Estado

Compone el reloj y la alarma:

- **Adaptadores** (`lib/src/alba_composition.dart`): `IsarStorage` con `ClockIsar` y `AlarmIsar`, y `AlarmSchedulerModule` (paquete `alarm`). Es el único sitio que nombra tecnologías.
- **Plugins**: `ClockPlugin` y `AlarmPlugin`, con su ciclo de vida (`PluginLifecycleManager`). Un plugin que falla al iniciar no impide arrancar a los demás. El reloj es el inicio.
- **Avisos y bloques**: `AmbientHost` junta los bloques de estado y los avisos de los plugins, aplica las horas de silencio de noche y es el `AmbientFeed` del reloj. `AmbientAlertNavigator` abre la pantalla del aviso a pantalla completa que gana (la alarma sonando), esté donde esté la app.
- **Noche**: con la fase del reloj (`NightModeQuery`), toda la app pasa a negro y ámbar.
- **Idioma**: el del sistema (español o inglés); las páginas abiertas cambian de idioma con `LanguageRebuilder`.

Mantener la hora abre, mientras no haya ajustes (fase 5), la lista de alarmas.

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
