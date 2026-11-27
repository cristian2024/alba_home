# clock_domain

Dominio del reloj, en Dart puro.

- `NightSchedule`: cuándo es de noche (por defecto de 22:30 a 6:45, 08.2), en hora local (`LocalTime`). La pantalla se funde a negro en los 30 min anteriores y vuelve al día en los 15 posteriores.
- `NightPhases.at`: la fase de un instante (`NightPhase` de `clock_contract`): día, atardecer con cuánto de noche hay y a qué hora empieza, noche y amanecer. Usa el `WallClock` de `wall_clock`.
- `PhotoScrim`: la opacidad del degradado sobre la foto. El diseño usa el 72 %; con fotos más claras que la de nieve sube lo justo para que la hora se lea a 7:1.
- `NightScheduleRepository`, con `nightScheduleRepositoryContract` e `InMemoryNightScheduleRepository` en `testing.dart`.
