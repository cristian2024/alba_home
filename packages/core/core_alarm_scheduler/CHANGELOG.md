# Changelog

## 0.1.0 - 2026-11-22

### Añadido

- `AlarmScheduler`: programar, cancelar y detener alarmas exactas, ver las pendientes y las que suenan, y consultar o pedir los permisos. `ScheduledAlarm`, `AlarmPermissions` y `AlarmValidation`.
- `package:core_alarm_scheduler/testing.dart`: tests de contrato `alarmSchedulerContract` e `InMemoryAlarmScheduler`, que dispara las alarmas con `fire` o `fireDue`.
