# clock_contract

API pública del reloj, en Dart puro.

- `NightModeQuery.watchPhase()`: la fase de noche (`NightPhase`) según el horario del reloj: día, atardecer (se va fundiendo a negro, con la hora a la que empieza la noche), noche y amanecer. La app la usa para el tono de noche de todas las pantallas y para las horas de silencio de los avisos.

`package:clock_contract/testing.dart`: `nightModeQueryContract` e `InMemoryNightModeQuery`.
