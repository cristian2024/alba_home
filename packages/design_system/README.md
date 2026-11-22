# design_system

Sistema de diseño de Alba, generado desde las exportaciones de Penpot (`design/referencia_penpot/`): tokens, temas claro, oscuro y noche, Inter con cifras tabulares, iconos y componentes accesibles. Solo depende de Flutter.

Los componentes no conocen la app: reciben los textos ya traducidos y devuelven lo que pasa con callbacks. La navegación, los cubits y los diálogos los pone la pantalla que los usa.

## Tokens generados

`lib/src/tokens/` sale de `tokens.json` y de los iconos de `spec.json` con un generador:

```sh
cd packages/design_system && dart run tool/generate_tokens.dart
```

Esos archivos no se editan a mano. Un test falla si no coinciden con el JSON, así que un cambio en Penpot se exporta, se regenera y se sube junto.

- `AppColors`: primitivos (`warm.50` → `warm50`).
- `AppThemeColors`: colores semánticos de claro y oscuro (`bg.surface-raised` → `bgSurfaceRaised`), como `ThemeExtension`. Se leen con `AppThemeColors.of(context)`.
- `AppNightColors`: ámbar sobre negro, iguales en los dos temas.
- `AppSpacing`, `AppRadii` (`2xLarge` → `x2xLarge`), `AppSizes`, `AppLayout` (lienzo de 891 × 411) y `AppOpacity`.
- `AppTypography`: los 13 estilos de Penpot (`clockHero` de 205 a `caption` de 14), con Inter del paquete y cifras tabulares en todos. Un `TextStyle` propio debe indicar `package: AppTypography.fontPackage`.
- `AppIcons`: los 58 iconos de Penpot (Lucide con el trazo convertido en relleno), dibujados con `AppIcon`.

## Temas

`AppTheme.light` y `AppTheme.dark` siguen el tema del sistema. `AppTheme.night` es el modo noche del reloj: fondo negro y texto ámbar.

El sistema es plano: no tiene sombras ni tinte de superficie. Al pulsar, el fondo baja un paso; los botones (`AppButton`, `AppIconButton`) hacen además una onda corta y tenue del color de su texto (`AppPressable.splashColor`, `AppQuickRipple`), y el resto de lo pulsable no.

Los componentes con variantes de Penpot reciben `AppTone`:
- `surface`: sobre el lienzo.
- `photo`: sobre la foto, con su degradado.
- `night`: modo noche.

`AppToneScope` lo pone la app sobre las pantallas durante el horario de noche, para que las que tienen variante de noche la elijan solas.

Los estados y avisos reciben además `AppUrgency`: `normal`, `warning` (ocre) o `urgent` (terracota, o rojo de noche).

## Componentes

| Componente | Penpot | Para qué |
| :--- | :--- | :--- |
| `AppButton` | `Button/Large`, `Button/Standard` | Píldora de 72 o 48 con icono opcional. Variantes `primary`, `secondary`, `ghost`, `danger`, `night` y `nightPrimary`. |
| `AppIconButton` | `Button/Icon72`, `Button/Icon48` | Círculo de 72 o 48. `semanticLabel` obligatorio («Pausar Pasta»). |
| `AppPressable` | — | La base de lo pulsable: color al pulsar, onda opcional (`splashColor`), anillo de foco de 3 px, semántica de botón y atenuado sin `onTap`. |
| `AppClockTime` | `Clock/Time/*` | La hora a 205, 160, 96 o 56, en cifras tabulares. |
| `AppStatusBlock` | `Status/Block/*` | Icono, valor y etiqueta, de 140 × 120, a los lados de la hora. |
| `AppStatusCapsule` | `Status/Capsule/*` | Píldora de 60 con icono y texto. Pulsable si recibe `onTap`. |
| `AppModeDots` | `Mode/Dots/*` | Puntos de modo; el actual, alargado. |
| `AppAlertBanner` | `Alert/Banner/*` | Banner de 96 con botón de 72 a 12 de los bordes. Variantes `info`, `warning`, `critical`, `photo` y `night`. |
| `AppFullScreenAlert` | `Alert/FullScreen/*` | Aviso que sustituye la pantalla, con una o dos `AppAlertAction`. |
| `AppTimerCard` | `Timer/Card/*` | Temporizador de 264 × 268: en marcha, en pausa, terminado o detenido con «Deshacer». |
| `AppSavedChip` | `Saved/Chip/*` | Tiempo guardado de cocina, píldora de 72. |
| `AppAlarmRow` | `Alarm/Row/*` | Fila de 96 con hora, nombre, días e interruptor. La fila y el interruptor son controles separados para TalkBack. Con `blocked`, detalle en rojo y escudo (03.7). |
| `AppSwitch` | `Settings/Switch/*` | Interruptor de 72 × 48. |
| `AppDayToggle` | `Day/Toggle/*` | Día de la semana, círculo de 64. |
| `AppSettingsRow`, `AppSettingsField` | `Settings/Row/*` | Fila de 80 con *chevron*, valor o interruptor; `attention` en ocre; campo de 72. |
| `AppStepper` | `Settings/Stepper` | Botones − y + de 48 alrededor de un valor. |
| `AppWheelPicker` | `Wheel/Picker/*` | Rueda de números sin teclado (opcionalmente en bucle). Se ajusta con subir y bajar en TalkBack. |
| `AppSoundTile` | `Sound/Tile/*` | Sonido de 196 × 156, seleccionado o no, también de noche. |
| `AppEmptyState` | `Empty/State` | Icono, título, explicación y acción opcional. |
| `AppPhotoScrim` | Degradado de la foto | 371 de alto, sólido al 72 % hasta el 42 %. |

### Diferencias con Penpot

- **La hora:** usa cifras tabulares, no una caja fija por dígito, como pide `DESIGN.md`. El espacio alrededor de los dos puntos es algo más estrecho.
- **Botón que ocupa el hueco** (`expand`): baja el relleno lateral a 16. Así cabe «1 min» en la tarjeta de temporizador, donde las cifras tabulares lo hacen más ancho que en Penpot.
- **Pulsado de `nightPrimary`:** baja a `night.text-secondary`, porque Penpot no define ese estado.
- **Onda en los botones:** `DESIGN.md` describe el pulsado solo como un cambio de fondo; la onda se añadió a petición, con el color del texto al 10 %, corta (`AppQuickRipple`: unos 250 ms).

## Licencias

- Inter 4.1 (SIL OFL 1.1, `assets/OFL-Inter.txt`).
- Lucide (ISC, `assets/LICENSE-Lucide.txt`).

Quien publica una app llama a `registerDesignSystemLicenses()` al arrancar.

## Galería y tests

`example/` es una galería con las mismas secciones que `design/referencia_penpot/hojas/01_componentes_<tema>.png` y un interruptor de tema. Las filas, más anchas que la pantalla, se desplazan en horizontal; un test comprueba que no desborda a 891 × 411 ni en vertical. Para compararla con las hojas a la misma escala:

```sh
cd packages/design_system/example
flutter test --dart-define=GALLERY_OUT=/ruta/de/salida
```

Eso guarda `galeria_claro.png` y `galeria_oscuro.png` a 2924 de ancho, como las hojas.

`flutter test` en el paquete comprueba los tokens contra el JSON, el parser de iconos, los temas y cada componente (medidas, estados, toques y semántica). Los tests cargan Inter (`test/flutter_test_config.dart`) para medir como en el aparato.
