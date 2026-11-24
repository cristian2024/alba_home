# Plan: Alba, reloj de casa sobre el Huawei Mate 20 Lite

Fecha: 2026-11-18. Estado (2026-11-21): fases 0, 1 y 2 **cerradas** (ver `design/TRASPASO_orquestacion.md`). El desarrollo (fases 3 a 5) va en su propio chat con `PROMPT_desarrollo.md`, y la base 3D en otro.

## 1. Objetivo

Convertir el Mate 20 Lite (Android 10, EMUI 10) en un aparato de mesa de noche y cocina que deje de comportarse como un celular. Va siempre en horizontal y siempre enchufado, funciona sin internet y es la pantalla de inicio del teléfono.

Funcionalidades:

| Funcionalidad | Qué hace |
| :--- | :--- |
| Reloj | Pantalla principal con la distribución **B**: hora abajo al centro y degradado inferior sobre la foto |
| Alarma | Alarmas recurrentes, posponer, pantalla de alarma sonando |
| Sonidos | Ruido blanco, lluvia o ventilador en bucle, con temporizador de apagado |
| Cocina | Varios temporizadores a la vez, con nombre y tiempos guardados |
| Fotos | Presentación de fotos de una carpeta local, solo de día, como fondo del reloj |
| Batería | Avisos por carga alta, carga baja, nivel crítico, temperatura y carga insuficiente para la próxima alarma |

Fuera de alcance por ahora: infrarrojo (el teléfono no tiene), SMS, cámara de seguridad y cualquier función que dependa de internet.

## 2. Fases y puertas

Cada fase termina con una puerta: no se pasa a la siguiente sin tu visto bueno.

| Fase | Resultado | Puerta |
| :--- | :--- | :--- |
| 0. Decisiones | Las preguntas abiertas del §9 respondidas | Tu respuesta |
| 1. Diseño en Penpot | Sistema de diseño y pantallas, una página por flujo | Revisión tuya |
| 2. Auditoría con Impeccable | Informe con hallazgos y correcciones aplicadas en Penpot | Sin hallazgos graves abiertos |
| 3. Base del monorepo | Workspace, tooling, núcleo y sistema de diseño en Flutter | `melos run verify` en verde |
| 4. Plugins | Un plugin por funcionalidad, en el orden del §6 | `verify` en verde y prueba en el teléfono por plugin |
| 5. App y modo aparato | Launcher, modo inmersivo, arranque, APK de release | Una semana de uso real sin fallos de alarma |
| 6. Base 3D | Soporte en OpenSCAD para el teléfono en horizontal | Impresión de prueba |

## 3. Fase 1: diseño en Penpot

### 3.1 Lienzo

- Tamaño de cada pantalla: **891 × 411** (puntos lógicos del Mate 20 Lite en horizontal: 2340 × 1080 a densidad 2,625).
- Sin barra de estado ni botones de navegación (la app los oculta).
- Cada pantalla en dos variantes cuando aplique: **día** (sobre foto) y **noche** (negro y ámbar).

### 3.2 Páginas del archivo

Un flujo por página, y el sistema de diseño en páginas propias:

| Página | Contenido |
| :--- | :--- |
| `00 Tokens` | Colores (día, noche, avisos), tipografía, espaciado, radios, opacidades del degradado |
| `01 Componentes` | Dígitos del reloj, cápsulas de estado, botones grandes, tarjeta de temporizador, banner de aviso, controles de ajustes |
| `02 Reloj` | Día con foto (distribución B), día sin fotos, noche, transición, reloj con temporizador y con aviso |
| `03 Alarma` | Lista, crear o editar, repetición por días, alarma sonando, pospuesta |
| `04 Sonidos` | Selector de sonido, reproduciendo, temporizador de apagado, vista de noche |
| `05 Cocina` | Sin temporizadores, varios en marcha, crear (tiempos guardados), terminado sonando |
| `06 Fotos` | Carpeta vacía con instrucciones, ajustes de la presentación |
| `07 Batería` | Banners de carga alta, baja, crítica, temperatura y "no llega a la alarma" |
| `08 Ajustes` | Acceso con pulsación larga, horario de noche, umbrales de batería, idioma |
| `09 Navegación` | Cómo se pasa entre modos (deslizar) y cómo se vuelve al reloj |

