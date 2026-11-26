# Changelog

## 0.1.1 - 2026-11-23

### Corregido

- Una alarma de una sola vez que sonaba con la app cerrada seguía activa y pasaba al día siguiente. Ahora `SyncAlarmSchedule` guarda el instante para el que la programa y, si al arrancar ya pasó, la desactiva, como al apagarla.
- Al arrancar porque una alarma está sonando, la sincronización ya no la reprograma (eso la cortaba): espera a que `HandleAlarmRang` abra su sesión.

## 0.1.0 - 2026-11-22

### Añadido

- `AlarmPlugin`: lista, edición, días, descartar cambios, alarma sonando con «mantén para apagar» y pospuesta (pantallas 03.1 a 03.8), en español e inglés y con TalkBack.
- Casos de uso: crear, editar, borrar, activar, sincronizar con Android, sonar, posponer y apagar.
- `NextAlarmQuery`, cápsulas (`AmbientStatusSource`) y avisos (`AmbientAlertSource`) para el reloj; eventos `AlarmRang`, `AlarmSnoozed` y `AlarmDismissed`.
- Tres sonidos propios generados con `tool/generate_sounds.py`.
- App de ejemplo con todo en memoria.
