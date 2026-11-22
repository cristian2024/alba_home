# Alba · bitácora de desarrollo (fases 3 a 5)

Última actualización: 2026-11-22.

## Fase actual

**Fase 3 (base del monorepo): pasos 1 a 3 hechos.** `flutter_shared` publicado: PRs #1 a #6 mergeados y etiquetas `core_utils-v0.1.2`, `core_di-v0.1.2`, `core_events-v0.2.0`, `core_ui-v0.1.2`, `core_contracts-v0.1.4` y `storage_isar-v0.3.0`. Workspace de Alba (paso 2) y contratos nuevos (paso 3) en local, sin commits, con `melos run verify` en verde. Siguiente: paso 4, `design_system`.

### flutter_shared (paso 1)

- Raíz: Melos 8.9 con workspaces, SDK `^3.11`, `analysis_options.yaml`, `.gitignore`, `tool/` (analyze, verify_architecture con sus tests, test_changed) y CI copiados de home_tasks, más `README.md` y `CLAUDE.md`.
- Paquetes extraídos de home_tasks sin cambios: `core_di` 0.1.2, `core_events` 0.2.0, `core_utils` 0.1.2, `core_ui` 0.1.2.
- `core_contracts` **0.1.4**, un cambio compatible (por eso no es 0.2.0 como se dijo al principio): `AmbientStatus` y `AmbientStatusSource`, `AmbientAlert` y `AmbientAlertSource` con acciones y política en horas de silencio, `AmbientAlertResolver` (reglas de 09.2: menor número gana, cola de pantallas completas, un banner, máx. 2 estados), tests de contrato y dobles en memoria. `buildDashboardTile` tiene implementación por defecto.
- `storage_isar` **0.3.0** (incompatible): `isar_community` 3.4.1 y sin `IsarSpaceStorage`. Por eso, para pasar `storage_isar` a la versión compartida, home_tasks tendrá que mover antes `IsarSpaceStorage` a su propio repo.
- Commits (2026-11-22, subidos con sus PRs el mismo día):
  - `main`: la raíz, en un solo commit. Sola no resuelve, porque pub falla con un workspace sin paquetes; la CI de un push de `main` saldrá en rojo hasta el primer merge.
  - Ramas `feat/core-utils`, `feat/core-di`, `feat/core-events`, `feat/core-ui` y `feat/core-contracts`, todas desde `main`, con un commit cada una.
  - `feat/storage-isar` en escalera: incluye los merges de `feat/core-di` y `feat/core-contracts`, porque depende de ellos. Su PR se abre cuando esas dos estén en `main`.
  - `local/integracion`: rama solo local que junta las seis, para tener todos los paquetes en disco (Alba los usa por `pubspec_overrides.yaml`). No se sube.
- El workspace usa un solo patrón, `packages/*/*`: pub falla si un patrón no encuentra ningún paquete, y cada rama trae solo el suyo.

### Workspace de Alba (paso 2)

- Raíz `alba_home`: Melos 8.9 con workspaces, SDK `^3.11`; `analysis_options.yaml`, `.gitignore`, `tool/` y CI copiados de `flutter_shared` (que a su vez vienen de home_tasks), más `CLAUDE.md` y `README.md`. Script `build:apk` para `apps/alba`.
- `workspace:` solo con `apps/alba`: pub falla si una entrada no encuentra paquetes, así que cada carpeta se añade con su primer paquete.
- Verificador de arquitectura adaptado: `storage_isar` cuenta como adaptador aunque venga de fuera (regla 6), y los SDKs de Alba (`just_audio`, `audio_session`, `alarm`, `battery_plus`, `wakelock_plus`, `screen_brightness`, `shared_preferences`…) solo los importan los adaptadores (regla 9). Con sus tests.
- `apps/alba` 0.1.0+1: `com.example.alba`, `minSdk` 24, `sensorLandscape`, etiqueta «Alba». `main` prepara el `ServiceLocator` y muestra el nombre sobre negro, con un widget test. `core_di` se resuelve por git desde la etiqueta, sin overrides. El APK de debug compila.

### Contratos nuevos (paso 3)

Cuatro paquetes en `packages/core/` (añadido `packages/core/*` al workspace), Dart puro, 0.1.0, con README, CHANGELOG, tests de contrato y doble en memoria en `testing.dart`. Cobertura de líneas del 100 % en los cuatro.