### 3.3 Criterios que el diseño debe cumplir

- Hora legible a 2 m: unos 35 a 40 % del alto en la distribución B, números tabulares y sin ambigüedad entre 1 y 7.
- Contraste de la hora de al menos **7:1** sobre el peor caso de foto, con el degradado.
- Noche: fondo negro puro y texto ámbar o rojo tenue, sin superficies claras.
- Áreas táctiles de al menos 48, y de unos 72 en alarma sonando y cocina (manos mojadas, medio dormido).
- Nada que recuerde a un celular: sin barra superior de app, sin menús de tres puntos, sin teclado salvo para el nombre de un temporizador.

### 3.4 Cómo se trabaja

Igual que en `design_system`: servidor `penpot-mcp` local, plugin conectado desde el navegador y scripts versionados en `phone_work/design/` para poder rehacer el archivo. Las exportaciones en PNG y un `spec.json` quedan en `design/referencia_penpot/` como referencia para Flutter.

## 4. Fase 2: auditoría con Impeccable

- Se audita con la skill `impeccable` sobre los PNG exportados de cada página, en día y noche.
- Qué revisa: jerarquía, legibilidad a distancia, contraste, consistencia entre flujos, áreas táctiles y estados vacíos o de error.
- Resultado: `design/auditoria_impeccable.md`, con cada hallazgo, su gravedad y cómo se resolvió en Penpot.
- Al terminar, Impeccable deja el `DESIGN.md` con el sistema de diseño final, que es la fuente para el paquete `design_system`.

## 5. Fase 3: base del monorepo

Mismas pautas que `home_tasks`: Melos 8 con pub workspaces, `flutter_bloc`, `go_router`, `get_it` envuelto en `ServiceLocator`, `isar_community` 3.3.2 solo en adaptadores, `slang` con textos inyectados por el consumidor, `equatable`, tipos explícitos, verificador de arquitectura en `tool/`, CHANGELOG y SemVer por paquete, una rama por proyecto.

### 5.1 Estructura

```
phone_work/
├── apps/app/                       Punto de composición (launcher, modo aparato)
├── packages/
│   ├── core/                       Contratos transversales (Dart puro salvo core_ui)
│   ├── adapters/                   Tecnologías concretas
│   ├── contracts/                  Lo que un plugin publica a otros
│   ├── plugins/<funcionalidad>/    _domain, plugin_, adaptador
│   ├── shared/                     Dart puro reutilizable
│   └── design_system/
├── design/                         Penpot, referencias y auditoría
└── tool/                           analyze, verify_architecture, test_changed
```

### 5.2 Núcleo

| Paquete | Origen | Responsabilidad |
| :--- | :--- | :--- |
| `core_di` | Reutilizado de home_tasks | `ServiceLocator` y `DependencyModule` |
| `core_events` | Reutilizado | `EventBus` |
| `core_utils` | Reutilizado | `Clock`, `IdGenerator` |
| `core_ui` | Reutilizado | `LocalizationCoordinator`, `injectTranslations`, `LanguageRebuilder` |
| `core_contracts` | Reutilizado y **ampliado** | Contrato de plugin y ciclo de vida (ver §5.3) |
| `core_audio` | Nuevo | Contrato `AudioPlayback`: reproducir en bucle, volumen, fundidos. Tests de contrato y doble en memoria |
| `core_alarm_scheduler` | Nuevo | Contrato para programar y cancelar alarmas exactas que suenan aunque la app esté cerrada |
| `core_battery` | Nuevo | Contrato `BatteryReader`: nivel, estado de carga y temperatura como stream |
| `core_display` | Nuevo | Contrato `DisplayControl`: mantener encendida, brillo, modo inmersivo |
| `design_system` | Nuevo, con la estructura de tokens de home_tasks | Tokens de día y noche, tipografía de reloj, componentes del §3.2 |

