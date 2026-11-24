# alarm_scheduler_alarm

Adaptador de `core_alarm_scheduler` sobre el paquete `alarm` 5.15.0 y `permission_handler`. La app elige `AlarmSchedulerModule`, que inicia `alarm` y registra `AlarmScheduler`.

## Cómo funciona

- **Ids:** el id de texto de cada alarma viaja en el `payload` de `alarm`. El id entero que pide `alarm` se calcula con FNV-1a, así que es siempre el mismo.
- **Varias a la vez:** pueden sonar varias alarmas juntas, aunque coincidan en el mismo segundo.
- **Sonido:** antes de programar, `AppDocumentsSoundFiles` copia el asset a `alarm_sounds/` en los documentos de la app y `alarm` reproduce esa copia, también tras reiniciar. `alarm` solo abre como asset las rutas que empiezan por `assets/`, así que el asset de otro paquete (`packages/plugin_alarm/…`) sonaría en silencio. Si la copia falla o no hay asset, suena el tono de alarma del sistema.
- **Volumen:** sube con `VolumeSettings.fade` y se fuerza aunque el teléfono esté bajo.
- **Orden:** el adaptador sigue el orden en que empiezan a sonar desde que se crea.
- **Pantalla completa (Android 14 o posterior):** se da por concedida, porque `permission_handler` no la consulta.

## Requisitos de la app

- Los permisos del `AndroidManifest.xml` de la guía de Android de `alarm`.
- `equatable ^3` forzado con `dependency_overrides`, porque `alarm` pide la 2.

## Tests

`alarm` y los permisos van detrás de interfaces. El contrato completo pasa con un `alarm` simulado, y la prueba real se hace en el teléfono.
