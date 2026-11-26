# Changelog

## 0.1.2 - 2026-11-26

### Corregido

Diferencias con Penpot encontradas al comparar las pantallas a 891 × 411 en claro, oscuro y noche:

- La cabecera mide 72 aunque no haya botón de volver, y «Nueva» y «Guardar» son botones de 48 (03.1, 03.3).
- La lista vacía no repite «Nueva» en la cabecera, y «Nueva alarma» es grande (03.2).
- Con las alarmas bloqueadas, la cabecera no anuncia la próxima: no sonará (03.7).
- «Descartar» lleva la X, y el aviso de descartar cambios ya no subraya sus textos (03.3b).
- La pista «Toca en cualquier sitio para posponer» usa `type.label`; mientras se mantiene para apagar, deja sitio a la barra y el botón no se oscurece (03.5, 03.5b).
- Requiere `design_system` 0.1.2: de noche, «Apagar alarma» va rellena (03.6bn).

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