### 5.3 Contrato de plugin para un aparato

El `HomePlugin` de home_tasks está pensado para un inicio con tarjetas (`buildDashboardTile`). Aquí el inicio es el reloj, así que hace falta otra forma de colaborar. Propuesta en `core_contracts`:

- `HomePlugin` igual que hoy (id, versión, `isAvailable`, `initialize`, `routes`, `dispose`), sin `buildDashboardTile` obligatorio.
- `HomePluginEntryRoute`, igual: la pantalla de cada modo.
- Nuevo `AmbientStatusSource`: el plugin publica un stream de **cápsulas de estado** como datos (icono, texto, prioridad, urgencia). El reloj las dibuja con el sistema de diseño. Así el temporizador de cocina, la próxima alarma y la batería aparecen en el reloj sin que el reloj importe ningún plugin.
- Nuevo `AmbientAlertSource`: avisos a pantalla completa o banner (alarma sonando, temporizador terminado, batería crítica), con prioridad para decidir cuál se muestra si coinciden dos.

Esto obliga a sacar `core_contracts` de home_tasks a un lugar compartido o a crear una versión propia (pregunta 1 del §9).

### 5.4 Adaptadores

| Adaptador | Contrato | Tecnología |
| :--- | :--- | :--- |
| `audio_just_audio` | `AudioPlayback` | `just_audio` (bucle sin cortes) |
| `alarm_scheduler_alarm` | `core_alarm_scheduler` | Paquete `alarm` (alarmas exactas, pantalla completa, reinicio) |
| `battery_android` | `BatteryReader` | `battery_plus` y un canal nativo pequeño para la temperatura |
| `display_android` | `DisplayControl` | `wakelock_plus`, `screen_brightness`, `SystemChrome` |
| `storage_isar` | Repositorios | Reutilizado desde `flutter_packages`, con `isar_community` 3.4.1 (§11) |
| `settings_shared_preferences` | `AppSettingsRepository` | `shared_preferences` |

Cada contrato con varias implementaciones posibles trae sus tests de contrato en `testing.dart`, y el adaptador los pasa.

## 6. Fase 4: plugins

Orden de construcción: el que tiene más riesgo primero.

| # | Funcionalidad | Paquetes | Notas |
| :--- | :--- | :--- | :--- |
| 1 | **Alarma** | `alarm_domain`, `plugin_alarm`, `alarm_isar`; publica `alarm_contract` | Es lo más delicado. Prueba real en el teléfono: pantalla apagada, app cerrada, reinicio |
| 2 | **Reloj** | `plugin_clock` | Distribución B, horario día y noche, cápsulas de otros plugins. Cálculo del degradado según la luminosidad de la foto |
| 3 | **Batería** | `battery_guard_domain` (reglas puras: umbrales, margen, horario silencioso, "no llega a la alarma"), `plugin_battery_guard` | Consume `alarm_contract` para la próxima alarma |
| 4 | **Sonidos** | `plugin_ambient_sounds` | Sonidos como assets. Preferencias pequeñas, sin base de datos |
| 5 | **Cocina** | `kitchen_timer_domain`, `plugin_kitchen_timer`, `kitchen_timer_isar`; publica `kitchen_timer_contract` | Guarda la hora de fin, no el tiempo restante, para sobrevivir a un reinicio. Usa `core_alarm_scheduler` para sonar aunque la app muera |
| 6 | **Fotos** | `photo_frame_domain` (orden, rotación, recorte), `plugin_photo_frame`, `photo_source_local_folder`; publica `photo_frame_contract` | El reloj pide la foto actual a la capacidad; las fotos llegan por USB a una carpeta |

Por cada plugin:

