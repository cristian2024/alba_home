# core_alarm_scheduler

Contrato para programar alarmas exactas que suenan aunque la app esté cerrada, la pantalla apagada o el teléfono se haya reiniciado. Dart puro. Lo usan la alarma y los temporizadores de cocina; el adaptador real es `alarm_scheduler_alarm`.

## Contenido

- `AlarmScheduler`:
  - `schedule(alarm)`: programa o sustituye por id (si estaba sonando, deja de sonar).
  - `cancel(id)` y `stop(id)`.
  - `scheduled()`: las pendientes, de la más próxima a la más lejana.
  - `watchRinging()`: las que suenan, en el orden en que empezaron.
  - `permissions()` y `requestPermissions()`.
- `ScheduledAlarm`: un disparo único con hora UTC, textos de la notificación, sonido, volumen, subida (`fadeIn`), vibración y bucle. Repetir o posponer lo decide quien la programa.
- `AlarmPermissions`: alarmas exactas, notificaciones y pantalla completa. Sin alarmas exactas la alarma no suena a su hora (`canRing`).
- `AlarmValidation`: rechaza horas pasadas o fuera de UTC, volúmenes fuera de rango y fundidos negativos.

## Uso

```dart
await scheduler.schedule(ScheduledAlarm(
  id: alarm.id,
  at: nextRing,
  title: 'Trabajo',
  soundAsset: 'assets/sounds/sunrise.ogg',
  fadeIn: const Duration(minutes: 1),
));

// Posponer: el mismo id, diez minutos después.
await scheduler.schedule(ringing.copyWith(at: clock.nowUtc().add(const Duration(minutes: 10))));
```

## Tests

`package:core_alarm_scheduler/testing.dart` trae `alarmSchedulerContract`, que toda implementación debe pasar (los tests de alarmas sonando, si la implementación sabe dispararlas), e `InMemoryAlarmScheduler`. En el doble las alarmas no suenan solas: el test usa `fire(id)` o avanza un `FixedClock` y llama a `fireDue()`. Los permisos se fijan con `currentPermissions` y `permissionsAfterRequest`.

```sh
dart test
```
