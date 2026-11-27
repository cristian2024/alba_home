# plugin_clock

Plugin del reloj de Alba: la pantalla principal.

## Composición

La app registra en el `ServiceLocator`:
- `NightScheduleRepository`, con `ClockIsar`;
- opcionalmente `Clock`, `WallClock` (de `wall_clock`), `CurrentPhotoQuery` (las fotos) y un `AmbientFeed` (los bloques y avisos de todos los plugins, que implementa la app).

Después crea `ClockPlugin(locator: …, settingsRoute: …)`, llama a `initialize()` y añade `plugin.routes` a su `GoRouter`. Mantener la hora 2 s abre `settingsRoute`.

## Qué publica

- `NightModeQuery` (de `clock_contract`): la fase de noche según el horario. La app la usa para el tono de noche y las horas de silencio de los avisos.
- `AmbientStatusSource`: el bloque «22:30 · Modo noche» en los 30 min anteriores a la noche.

## Pantallas

| Ruta | Pantallas | Qué es |
| :--- | :--- | :--- |
| `/clock` | 02.1 a 02.9 | El reloj: foto con su degradado (o fondo liso sin fotos), fecha, hora, hasta dos bloques y el banner que gane. Se funde a negro antes de la noche y va en negro y ámbar de noche. Mantener la hora abre ajustes; un toque corto muestra la pista |
| `/clock/night-schedule` | 08.2 | Horario de noche, con ruedas; se guarda al girar |

El degradado sobre la foto sigue el 72 % del diseño y sube si una foto lo pidiera para que la hora se lea a 7:1 (`PhotoScrim` de `clock_domain`, con la luminancia de la mitad inferior de la foto).

Textos en español e inglés con slang. `example/` lleva el reloj en memoria con botones para saltar a la hora de cada pantalla.