- `core_audio`: `AudioPlayback` (un canal: `play` con volumen, bucle y `fadeIn`; `setVolume` con fundido; `stop` con `fadeOut`; `watchState`). Las operaciones terminan con el fundido aplicado. `AudioPlaybackException` para «No se pudo reproducir» (04.5). Doble `InMemoryAudioPlayback`, que registra los fundidos.
- `core_alarm_scheduler`: `AlarmScheduler` con disparos únicos `ScheduledAlarm` (id de quien la programa, hora UTC, textos, sonido, volumen, subida, vibración, bucle). Al sonar sale de `scheduled()` y pasa a `watchRinging()` (varias a la vez, para 05.6); repetir y posponer los decide el dominio volviendo a programar el mismo id. `AlarmPermissions` (exactas, notificaciones, pantalla completa) para 03.7. Doble `InMemoryAlarmScheduler` con `fire` y `fireDue`. Depende de `core_utils` (etiqueta) por `Clock`.
- `core_battery`: `BatteryReader` con `BatteryStatus` (nivel, `BatteryChargeState` con `notCharging`, temperatura en °C para 07.4) y `isPluggedIn` (07.1). Doble `InMemoryBatteryReader`.
- `core_display`: `DisplayControl` (pantalla encendida, brillo 0–1 o el del sistema, inmersivo). Doble `InMemoryDisplayControl`.
- Los dobles reenvían los cambios suscribiéndose al empezar a escuchar: con un generador `async*` se perdían los cambios que llegaban antes de pedir el siguiente evento (lo detectó el test de contrato).

## Hecho y verificado

- Leídos la skill `flutter-guidelines`, `PLAN.md`, el traspaso de diseño, la nota de diseño, `DESIGN.md`, `tokens.json`, `spec.json` y las convenciones de home_tasks (`CLAUDE.md`, `tool/` y Melos).
- Repos creados en GitHub (públicos y vacíos) y conectados como `origin`. No se ha hecho ningún commit ni push:
  - `cristian2024/flutter_shared` → `/Users/daniel/Documents/projects/flutter_shared` (rama `main`)
  - `cristian2024/alba_home` → `/Users/daniel/Documents/projects/phone_work` (rama `main`; la carpeta no se renombra)

## Decisiones

| Tema | Decisión |
| :--- | :--- |
| Paquetes compartidos | Repo **nuevo** `flutter_shared`, desde cero. `flutter-packages` es un intento viejo sin relación con esto: no se toca (además, `deuda_pro` usa sus carpetas por ruta absoluta) |
| Estructura de `flutter_shared` | Melos 8 + pub workspaces, SDK `^3.11`. `packages/core/` (`core_di`, `core_events`, `core_contracts`), `packages/shared/` (`core_utils`, `core_ui`), `packages/adapters/` (`storage_isar`). Tooling y CI copiados de home_tasks |
| Versiones iniciales | Etiquetas `<paquete>-v<versión>`. `core_di`, `core_events`, `core_utils` y `core_ui` con su versión de home_tasks. `core_contracts` 0.1.4 (compatible: cápsulas, avisos, `buildDashboardTile` opcional). `storage_isar` 0.3.0 (`isar_community` 3.4.1, sin `IsarSpaceStorage`, que depende de `core_spaces` y se queda en home_tasks) |
| Ramas en `flutter_shared` | Raíz directa en `main`; `feat/core-utils`, `feat/core-di`, `feat/core-events`, `feat/core-ui` y `feat/core-contracts` desde `main`; `feat/storage-isar` después de `core-di` y `core-contracts`. Etiquetas sobre `main` tras cada merge, solo cuando el usuario lo pida |
| Repo de Alba | `alba_home`; la carpeta sigue llamándose `phone_work`; app en `apps/alba` (PLAN §9) |
| Identificador Android | Provisional, el básico: `com.example.alba`. Se revisa más adelante |
| Alarma: «Nueva» y «Guardar» | Suben de 48 a **72**, como las cabeceras de Cocina (desviación respecto a los PNG de 03.1, 03.3 y 03.7) |
| Aviso de noche «no llega a la alarma» | Texto corto «No llega a la alarma» en la cápsula del reloj (02.6n); texto largo «Con 9 % no llega a las 6:30» en el banner (07.5n) |
| Isar | `isar_community` 3.4.1 (la skill dice 3.3.2; manda la decisión del proyecto) |

## Pendientes

- Fase 3, pasos 1 a 5 (ver `PROMPT_desarrollo.md`).
- Conectar el Mate 20 Lite por `adb` antes de la fase 4 (ahora no hay dispositivo).
- Revisar el identificador Android antes del APK de release.
