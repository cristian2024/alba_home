# Alba · bitácora de desarrollo (fases 3 a 5)

Última actualización: 2026-11-26 (reloj).

## Fase actual

**Fase 3 cerrada (visto bueno el 2026-11-22). Fase 4 empezada: alarma.** `flutter_shared` publicado: PRs #1 a #6 mergeados y etiquetas `core_utils-v0.1.2`, `core_di-v0.1.2`, `core_events-v0.2.0`, `core_ui-v0.1.2`, `core_contracts-v0.1.4` y `storage_isar-v0.3.0`. Workspace de Alba (paso 2) y contratos nuevos (paso 3) en `alba_home`: raíz directa en `main` y PRs #1 app, #2 core_audio, #3 core_alarm_scheduler, #4 core_battery y #5 core_display mergeados el 2026-11-22. `design_system` (paso 4) con su galería, y `melos run verify` en verde con todo. Siguiente: visto bueno de la fase 3 y fase 4 (alarma).

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

### Fase 4 · alarma (en curso, en local)

- `alarm_domain` 0.1.0 (Dart puro, 32 tests, 100 % de cobertura): `Alarm` con `AlarmTime` local y días `Weekday`; `NextRing` calcula la próxima vez (sin días: hoy o mañana; con días: el primero que toque) con `WallClock` inyectado (`FixedOffsetWallClock` para Colombia y los tests, `SystemWallClock` en la app); `AlarmSession` para sonar y posponer con límite («quedan 2», «1 de 3 veces»); `afterDismiss` desactiva las de una sola vez. `AlarmRepository` con tests de contrato y doble en memoria.
- `alarm_contract` 0.1.0 (proyecto aparte): `NextAlarmQuery` (próxima alarma y si Android deja sonar) con tests de contrato y doble, y eventos `AlarmRang`, `AlarmSnoozed`, `AlarmDismissed`.
- Workspace: el patrón añade `packages/plugins/*/*` y `packages/contracts/*`.
- `storage_isar` 0.3.0 no resolvía por git desde fuera (declaraba `core_contracts` y `core_di` solo con versión). Arreglo 0.3.1 en `flutter_shared` (PR #7) y regla en su CLAUDE.md (PR #8), pendientes de merge y de la etiqueta `storage_isar-v0.3.1`. Mientras, `pubspec_overrides.yaml` local (ignorado) apunta a la rama del arreglo.
- `alarm_isar` 0.1.0: `IsarAlarm` e `IsarAlarmSession` (fila única), `IsarAlarmRepository` en transacciones, `AlarmIsar` como `IsarFeature`. Pasa los tests de contrato con Isar real.
- `alarm_scheduler_alarm` 0.1.0 (adaptador de `core_alarm_scheduler` sobre `alarm` 5.15.0 y `permission_handler` 13.0.2): id de texto en el `payload` e id entero por FNV-1a; varias a la vez y en el mismo segundo; subida con `VolumeSettings.fade` y volumen forzado; orden de inicio seguido desde que se crea. `alarm` y los permisos van detrás de interfaces: pasa el contrato completo con un `alarm` simulado (20 tests). Pantalla completa (Android 14+) se da por concedida.
- **Decisión (usuario, 2026-11-22):** `alarm` exige `equatable ^2` en todas sus versiones; se fuerza `equatable ^3` con `dependency_overrides` en el pubspec raíz (compila: solo usa `extends Equatable` y `props`). Revisar en cada actualización de `alarm`.
- El patrón del workspace añade `packages/adapters/*`.
- `design_system` 0.1.1 (PR #9, mergeado): `AppToneScope`, `AppAlarmRow.blocked` y fuente `AlbaIcons` (IconData por icono, generada con `tool/generate_icon_font.py`). En la revisión, los colores del tema repetidos en un `build` pasan a variables (fila de alarma y cinco componentes más).
- `plugin_alarm` en local: casos de uso al 100 %, sonidos generados (`tool/generate_sounds.py`), slang es/en (sin fecha en la cabecera), pantallas 03.1–03.8, diálogos de nombre/sonido/posponer (sin diseño en Penpot), `AlarmPlugin` con cápsulas, avisos y `NextAlarmQuery`, y `example/` en memoria. 60 tests en verde. Arreglos que salieron de los tests: «mantener para apagar» soltado antes de tiempo posponía la alarma; la primera emisión de cápsulas salía vacía; cabecera 12 px más alta que en Penpot; diálogo de posposición desbordaba.
- **Resuelto en `flutter_shared` (2026-11-23):** `core_ui` y `storage_isar` no compilaban por git porque su código generado (`*.g.dart`) no se versionaba. PRs #9 (core_ui 0.1.3, slang sin fecha), #10 (storage_isar 0.3.2) y #11 (regla en su CLAUDE.md) mergeados; etiquetas `core_ui-v0.1.3` y `storage_isar-v0.3.2` publicadas. PR #12: paso de la CI que regenera y falla si algún `*.g.dart` cambia. Alba ya no usa `pubspec_overrides.yaml`: `core_ui ^0.1.3` y `storage_isar ^0.3.2` por git, verify en verde.
- PRs de la alarma mergeados (2026-11-23 a 2026-11-26): raíz #10, `alarm_contract` #11, `alarm_scheduler_alarm` #12, funcionalidad #13 y PLAN (canciones propias para una siguiente versión) #14.
- `alarm_scheduler_alarm` 0.1.1 (#15): `alarm` solo abre como asset las rutas que empiezan por `assets/`; la de un asset de otro paquete la buscaba como archivo y la alarma sonaba en silencio (comprobado en el emulador: `ENOENT`). Ahora copia el sonido a `alarm_sounds/` en los documentos de la app y, si falla, suena el tono del sistema.
- `alarm_domain` 0.2.0, `alarm_isar` 0.1.1 y `plugin_alarm` 0.1.1 (#16): una alarma de una sola vez guarda el instante para el que se programó (`onceAt`); si sonó con la app cerrada, al arrancar queda desactivada. La sincronización ya no reprograma (y corta) la alarma que suena al arrancar.
- `apps/alba` 0.2.0+2 (#17): compone `IsarStorage` con `AlarmIsar`, `AlarmSchedulerModule` y `AlarmPlugin` con su ciclo de vida; `AmbientHost` y `AmbientAlertNavigator` abren la pantalla de alarma sonando esté donde esté la app; idioma del sistema; `compileSdk` 37 (lo exige `permission_handler`). Mientras no haya reloj, el inicio lleva a la lista de alarmas.
- Probado en el emulador (Android 16): suena con la app cerrada, al abrir mientras suena aparece «sonando» sin cortarse, mantener apaga y desactiva, tras reiniciar no vuelve a sonar y queda desactivada. Una vez se cortó sola a los 2 min y no se repitió.
- Comparación con Impeccable a 891 × 411 (claro, oscuro y noche) contra los PNG de Penpot: PRs #18 (`design_system` 0.1.2: acción principal rellena de noche, sin subrayado de depuración en `AppFullScreenAlert`, `AppEmptyState.actionSize`) y #19 (`plugin_alarm` 0.1.2: cabecera de 72, lista vacía con una sola acción, sin «Próxima» con las alarmas bloqueadas, X en «Descartar», pista en `type.label`, «mantener para apagar» sin oscurecerse y con la pista oculta). En la revisión del #19, las secciones de textos leídas varias veces pasan a variables (regla en `CLAUDE.md`).
- **Visto bueno de la alarma (usuario, 2026-11-26)**, con la prueba en el Mate 20 Lite pendiente: se hará junto con la del reloj.

### Fase 4 · reloj

- `wall_clock` 0.1.0 (`packages/shared/`, nuevo en el workspace): `WallClock` sacado de `alarm_domain` para que lo use cualquier dominio. Pendiente: que `alarm_domain` pase a usarlo (hoy tiene su propia copia).
- `clock_contract` 0.1.0: `NightModeQuery` y `NightPhase` (día, atardecer, noche, amanecer). `photo_frame_contract` 0.1.0: `CurrentPhotoQuery`, que implementará el plugin de fotos (decisión del usuario: el contrato ya, para que el reloj dibuje la foto desde ahora).
- `clock_domain` 0.1.0 (Dart puro, 100 %): `NightSchedule` (22:30 a 6:45, fundido de 30 min antes y vuelta en 15 min), `NightPhases.at`, `PhotoScrim` (opacidad del degradado según la luminancia de la foto, mezcla en sRGB; con el degradado #0B0A09 al 72 % una foto blanca ya da 7,75:1, así que en la práctica se queda en el 72 %) y el repositorio del horario con tests de contrato.
- `clock_isar` 0.1.0 (decisión del usuario: Isar para el horario): una sola fila, pasa los tests de contrato.
- `design_system` 0.1.3: `AppPhotoScrim.opacity`.
- `plugin_clock` 0.1.0: reloj 02.1–02.9 (foto con degradado, fondo liso sin fotos, fundido a negro, noche en negro y ámbar, bloques, banner, mantener 2 s para ajustes con barra y halo, pista tras toque corto) y horario de noche 08.2. `NightModeService` implementa `NightModeQuery`; el plugin publica el bloque «Modo noche» al atardecer. `AmbientFeed` es el puerto por el que la app le da bloques y avisos (decisión del usuario: puertos en el reloj). 28 tests; dominio y casos de uso al 100 %. `example/` con botones para saltar a la hora de cada pantalla.
- `apps/alba` 0.3.0+3: el reloj es el inicio; `AmbientHost` junta bloques y avisos, aplica las horas de silencio de noche y es el `AmbientFeed`; de noche toda la app en negro y ámbar. Mantener la hora abre la lista de alarmas mientras no haya ajustes (fase 5).
- Comparado con Penpot a 891 × 411 (claro, oscuro y noche): coincide en posiciones y estilos; corregida la posición de «Termina» en 08.2. La foto no se dibuja en las capturas de test, así que el fondo con foto queda por ver en el teléfono.
- Siguiente: prueba en el Mate 20 Lite de alarma y reloj, y visto bueno del reloj.

### design_system (paso 4)

- `packages/design_system` 0.1.0, solo Flutter. Tokens generados por `tool/generate_tokens.dart` desde `tokens.json` y los iconos de `spec.json`; un test falla si lo versionado no coincide con el JSON.
- Temas `AppTheme.light`, `.dark` y `.night`, planos. Variantes de Penpot con `AppTone` (superficie, foto, noche) y `AppUrgency`.
- Inter 4.1 como asset y cifras tabulares en todos los estilos. Los 58 iconos se dibujan desde sus trazados de Penpot (M, L, H, V, Q, Z) con un parser propio, sin fuente de iconos.
- 22 componentes de las 20 familias de `spec.json`, con semántica para TalkBack, anillo de foco y estado pulsado. 49 tests, que cargan Inter para medir como en el aparato.
- Galería en `example/` con las secciones de `hojas/01_componentes_<tema>.png`; `flutter test --dart-define=GALLERY_OUT=<carpeta>` la captura a 2924 de ancho. Comparada con las hojas claro y oscuro: coincide salvo el espacio alrededor de los dos puntos de la hora (cifras tabulares en vez de cajas por dígito, como pide `DESIGN.md`).
- Decisiones menores: el botón `expand` baja el relleno a 16 para que quepa «1 min» en la tarjeta (las cifras tabulares lo ensanchan); el pulsado de `nightPrimary` usa `night.text-secondary` (Penpot no lo define); el `Night-Primary` de botón es ámbar macizo como en `spec.json` aunque `DESIGN.md` lo describa con borde.

### Repo alba_home

- `main` empieza con la raíz: tooling, CI, `CLAUDE.md`, `README.md`, `PLAN.md`, `PROMPT_desarrollo.md`, esta bitácora, `DESIGN.md` y `design/` sin `design/penpot/`. Fuera, sin seguimiento: `hardware/`, `design/penpot/` y `.impeccable/` (pendiente de decidir con el usuario).
- `workspace:` es un solo patrón con alternativas, `"{apps/alba,packages/core/*}"`: con entradas separadas, cada rama fallaba por la carpeta que no trae.
- `packages/core/README.md` va en la raíz para que la carpeta exista en todas las ramas: la herramienta de Flutter (no `dart pub`) falla si una carpeta del patrón no existe.
- `local/integracion`: rama solo local que junta las cinco ramas, para trabajar con todo en disco. No se sube. Los cambios de esta bitácora posteriores a la raíz irán en una rama de la raíz.

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
| Alarma de una sola vez ya pasada hoy (usuario, 2026-11-26) | Se rotula «Solo mañana», que es lo que ocurrirá, aunque 03.1 y 03.7 digan «Solo hoy» |
| Aviso de noche «no llega a la alarma» | Texto corto «No llega a la alarma» en la cápsula del reloj (02.6n); texto largo «Con 9 % no llega a las 6:30» en el banner (07.5n) |
| Isar | `isar_community` 3.4.1 (la skill dice 3.3.2; manda la decisión del proyecto) |

## Pendientes

- Fase 3, pasos 1 a 5 (ver `PROMPT_desarrollo.md`).
- Conectar el Mate 20 Lite por `adb` para la prueba de la alarma (ahora no hay dispositivo).
- Revisar el identificador Android antes del APK de release.
