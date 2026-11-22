# CLAUDE.md · Alba

Reloj de mesa de noche y cocina sobre un Huawei Mate 20 Lite (Android 10, EMUI 10): horizontal a 891×411 dp, siempre enchufado, sin internet y como launcher. Plan en `PLAN.md`, encargo en `PROMPT_desarrollo.md`, bitácora en `ESTADO_desarrollo.md`, diseño en `DESIGN.md` y `design/`.

Mismas pautas que home_tasks y la skill `flutter-guidelines`; aquí va lo propio de Alba y lo que conviene tener a mano.

## Límites
- **No tocar `hardware/` ni `design/penpot/`.**
- home_tasks y flutter_shared son otros repos: desde aquí no se modifican. Un cambio en un paquete compartido se hace en `flutter_shared`, con su rama, su PR y su etiqueta.
- **Commits, push y PRs solo cuando el usuario lo pida**, sin atribución a Claude.
- Si algo del diseño no se puede implementar tal cual o choca con Flutter o Android, avisar antes de desviarse.

## Comandos (Melos)
- `melos bs`: resuelve el workspace y ejecuta `melos run gen` (Isar con build_runner, slang). Los `*.g.dart` no se versionan; tras cambiar de rama, `melos run gen`.
- `melos run verify`: `analyze` (`tool/analyze.dart`, falla con cualquier diagnóstico) + `verify:arch` (`tool/verify_architecture.dart`) + `test`.
- `melos run test:changed`: lo que ejecuta la CI en un PR.
- `melos run build:apk` → `apps/alba/build/app/outputs/flutter-apk/app-release.apk`.
- Un paquete con `build_runner` y app de `example/` lleva un `build.yaml` que excluye `example/**` (si no, build_runner sigue `example/ios/.symlinks` y borra archivos de otros paquetes).

## Estructura
- `apps/alba`: punto de composición (launcher, modo aparato). Solo él elige adaptadores.
- `packages/core/*`: contratos propios de Alba (`core_audio`, `core_alarm_scheduler`, `core_battery`, `core_display`), Dart puro.
- `packages/adapters/*`: tecnologías concretas. `packages/contracts/*`: lo que un plugin publica a otros. `packages/plugins/<funcionalidad>/`: `_domain`, `plugin_` con su `example/` y sus adaptadores. `packages/shared/*`: Dart puro reutilizable. `packages/design_system`.
- La lista `workspace:` del `pubspec.yaml` raíz es un solo patrón con alternativas (`"{apps/alba,packages/core/*,packages/design_system,packages/design_system/example}"`): pub falla si una entrada no encuentra ningún paquete, y cada rama trae solo su proyecto. Al crear el primer paquete de una carpeta nueva, se añade como alternativa.

## Paquetes compartidos (flutter_shared)
- `core_di`, `core_events`, `core_contracts`, `core_utils`, `core_ui` y `storage_isar` vienen de https://github.com/cristian2024/flutter_shared por dependencia git con etiqueta y rango:

  ```yaml
  core_di:
    git:
      url: https://github.com/cristian2024/flutter_shared.git
      path: packages/core/core_di
      tag_pattern: core_di-v{{version}}
    version: ^0.1.2
  ```

- URL https (el repo es público): la CI la resuelve sin clave SSH.
- **Trabajar a la vez en un paquete compartido y en Alba:** un `pubspec_overrides.yaml` en la **raíz** (en un workspace, los overrides solo valen ahí; está en `.gitignore`) con `dependency_overrides:` que apuntan a `/Users/daniel/Documents/projects/flutter_shared/packages/...`. Al publicar la etiqueta se borra y se sube el rango.
- `tool/src/architecture_rules.dart` conoce por nombre los adaptadores externos (`externalAdapterPackages`): si llega otro adaptador compartido, se añade ahí.

## Contrato de plugin
- `HomePlugin` de `core_contracts` con interfaces opcionales que el host busca con un patrón de tipo: `HomePluginEntryRoute` (la pantalla del modo), `AmbientStatusSource` (cápsulas en el reloj) y `AmbientAlertSource` (avisos a pantalla completa o banner).
- Qué aviso gana lo decide `AmbientAlertResolver` con los 9 niveles de prioridad de `DESIGN.md` (09.2): menor número, más prioridad.
- Ningún plugin importa a otro: eventos para hechos (`AlarmRang`, `TimerFinished`) y capacidades para consultas (`NextAlarmQuery`…), publicados en `packages/contracts/`.

## Convenciones de código
- Las de la skill `flutter-guidelines`: tipos explícitos (`always_specify_types`, `toleratedCodes` vacío en `tool/analyze.dart`), nada de funciones que devuelven widgets, widgets reutilizables agnósticos, getters privados para `widget.x` repetido, estilos del tema en variables al inicio de `build`, constantes en su `abstract final class`, nombres descriptivos, `Semantics` o `tooltip` en todo lo interactivo.
- Dominio en Dart puro, UUID v4 y `DateTime` en UTC, con `Clock` e `IdGenerator` inyectados. Igualdad con `Equatable`.
- Textos con slang, en español e inglés, inyectados por el consumidor (`core_ui`). Nada de textos escritos a mano en la UI.
- Colores, medidas y textos siempre desde `design_system` (`AppThemeColors.of(context)`, `AppTypography`, `AppSpacing`…), nunca valores a mano. Los tokens de `packages/design_system/lib/src/tokens/` se generan desde `design/referencia_penpot/` con `dart run tool/generate_tokens.dart` y no se editan a mano.
- Variantes de Penpot con `AppTone` (`surface`, `photo`, `night`) y `AppUrgency`; el modo noche del reloj usa `AppTheme.night`.
- Cifras de la hora con cifras tabulares (ya incluidas en todos los estilos de `AppTypography`), Inter como asset de `design_system`.
- Una rama (y un PR) por proyecto; toda rama que cambia un paquete o la app sube su versión, añade su entrada al CHANGELOG y actualiza su README (formato y SemVer de la skill). La app sube además el `+build`.

## Trampas conocidas en tests (heredadas de home_tasks)
- **Handlers de bloc:** no hacer `await` de `subscription.cancel()` ni de `dispose()` dentro de un handler: en `testWidgets` no se completan con el reloj simulado. Lanzarlos con `unawaited`.
- **`onCancel` de un stream** que reenvía otra suscripción: no devolver el futuro de su `cancel()`; `Stream.first` lo espera y el test se cuelga.
- **`pumpAndSettle`** no termina con animaciones infinitas visibles (indicadores, el segundero): usar `pump()`.
- **Isar en tests:** `setUpAll(initializeIsarForTests)` de `storage_isar`, también con `testWidgets`.
- **Streams contra una base real:** esperar la emisión inicial con `StreamQueue` antes de escribir.
- **`router.push`** devuelve un futuro que se completa al volver: no hacer `await`; `unawaited` y `pumpAndSettle()`.
