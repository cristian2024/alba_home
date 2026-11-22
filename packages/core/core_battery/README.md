# core_battery

Contrato para leer la batería del aparato: nivel, estado de carga y temperatura. Dart puro. Lo usa el aviso de batería; el adaptador real es `battery_android`.

## Contenido

- `BatteryReader`: `current()` y `watchStatus()`. El stream emite la lectura actual al suscribirse y no repite lecturas iguales seguidas.
- `BatteryStatus`: `level` (0 a 100), `state` y `temperatureCelsius` (puede ser `null`). `isPluggedIn` es cierto con el cargador conectado, cargue o no.
- `BatteryChargeState`: `charging`, `discharging`, `full`, `notCharging` (enchufado pero sin cargar) y `unknown`.

## Uso

```dart
reader.watchStatus().listen((BatteryStatus status) {
  if (!status.isPluggedIn && status.level <= 20) {
    // Batería baja.
  }
});
```

## Tests

`package:core_battery/testing.dart` trae `batteryReaderContract`, que toda implementación debe pasar, e `InMemoryBatteryReader`, cuya lectura fija el test con `set`.

```sh
dart test
```
