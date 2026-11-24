# Changelog

## 0.1.1 - 2026-11-23

### Corregido

- Los sonidos de otros paquetes (`packages/<paquete>/assets/…`) no sonaban: `alarm` los buscaba como archivo y la alarma quedaba muda. Ahora `AppDocumentsSoundFiles` copia el asset a los documentos de la app antes de programar y `alarm` reproduce esa copia.
- Si el sonido no se puede preparar, suena el tono de alarma del sistema en lugar de nada.

### Añadido

- `AlarmSoundFiles` y `AlarmSchedulerModule(soundFiles:)` para elegir dónde quedan los sonidos.

## 0.1.0 - 2026-11-22

### Añadido

- `AlarmSchedulerModule`: `AlarmScheduler` sobre el paquete `alarm` 5.15.0 y `permission_handler`, que pasa `alarmSchedulerContract`.
