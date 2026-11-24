# Changelog

## 0.2.0 - 2026-11-23

### Añadido

- `Alarm.onceAt` y `Alarm.armedFor`: una alarma sin repetición guarda el instante para el que se programó, para saber si ya sonó con la app cerrada. `copyWith` lo borra al cambiar la hora, los días o la activación.
- `alarmRepositoryContract` comprueba que `onceAt` se guarda.

## 0.1.0 - 2026-11-22

### Añadido

- `Alarm` con `AlarmTime` local y días `Weekday`; `NextRing` (próxima vez, con `WallClock`); `AlarmSession` (sonar y posponer con límite) y `afterDismiss`.
- `AlarmRepository` con `alarmRepositoryContract` e `InMemoryAlarmRepository` en `testing.dart`.
