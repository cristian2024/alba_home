# Changelog

## 0.2.0+2 - 2026-11-23

### Añadido

- Composición de la alarma: `IsarStorage` con `AlarmIsar`, `AlarmSchedulerModule` y `AlarmPlugin`, con su ciclo de vida.
- `AmbientHost` y `AmbientAlertNavigator`: el aviso a pantalla completa que gana (la alarma sonando) abre su pantalla esté donde esté la app.
- Tema claro y oscuro de `design_system`, idioma del sistema y cambio de idioma en las páginas abiertas.
- Mientras no exista el reloj, el inicio lleva a la lista de alarmas.

### Cambiado

- `compileSdk` 37, que exige `permission_handler`.

## 0.1.0+1 - 2026-11-22

### Añadido

- App inicial: arranca en horizontal, prepara el `ServiceLocator` de `core_di` y muestra el nombre sobre negro.
- Android con `minSdk` 24 y etiqueta «Alba».
