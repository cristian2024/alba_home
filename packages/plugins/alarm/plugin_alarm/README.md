# plugin_alarm

Plugin de alarma de Alba.

## Composición

La app registra en el `ServiceLocator`:
- `AlarmRepository`, con `AlarmIsar`;
- `AlarmScheduler`, con `AlarmSchedulerModule`;
- opcionalmente `Clock`, `IdGenerator`, `WallClock` y `EventBus`.

Después crea `AlarmPlugin(locator: …)`, llama a `initialize()` y añade `plugin.routes` a su `GoRouter`. Durante el horario de noche, envuelve las pantallas en `AppToneScope(tone: AppTone.night)`.

## Con la app cerrada

Android hace sonar la alarma aunque la app no esté abierta. Al arrancar, el plugin sincroniza lo guardado con lo programado:
- una alarma de una sola vez cuya hora ya pasó sonó (o se perdió con el teléfono apagado) y queda desactivada;
- una que se repite pasa a su próxima vez;
- la que está sonando en ese momento no se toca: la atiende la pantalla de alarma sonando.

## Qué publica

- `NextAlarmQuery`: la próxima alarma y si Android la deja sonar. Lo usan el reloj y la batería.
- `AmbientStatusSource`: la próxima alarma (o la pospuesta, o «No sonará») como bloque.
- `AmbientAlertSource`:
  - la alarma sonando, a pantalla completa (prioridad 1), con las acciones posponer y apagar;
  - el aviso de alarmas bloqueadas (prioridad 4), con la acción activar.
- Los eventos `AlarmRang`, `AlarmSnoozed` y `AlarmDismissed`.

## Pantallas

| Ruta | Pantallas | Qué es |
| :--- | :--- | :--- |
| `/alarm` | 03.1, 03.2 y 03.7 | Lista |
| `/alarm/new` y `/alarm/:id/edit` | 03.3, 03.3b y 03.4 | Edición, con descartar cambios y días |
| `/alarm/ringing` | 03.5, 03.5b y 03.5n | Alarma sonando |
| `/alarm/snoozed` | 03.6b | Alarma pospuesta |

Los diálogos de nombre, sonido y posposición no tienen diseño en Penpot. Están hechos con componentes de `design_system`.

## Sonidos

`assets/sounds/*.wav`: Amanecer suave, Campana y Pulso. Son propios, generados con `python3 tool/generate_sounds.py`.

## Tests

- Casos de uso al 100 %.
- Pantallas a 891 × 411, con Inter cargada.
- El plugin con dobles en memoria.

`example/` monta todo en memoria, con un botón para hacer sonar la próxima alarma.