1. Dominio en Dart puro con 100 % de cobertura.
2. Plugin con casos de uso (100 % de cobertura), UI con el sistema de diseño, i18n en español e inglés y su app de `example/`.
3. Adaptador que pasa los tests de contrato.
4. Prueba en el Mate 20 Lite antes de pasar al siguiente.

Comunicación entre plugins, como en home_tasks: eventos para hechos (`AlarmRang`, `TimerFinished`) y capacidades para consultas (`NextAlarmQuery`, `ActiveTimersQuery`, `CurrentPhotoQuery`). Ningún plugin importa a otro.

## 7. Fase 5: app y modo aparato

- **Launcher:** la actividad declara `HOME` y `DEFAULT` en el manifiesto. Al elegirla como inicio arranca sola al encender y el botón de inicio siempre vuelve al reloj.
- **Modo inmersivo** permanente y pantalla siempre encendida mientras carga.
- **Ajustes** detrás de una pulsación larga de 2 segundos sobre la hora.
- **Navegación:** deslizar entre Reloj, Sonidos y Cocina. Alarma y Fotos se abren desde Ajustes. Tras un minuto sin tocar, vuelve al reloj.
- **Android:** minSdk 24, que cubre Android 10. Permisos de alarma exacta, notificaciones de pantalla completa y arranque al encender.
- **Huawei:** guía de un paso para desactivar la gestión automática en *Batería → Inicio de aplicaciones*.
- **Tests:** `AppHarness` con adaptadores falsos y tests de integración en el teléfono.
- **Entrega:** APK de release instalada por `adb install`.

## 8. Fase 6: base 3D

Va en paralelo en otro chat, con el prompt de `hardware/stand/PROMPT_base_3d.md`. Lo que sigue es el resumen.

- OpenSCAD paramétrico en `hardware/stand/`, para el teléfono en horizontal y con el ángulo de lectura como parámetro.
- Canal para USB-C en el costado derecho (el conector queda de lado en horizontal), ventilación detrás de la batería y apoyo de goma.
- PETG. Medidas del teléfono confirmadas con calibrador antes de imprimir.

## 9. Decisiones

| # | Tema | Decisión |
| :--- | :--- | :--- |
| 1 | Paquetes compartidos | En `flutter_packages`, versionados por etiqueta git con `tag_pattern` (ver §10) |
| 2 | Identidad visual | Tema propio con **modo claro y oscuro**, misma estructura de tokens que home_tasks, sin la paleta morada. El **modo noche** del reloj es aparte: siempre negro y ámbar, sea cual sea el tema |
| 3 | Nombre | **Alba**. Repo `alba_home`, app en `apps/alba`, paquete Android `com.<usuario>.alba` |
| 4 | Idiomas | Español e inglés |
| 5 | Penpot | Archivo nuevo para este proyecto |
| 6 | Base de datos | `isar_community` 3.4.1 (ver §11) |
| 7 | Base 3D | En paralelo, en otro chat, con `hardware/stand/PROMPT_base_3d.md` |

Con el modo claro y oscuro, cada pantalla de Penpot del §3.2 que no sea el reloj de noche va en tres variantes cuando aplique: **claro**, **oscuro** y, en el reloj, **noche**.

## 10. Versionado de los paquetes compartidos

**Requisito:** un cambio en un paquete compartido nunca obliga a tocar home_tasks ni ningún otro proyecto. Cada proyecto decide cuándo se actualiza.

**Propuesta: repositorio `flutter_packages` con etiquetas por paquete y dependencias git resueltas por versión** (Dart 3.9 o posterior; los dos proyectos usan `^3.11`).

- `flutter_packages` es un monorepo Melos con un paquete por carpeta, SemVer y CHANGELOG propios.
- Cada versión publicada es una etiqueta `<paquete>-v<versión>` (p. ej. `core_di-v1.2.0`). Es el formato que ya crea `melos version`.
- Cada proyecto depende con un **rango**, como si fuera pub.dev:

  ```yaml
  core_di:
    git:
      url: git@github.com:<usuario>/flutter_packages.git
      path: packages/core/core_di
      tag_pattern: core_di-v{{version}}
    version: ^1.2.0
  ```

