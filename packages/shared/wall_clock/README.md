# wall_clock

La hora de reloj de pared del aparato, inyectable, en Dart puro.

- `WallClock`: de instante UTC a hora local (`toLocal`) y de hora local a instante UTC (`localToUtc`, que normaliza fechas fuera de rango).
- `SystemWallClock`: la zona del sistema, con sus cambios de horario. Es la de la app.
- `FixedOffsetWallClock`: una diferencia fija (Colombia, UTC−5). Para los tests, que así no dependen de la zona de la máquina.

Los dominios guardan instantes en UTC y piensan en hora local con un `WallClock` inyectado, igual que reciben un `Clock` de `core_utils` para «ahora».
