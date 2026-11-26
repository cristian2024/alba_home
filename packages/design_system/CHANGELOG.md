# Changelog

## 0.1.2 - 2026-11-26

### Corregido

- `AppFullScreenAlert` de noche: la acción principal va rellena en ámbar (`AppButtonVariant.nightPrimary`), como `Alert/FullScreen/Night` en Penpot; antes las dos acciones salían iguales.
- `AppFullScreenAlert` como página sin `Material` encima (p. ej. en una ruta propia) ya no subraya sus textos en amarillo: lleva su propio estilo de texto base.

## 0.1.1 - 2026-11-22

### Añadido

- `AppToneScope`: la app indica el tono (p. ej. noche) a las pantallas de debajo.
- `AppAlarmRow.blocked`: alarma bloqueada por Android, con el detalle en rojo y un escudo en lugar del interruptor (03.7).
- Fuente `AlbaIcons`, generada desde los trazados de Penpot con `tool/generate_icon_font.py`: cada `AppIconData` lleva su `iconData` para los contratos que piden un `IconData`, y `AppIcons.byCodepoint` vuelve del glifo al icono.

## 0.1.0 - 2026-11-22

### Añadido

- Tokens generados desde Penpot con `tool/generate_tokens.dart`: `AppColors`, `AppThemeColors` (claro y oscuro), `AppNightColors`, `AppSpacing`, `AppRadii`, `AppSizes`, `AppLayout`, `AppOpacity`, `AppTypography` (Inter con cifras tabulares) y los 58 `AppIcons`.
- `AppTheme.light`, `AppTheme.dark` y `AppTheme.night`, planos y sin sombras. `AppTone` y `AppUrgency` para elegir variantes.
- Componentes: `AppButton`, `AppIconButton`, `AppPressable`, `AppIcon`, `AppClockTime`, `AppStatusBlock`, `AppStatusCapsule`, `AppModeDots`, `AppAlertBanner`, `AppFullScreenAlert`, `AppTimerCard`, `AppSavedChip`, `AppAlarmRow`, `AppSwitch`, `AppDayToggle`, `AppSettingsRow`, `AppSettingsField`, `AppStepper`, `AppWheelPicker`, `AppSoundTile`, `AppEmptyState` y `AppPhotoScrim`.
- `registerDesignSystemLicenses()` con las licencias de Inter y Lucide.
- Los botones hacen una onda corta y tenue al pulsar (`AppPressable.splashColor`, `AppQuickRipple`).
- Galería en `example/` para comparar con las hojas de Penpot, con desplazamiento horizontal en las filas anchas.