- **Por qué cumple el requisito:** si sale `core_di` 2.0.0, home_tasks sigue en `^1.2.0` y no se entera. Las correcciones 1.2.x le llegan solo cuando ejecute `pub upgrade`, y el `pubspec.lock` versionado de la app lo deja fijo hasta entonces.
- **Trabajar en un paquete y en un proyecto a la vez:** un `pubspec_overrides.yaml` local (ignorado por git) apunta el paquete a su carpeta en disco. Al terminar se publica la etiqueta y se borra el override.
- **Migración de home_tasks:** no hace falta tocarlo ahora. Sigue con sus copias locales y migra paquete por paquete cuando quiera, en sus propias ramas.

Alternativas descartadas o para más adelante:

| Opción | Ventaja | Por qué no ahora |
| :--- | :--- | :--- |
| Registro pub privado (OnePub, Cloudsmith, servidor propio) | Rangos de versión reales, `dart pub publish`, página por paquete | Costo o servidor que mantener. Tiene sentido si algún día hay más personas |
| Git con `ref:` fijo a una etiqueta | Funciona en cualquier versión de Dart | Sin rangos: cada parche hay que subirlo a mano en cada proyecto |
| Copiar los paquetes en cada repo | Cero infraestructura | Las copias se separan y las correcciones no se comparten |
| Dependencias por ruta entre repos | Inmediato | Acopla los repos: un cambio rompe al otro sin aviso, justo lo que quieres evitar |

## 11. Base de datos

Los datos son pocos: unas diez alarmas, tiempos guardados de cocina, temporizadores en marcha y el orden de las fotos. Gracias a los adaptadores y los tests de contrato, la elección se puede cambiar después sin tocar los plugins.

| Opción | Versión (nov. 2026) | Tipo | A favor | En contra |
| :--- | :--- | :--- | :--- | :--- |
| **`isar_community`** | 3.4.1 estable (no hay 4.x estable) | NoSQL nativo | Reutiliza `storage_isar` y lo que ya sabes de home_tasks. La 3.4.0 añade Swift Package Manager y corrige una fuga de memoria nativa, sin cambios incompatibles | Lo mantiene la comunidad tras el abandono del Isar original: riesgo a largo plazo |
| `drift` | 2.35.4 | SQLite con código generado | El más mantenido y usado (Flutter Favorite), consultas reactivas, migraciones explícitas | Adaptadores nuevos desde cero (`storage_drift`, `<funcionalidad>_drift`) |
| `objectbox` | 5.3.2 | NoSQL nativo | Rápido, relaciones, Apache-2.0 | Sincronización de pago. Otra tecnología más que aprender |
| `hive_ce` | 2.23.3 | Clave-valor en Dart puro | Sin código nativo, muy simple | Sin consultas reales. Para alarmas y temporizadores se queda corto |
| `sembast` | — | NoSQL en Dart puro | Simple, sin nativo | Menos rendimiento. Poco que ganar frente a Isar aquí |
| Realm | — | — | — | Descontinuado por MongoDB: descartado |

**Recomendación:** `isar_community` **3.4.1**, reutilizando `storage_isar` desde `flutter_packages`. Si más adelante quieres reducir el riesgo, `drift` es la salida natural, y este proyecto, con tan pocos datos, sería un buen lugar para probar el cambio de motor. home_tasks puede seguir en 3.3.2 o subir cuando quiera.

## 12. Para una siguiente versión

- **Canciones propias para alarmas y recordatorios.** Una carpeta local dedicada a la que llegan por USB, como las fotos. La alarma guarda la ruta de la canción, sin copiarla, para que cambiar o sustituir el archivo se note. Como Alba es el launcher y está siempre abierto, el plugin comprueba el archivo poco antes de cada alarma (y al programarla); si falta, la reprograma con el tono de alarma del sistema. Queda el riesgo de que se borre en ese último margen, en el que el paquete `alarm` sonaría en silencio y solo vibraría.
