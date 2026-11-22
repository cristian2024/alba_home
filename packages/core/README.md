# packages/core

Contratos transversales propios de Alba, en Dart puro: `core_audio` (reproducción con fundidos), `core_alarm_scheduler` (alarmas exactas), `core_battery` (lectura de la batería) y `core_display` (pantalla encendida, brillo e inmersivo).

Cada contrato trae sus tests de contrato y un doble en memoria en `testing.dart`; sus adaptadores van en `packages/adapters/`. Los contratos comunes con otros proyectos (`core_di`, `core_events`, `core_contracts`, `core_utils`, `core_ui`) vienen de [flutter_shared](https://github.com/cristian2024/flutter_shared).

Esta carpeta existe en todas las ramas aunque no tengan paquetes: la herramienta de Flutter falla al resolver el workspace si una carpeta del patrón `workspace:` no existe.
