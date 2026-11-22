# Prompt para el chat de desarrollo de Alba

Copia todo lo que está debajo de la línea en un chat nuevo de este workspace (`/Users/daniel/Documents/projects/phone_work`).

---

Vas a llevar el **desarrollo completo de Alba**: fases 3, 4 y 5 de `PLAN.md`. Es decir, la base del monorepo, los plugins y la app en modo aparato. Alba convierte un Huawei Mate 20 Lite (Android 10, EMUI 10) en un reloj de mesa de noche y cocina: siempre en horizontal, siempre enchufado, sin internet y como pantalla de inicio del teléfono.

El diseño (fase 1) y su auditoría con Impeccable (fase 2) ya están terminados y aprobados. La base 3D va en otro chat: no toques `hardware/` ni `design/penpot/`.

## Lee antes de planificar

1. La skill **`flutter-guidelines`**, entera, y sus referencias según toque. Son reglas obligatorias.
2. `PLAN.md`: §5 (monorepo, núcleo, contrato de plugin, adaptadores), §6 (plugins y orden), §7 (modo aparato), §9 (decisiones), §10 (versionado de paquetes compartidos) y §11 (base de datos).
3. `design/TRASPASO_orquestacion.md`: qué entregó el diseño y las indicaciones para Flutter (§4).
4. `design/NOTA_diseno.md`, `DESIGN.md` (raíz) y `.impeccable/design.json`: reglas del sistema de diseño.
5. `design/referencia_penpot/tokens.json` (valores por tema, con el nombre Dart propuesto) y `spec.json` (estructura de cada pantalla con nombres de token). Los PNG de `claro/`, `oscuro/` y `noche/` son la referencia visual.
6. Como modelo de convenciones: `/Users/daniel/Documents/projects/home_tasks/CLAUDE.md`, su `tool/` (`analyze.dart`, `verify_architecture.dart`, `test_changed.sh`) y la configuración Melos de su `pubspec.yaml`. Alba sigue las mismas pautas. **home_tasks no se modifica**: solo se lee y se copia.

## Decisiones ya tomadas

- Monorepo Melos 8 con pub workspaces, `flutter_bloc`, `go_router`, `get_it` envuelto en `ServiceLocator`, `slang` con textos inyectados por el consumidor, `equatable`, tipos explícitos, verificador de arquitectura, SemVer y CHANGELOG por paquete, una rama por proyecto.
- Base de datos: `isar_community` **3.4.1**, solo en adaptadores.
- Idiomas: español e inglés.
- Temas: claro, oscuro y **noche** (`night.*`), que es aparte y no depende de los otros dos.
- Paquetes compartidos (`core_di`, `core_events`, `core_utils`, `core_ui`, `core_contracts`, `storage_isar`) en **`flutter_packages`**, versionados con etiquetas `<paquete>-v<versión>` y consumidos por **dependencia git con `tag_pattern` y un rango de versión** (PLAN §10). Para trabajar en un paquete compartido y en Alba a la vez se usa un `pubspec_overrides.yaml` local, ignorado por git.
- El contrato de plugin se amplía con **cápsulas de estado** (`AmbientStatusSource`) y **avisos** (`AmbientAlertSource`), y `buildDashboardTile` deja de ser obligatorio (PLAN §5.3). Los 9 niveles de prioridad de avisos están en la pantalla 09.2 del diseño.

## Cosas a resolver al empezar (pregúntame)

1. **`flutter_packages` ya existe** (`git@github.com:cristian2024/flutter-packages.git`) con una estructura vieja: Melos 6, SDK `^3.6.0` y los paquetes `core`, `state_management` y `ui_kit`. Propón cómo llevarlo a Melos 8 con workspaces y dónde van los paquetes que se extraen de home_tasks, sin romper lo que ya hay. Espera mi visto bueno antes de tocar ese repo.
2. **Repositorio de Alba:** `phone_work` aún no es un repo git. Pregúntame el nombre (el plan dice `alba_home`), el remoto y si se renombra la carpeta.
3. **Dos detalles abiertos del diseño** (TRASPASO §5): si «Nueva» y «Guardar» de Alarma suben de 48 a 72, y qué texto se usa para el aviso de noche «no llega a la alarma» (02.6n y 07.5n dicen cosas distintas).
4. **Identificador Android** (`com.<algo>.alba`).

## Cómo trabajar

Por fases y con puertas: no pases a la siguiente sin mi visto bueno.

### Fase 3: base

1. Extraer o crear en `flutter_packages` los paquetes compartidos, con sus tests y su primera etiqueta.
2. Crear el workspace de Alba: estructura del PLAN §5.1, tooling en `tool/`, `analysis_options.yaml` y CI copiados y adaptados de home_tasks.
3. Crear los contratos nuevos (`core_audio`, `core_alarm_scheduler`, `core_battery`, `core_display`), cada uno con sus tests de contrato y su doble en memoria en `testing.dart`.
4. Crear `design_system` generado desde `tokens.json`: temas claro, oscuro y noche, estilos de texto con Inter incluida como asset y cifras tabulares en la hora, y los componentes de `spec.json`. Haz una app de `example/` tipo galería para compararla con las hojas de `design/referencia_penpot/hojas/`.
5. Puerta: `melos run verify` en verde.

### Fase 4: plugins

Orden del PLAN §6: **alarma → reloj → batería → sonidos → cocina → fotos**. Para cada uno:

1. Dominio en Dart puro, casos de uso y adaptador, con la cobertura que piden las reglas y los tests de contrato.
2. UI con `design_system`, fiel a los PNG de referencia, con textos en `slang` y accesibilidad (etiquetas de TalkBack según las notas de cada página del diseño).
3. **Antes de pedirme el visto bueno**, compara la UI implementada con su PNG de referencia (capturas del teléfono o del emulador a 891 × 411, en claro, oscuro y noche) usando Impeccable, y corrige lo que encuentre.
4. Prueba en el Mate 20 Lite con `adb`. La alarma, además: pantalla apagada, app cerrada y después de reiniciar.
5. Puerta: `melos run verify` en verde más mi visto bueno.

### Fase 5: app y modo aparato

Launcher (`HOME`), modo inmersivo, pantalla encendida, ajustes con pulsación larga de 2 s, vuelta al reloj tras 1 min, permisos de alarma exacta y pantalla completa, guía de Huawei (pantalla 08.5) y APK de release. Puerta: una semana de uso real sin fallos de alarma.

## Reglas de proceso

- Commits, push y PRs **solo cuando yo lo pida**, sin atribución a Claude, con los textos de PR que dicta la skill.
- Si una regla no es viable o cuesta más de lo que aporta, dilo y explica por qué, en vez de forzarla o saltarla en silencio.
- Si algo del diseño no se puede implementar tal cual o choca con Flutter o Android, avísame antes de desviarte.
- Lleva una bitácora en `ESTADO_desarrollo.md` (raíz): fase actual, qué está hecho y verificado, pendientes y decisiones. Ponla al día al cerrar cada puerta, para poder retomar en otro chat.
- Cuando pregunte «¿en qué quedamos?», responde con estado **y** pendientes.
- Si una parte se puede hacer en paralelo en otro chat (por ejemplo, un plugin que no depende de los demás), propónmelo con un prompt listo para pegar. Yo manejo los chats.
