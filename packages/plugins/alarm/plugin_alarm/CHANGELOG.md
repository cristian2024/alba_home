# Changelog

## 0.1.0 - 2026-11-22

### Añadido

- `AlarmPlugin`: lista, edición, días, descartar cambios, alarma sonando con «mantén para apagar» y pospuesta (pantallas 03.1 a 03.8), en español e inglés y con TalkBack.
- Casos de uso: crear, editar, borrar, activar, sincronizar con Android, sonar, posponer y apagar.
- `NextAlarmQuery`, cápsulas (`AmbientStatusSource`) y avisos (`AmbientAlertSource`) para el reloj; eventos `AlarmRang`, `AlarmSnoozed` y `AlarmDismissed`.
- Tres sonidos propios generados con `tool/generate_sounds.py`.
- App de ejemplo con todo en memoria.
