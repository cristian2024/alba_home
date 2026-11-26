# alarm_domain

Dominio de la alarma, en Dart puro.

- `Alarm`: hora local (`AlarmTime`), días de repetición (`Weekday`), sonido, subida, posposición (minutos y veces) y vibración. Sin días suena una sola vez y guarda el instante para el que se programó (`onceAt`), para saber si ya sonó con la app cerrada.
- `NextRing.after` y `NextRing.soonest`: la próxima vez que suena, con un `WallClock` inyectado (`SystemWallClock` en la app, `FixedOffsetWallClock` en los tests y en zonas sin cambio de hora como Colombia).
- `AlarmSession`: la que suena o está pospuesta, con las veces usadas («quedan 2»). `afterDismiss` desactiva las de una sola vez.
- `AlarmRepository`: el contrato de almacenamiento.

## Tests

`package:alarm_domain/testing.dart` trae `alarmRepositoryContract` e `InMemoryAlarmRepository`. `dart test`.
