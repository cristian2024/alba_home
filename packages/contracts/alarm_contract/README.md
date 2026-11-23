# alarm_contract

API pública de la alarma para otros plugins, en Dart puro.

- `NextAlarmQuery`: `watchNextAlarm()` (la próxima, o la pospuesta) y `watchCanRing()` (si Android deja sonar). La batería lo usa para «No llega a la alarma».
- Eventos: `AlarmRang`, `AlarmSnoozed`, `AlarmDismissed`.

`package:alarm_contract/testing.dart`: `nextAlarmQueryContract` e `InMemoryNextAlarmQuery`.
