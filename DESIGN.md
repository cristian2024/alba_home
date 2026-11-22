---
name: Alba
description: Reloj de casa para mesilla y cocina sobre un Huawei Mate 20 Lite en horizontal (891 × 411 dp), que no debe parecer un teléfono.
colors:
  amber-hearth: "#F2A230"
  amber-hearth-hover: "#E08A14"
  amber-hearth-pressed: "#BD6F0B"
  amber-ink: "#96560B"
  amber-ink-dark: "#F8BC55"
  amber-wash: "#FFF6E5"
  amber-wash-dark: "#2E1A07"
  cream-canvas: "#FAF6EF"
  cream-surface: "#FFFCF7"
  cream-sunken: "#F2ECE2"
  cream-border: "#E4DCCF"
  ink-primary: "#1F1B18"
  ink-secondary: "#6B6157"
  ink-tertiary: "#7A6F63"
  ink-on-brand: "#0B0A09"
  ember-canvas: "#141210"
  ember-surface: "#1F1B18"
  ember-raised: "#2A2521"
  ember-border: "#36302B"
  ember-text: "#F2ECE2"
  ember-text-secondary: "#ADA294"
  night-black: "#000000"
  night-amber: "#C8811F"
  night-amber-dim: "#8A5A18"
  night-amber-faint: "#2A1A08"
  night-red: "#9E3A2B"
  terracotta: "#A8412C"
  terracotta-wash: "#FCEEEA"
  olive: "#566D31"
  ochre: "#B47614"
  ochre-ink: "#73490D"
  ochre-wash: "#FCF3E3"
  slate: "#3F5970"
  photo-scrim: "#0B0A09B8"
  photo-veil: "#FFFCF71F"
  photo-edge: "#FFFCF733"
  photo-text: "#FFFCF7"
typography:
  clock-hero:
    fontFamily: "Inter, sans-serif"
    fontSize: "205px"
    fontWeight: 700
    lineHeight: 1
    letterSpacing: "-0.03em"
    fontFeature: "'tnum'"
  clock-large:
    fontFamily: "Inter, sans-serif"
    fontSize: "160px"
    fontWeight: 700
    lineHeight: 1
    letterSpacing: "-0.03em"
    fontFeature: "'tnum'"
  clock-medium:
    fontFamily: "Inter, sans-serif"
    fontSize: "96px"
    fontWeight: 700
    lineHeight: 1
    letterSpacing: "-0.02em"
    fontFeature: "'tnum'"
  clock-small:
    fontFamily: "Inter, sans-serif"
    fontSize: "56px"
    fontWeight: 700
    lineHeight: "60px"
    letterSpacing: "-0.01em"
    fontFeature: "'tnum'"
  display:
    fontFamily: "Inter, sans-serif"
    fontSize: "40px"
    fontWeight: 700
    lineHeight: "48px"
    letterSpacing: "-0.015em"
  title:
    fontFamily: "Inter, sans-serif"
    fontSize: "28px"
    fontWeight: 600
    lineHeight: "36px"
    letterSpacing: "-0.01em"
  subtitle:
    fontFamily: "Inter, sans-serif"
    fontSize: "26px"
    fontWeight: 500
    lineHeight: "32px"
  heading:
    fontFamily: "Inter, sans-serif"
    fontSize: "22px"
    fontWeight: 600
    lineHeight: "28px"
  body-large:
    fontFamily: "Inter, sans-serif"
    fontSize: "20px"
    fontWeight: 400
    lineHeight: "28px"
  body:
    fontFamily: "Inter, sans-serif"
    fontSize: "18px"
    fontWeight: 400
    lineHeight: "24px"
  label-large:
    fontFamily: "Inter, sans-serif"
    fontSize: "20px"
    fontWeight: 600
    lineHeight: "24px"
  label:
    fontFamily: "Inter, sans-serif"
    fontSize: "16px"
    fontWeight: 500
    lineHeight: "20px"
  caption:
    fontFamily: "Inter, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: "20px"
rounded:
  extra-small: "4px"
  small: "8px"
  medium: "12px"
  large: "16px"
  extra-large: "24px"
  2x-large: "32px"
  full: "999px"
spacing:
  s50: "2px"
  s100: "4px"
  s150: "6px"
  s200: "8px"
  s300: "12px"
  s400: "16px"
  s500: "20px"
  s600: "24px"
  s800: "32px"
  s1000: "40px"
  s1200: "48px"
  s1600: "64px"
  s2000: "80px"
components:
  button-large-primary:
    backgroundColor: "{colors.amber-hearth}"
    textColor: "{colors.ink-on-brand}"
    typography: "{typography.label-large}"
    rounded: "{rounded.full}"
    padding: "24px 32px"
    height: "72px"
  button-large-primary-pressed:
    backgroundColor: "{colors.amber-hearth-pressed}"
  button-large-secondary:
    backgroundColor: "{colors.cream-sunken}"
    textColor: "{colors.ink-primary}"
    typography: "{typography.label-large}"
    rounded: "{rounded.full}"
    padding: "24px 32px"
    height: "72px"
  button-standard-primary:
    backgroundColor: "{colors.amber-hearth}"
    textColor: "{colors.ink-on-brand}"
    typography: "{typography.label}"
    rounded: "{rounded.full}"
    padding: "14px 24px"
    height: "48px"
  button-icon-72-primary:
    backgroundColor: "{colors.amber-hearth}"
    textColor: "{colors.ink-on-brand}"
    rounded: "{rounded.full}"
    size: "72px"
  button-large-night:
    backgroundColor: "{colors.night-amber-faint}"
    textColor: "{colors.night-amber}"
    typography: "{typography.label-large}"
    rounded: "{rounded.full}"
    height: "72px"
  chip-saved:
    backgroundColor: "{colors.cream-surface}"
    textColor: "{colors.ink-primary}"
    typography: "{typography.label-large}"
    rounded: "{rounded.full}"
    padding: "24px"
    height: "72px"
  chip-saved-selected:
    backgroundColor: "{colors.amber-wash}"
    textColor: "{colors.amber-ink}"
  banner-photo:
    backgroundColor: "{colors.photo-scrim}"
    textColor: "{colors.photo-text}"
    rounded: "{rounded.large}"
    height: "96px"
    width: "827px"
  banner-warning:
    backgroundColor: "{colors.ochre-wash}"
    textColor: "{colors.ochre-ink}"
    rounded: "{rounded.large}"
    height: "96px"
    width: "827px"
  card-timer:
    backgroundColor: "{colors.cream-surface}"
    textColor: "{colors.ink-primary}"
    rounded: "{rounded.extra-large}"
    padding: "20px"
    width: "264px"
    height: "268px"
  row-alarm:
    backgroundColor: "{colors.cream-surface}"
    textColor: "{colors.ink-primary}"
    rounded: "{rounded.large}"
    padding: "18px 24px"
    height: "96px"
  row-settings:
    backgroundColor: "{colors.cream-surface}"
    textColor: "{colors.ink-primary}"
    typography: "{typography.body-large}"
    rounded: "{rounded.large}"
    padding: "16px"
    height: "80px"
---

# Design System: Alba

<!-- Fuente: exportación final de Penpot (design/referencia_penpot/tokens.json y spec.json, 2026-11-21). Los tokens del frontmatter son el tema claro resuelto a hex, con los valores clave del oscuro (-dark, ember-*) y de noche (night-*). La tabla completa de semánticos por tema está en tokens.json; esta página no la sustituye. -->

## Overview

**Creative North Star: "El reloj de la casa"**

Alba es un objeto doméstico, no un teléfono. Vive en la mesilla y en la encimera, siempre enchufado y siempre en horizontal. Se lee a dos metros, medio dormido o con las manos ocupadas. La hora y la foto mandan; todo lo demás aparece solo cuando hace falta y se va solo, porque a los 60 s sin tocar vuelve al reloj. No hay barra de estado, ni menús, ni listas largas, ni nada que recuerde a Android.

El mundo es cálido y de pocos materiales. De día y en oscuro se usan neutros crema y tierra con un único acento ámbar, el del fuego del hogar. De noche, todo es ámbar apagado sobre negro puro, para que la pantalla no deslumbre. Los controles son píldoras grandes y francas, planas, que se distinguen por color y por borde, no por relieve. La densidad es baja a propósito: una sola idea por pantalla.

Los tres temas comparten nombres de token. El claro y el oscuro intercambian valores; el de noche es un grupo propio (`night.*`) que no cambia con el tema y se activa por horario.

**Key Characteristics:**
- La hora domina el centro con Inter Bold a 205, con cifras tabulares.
- Un solo acento, ámbar `amber-hearth`, igual de día y en oscuro: botón principal con texto casi negro (9,4:1).
- Lo que se toca medio dormido o en la cocina mide 72; nada baja de 48.
- Plano: sin sombras. La profundidad la dan las superficies tonales, los bordes de 1 px y el degradado sobre la foto.
- Lienzo fijo de 891 × 411, márgenes de 32, separación de 16.

## Colors

Neutros cálidos de papel y brasa, un acento ámbar y estados en tonos tierra (terracota, oliva, ocre, pizarra) que nunca compiten con el acento.

### Primary
- **Ámbar de hogar** (`amber-hearth`): fondo del botón principal en claro y en oscuro, progreso de los temporizadores y la única llamada a la acción de cada pantalla. Al pulsar baja a `amber-hearth-pressed`.
- **Tinta ámbar** (`amber-ink`; `amber-ink-dark` en oscuro): texto de marca sobre lavado ámbar, como fichas seleccionadas, «Lista» en un temporizador terminado o el título «Dos listos».
- **Lavado ámbar** (`amber-wash`; `amber-wash-dark` en oscuro): fondo de lo seleccionado o terminado (tarjeta de temporizador acabado, ficha o sonido elegidos), siempre con borde `amber-hearth-pressed`.

### Secondary
- **Terracota** (`terracotta`, con `terracotta-wash`): peligro. Se usa en batería crítica, alarma bloqueada por Android y el banner rojo.
- **Ocre** (`ochre`, `ochre-ink`, `ochre-wash`): aviso. Es un tono distinto del ámbar de marca para que una cápsula de batería baja no se confunda con un botón.
- **Oliva** (`olive`) y **pizarra** (`slate`): éxito e información. Aparecen poco.

### Neutral
- **Lienzo crema** (`cream-canvas`): fondo de las pantallas sin foto en claro.
- **Superficie crema** (`cream-surface`): tarjetas, filas, fichas y banners informativos.
- **Crema hundida** (`cream-sunken`): botón secundario, pistas de progreso y teclado de referencia.
- **Borde crema** (`cream-border`): borde de 1 px de tarjetas y filas, que es el principal separador del sistema.
- **Tinta** (`ink-primary`, `ink-secondary`, `ink-tertiary`): texto, en orden de importancia. Contraste sobre el lienzo de 15,9:1, 5,6:1 y algo más de 4,5:1.
- **Brasa** (`ember-canvas`, `ember-surface`, `ember-raised`, `ember-border`, `ember-text`, `ember-text-secondary`): los mismos papeles en el tema oscuro.
- **Sobre foto** (`photo-scrim`, `photo-veil`, `photo-edge`, `photo-text`): degradado de `warm.1000` al 72 % detrás de la hora, velo blanco al 12 % detrás de los iconos y borde blanco al 20 % de los banners sobre foto.

### Night
- **Negro de noche** (`night-black`): fondo único de noche. El Mate 20 Lite es LCD: el negro no apaga píxeles, pero baja el brillo percibido.
- **Ámbar de noche** (`night-amber`): la hora y el texto principal.
- **Ámbar tenue** (`night-amber-dim`): texto secundario y bordes (3,6:1, por debajo de 4,5:1 a propósito).
- **Ámbar casi negro** (`night-amber-faint`): fondo de los botones de noche.
- **Rojo de noche** (`night-red`): solo para la alarma bloqueada y la batería que no llega (3,1:1).

### Named Rules
**The One Hearth Rule.** El ámbar es la única acción principal de la pantalla. Si hay dos botones ámbar compitiendo, uno sobra o pasa a secundario.

**The Ochre Is Not Amber Rule.** Un aviso nunca usa el ámbar de marca: lleva ocre, terracota o rojo de noche, para que una alerta no parezca un botón.

**The Dark Room Rule.** De noche no hay blanco, crema ni color saturado; solo ámbar sobre negro, y el rojo de noche para lo que despierta.

## Typography

**Display Font:** Inter (con sans-serif del sistema)
**Body Font:** Inter
**Label/Mono Font:** Inter con cifras tabulares (`tnum`) para toda cifra que cambie

**Character:** una sola familia, neutra y muy legible, con el 1 con bandera y el 7 recto. La personalidad está en la escala, no en la fuente: la hora es enorme y el resto queda contenido. Licencia SIL OFL 1.1.

### Hierarchy
- **Clock** (700; 205, 160, 96 y 56; interlineado 1; tracking de −3 % a −1 %): la hora del reloj y de noche (205), un temporizador solo (160), tarjetas y filas de alarma (96 y 56). Siempre con `tnum`.
- **Display** (700, 40/48): valores de los bloques de estado («6:30», «18 %») y títulos de avisos a pantalla completa.
- **Title** (600, 28/36): título de cabecera de cada pantalla.
- **Subtitle** (500, 26/32): la fecha encima de la hora, legible a ~1 m.
- **Heading** (600, 22/28): nombres en tarjetas y sonidos.
- **Body** (400; 20/28 y 18/24): texto de filas, banners y explicaciones.
- **Label** (600, 20/24 en botones de 72; 500, 16/20 en botones de 48 y en etiquetas de bloques).
- **Caption** (400, 14/20): detalles secundarios. Es el mínimo: no hay texto de interfaz por debajo de 14.

### Named Rules
**The Steady Clock Rule.** Toda cifra que cambia usa cifras tabulares y la hora se centra como bloque. En Penpot cada dígito va en una caja fija alineada a la izquierda; en Flutter no hay que copiar esas cajas, sino usar `FontFeature.tabularFigures()`.

**The Two-Metre Rule.** Lo que hay que leer desde la cama (hora, fecha, bloques de estado) no baja de 26, y la hora no baja de 7:1 sobre ninguna foto.

## Layout

El lienzo es fijo, de 891 × 411 dp en horizontal, sin desplazamiento y sin variante vertical. Los márgenes son de 32 y la separación entre elementos de 16; el espaciado sale de una escala de 4 (2 a 80). El reloj ocupa el centro; los bloques de estado (dos como máximo) se apoyan a izquierda y derecha en la banda inferior, alineados con la base de la hora. Los banners entran arriba, a 24 del borde, con 827 de ancho. Las cabeceras van arriba: título a la izquierda y acción principal a la derecha; esa acción es de 72 donde se toca con las manos ocupadas (Cocina) y de 48 en configuración. Ajustes es un índice de dos columnas de tres filas para no tener que desplazar. Navegación: deslizar del reloj a Sonidos o a Cocina, mantener la hora 2 s abre Ajustes y a los 60 s sin tocar se vuelve al reloj.

## Elevation & Depth

Es un sistema plano: no hay sombras en ningún componente. La profundidad se consigue de tres maneras:
- **Superficies tonales:** lienzo, superficie y hundida.
- **Bordes de 1 px:** `cream-border` o `ember-border`.
- **Degradado sobre la foto:** sube desde el borde inferior, alto 371, sólido hasta el 42 % y luego hasta 0. Es lo que da a la hora su contraste.

Los avisos a pantalla completa no flotan: sustituyen la pantalla entera.

### Named Rules
**The Flat Appliance Rule.** Un aparato de cocina no tiene sombras. Si algo necesita destacar, cambia de color o lleva borde; nunca se eleva.

## Shapes

Hay dos formas de borde:
- **Píldora** (`rounded.full`) en todo lo que se pulsa: botones de 72 y 48, botones de icono circulares, fichas de tiempos guardados y pistas de progreso.
- **Rectángulo suave** en todo lo que contiene: filas, banners y campos con radio grande (16); tarjetas de temporizador y de sonido con radio extra grande (24).

Los iconos son Lucide (ISC), de trazo, a 20, 24, 32 y 48, y en los banners van dentro de un círculo de 56. El borde siempre es de 1 px, y el de foco de 3 px en `amber-hearth-pressed`.

## Components

Francos y táctiles: píldoras grandes, planas, que se reconocen por color y borde.

### Buttons
- **Shape:** píldora (999).
- **Large** (72 de alto, 32 de relleno lateral, icono de 24 + etiqueta 20/600): la acción por defecto en alarma, cocina, avisos y cabeceras de cocina.
- **Primary:** ámbar con texto `ink-on-brand`. **Secondary:** `cream-sunken` con borde de 1 px. **Ghost:** sin fondo. **Night / Night-Primary:** `night-amber-faint` con texto `night-amber`, y su variante con borde.
- **Standard** (48, etiqueta 16/500): solo en configuración (cabeceras de Alarma y Ajustes).
- **Icon72:** círculo de 72 con icono de 32 (pausa, play, cerrar, detener con un solo temporizador).
- **Pulsado:** el fondo baja un paso (`amber-hearth-pressed`, `ember-*`). Al no haber puntero, no hay estado *hover* propio en el aparato.

### Chips
- **Tiempos guardados** (`Saved/Chip`): píldoras de 72 con nombre y minutos («Pasta 10 min»). La seleccionada lleva lavado ámbar, borde ámbar y texto `amber-ink`.

### Cards / Containers
- **Tarjeta de temporizador** (`Timer/Card`, 264 × 268, radio 24, relleno 20): nombre, estado, cifra de 56, pista de 8 y fila de botones «+1 min» y pausa. Estados: en marcha, en pausa (cifra atenuada), terminada (lavado ámbar con borde) y detenida (hundida, con «Deshacer»). La × de detener mide 48 a propósito, para no parar un temporizador sin querer.
- **Fila de alarma** (`Alarm/Row`, 827 × 96, radio 16): hora de 56, nombre, días e interruptor de 72 × 48.
- **Fila de ajustes** (`Settings/Row`, 827 × 80): icono en círculo de 48, título y valor o *chevron*.
- **Sonido** (`Sound/Tile`, 196 × 156, radio 24): icono, nombre y detalle; tiene variantes seleccionado y de noche.

### Inputs / Fields
- **Campo de texto** (solo en 05.4, nombre del temporizador): superficie con borde ámbar al tener el foco y cursor ámbar. Se usa el teclado del sistema y debajo hay sugerencias en fichas.
- **Ruedas** (`Wheel/Picker`): minutos y segundos con cifras de 96 en una banda hundida. Sustituyen al teclado en todo lo demás.

### Navigation
- No hay barra de navegación. Los modos se recorren deslizando, con puntos de modo (`Mode/Dots`) que aparecen solo al moverse. Ajustes se abre manteniendo la hora (con anillo de progreso). Desde Ajustes se entra a Alarma y a Fotos.

### Reloj y bloques de estado (componentes de firma)
- **`Clock/Time/*`**: la hora en cuatro tamaños (205, 160, 96 y 56), en variantes Photo, Surface y Night.
- **`Status/Block/*`**: icono, valor en Display y etiqueta en Label, de 140 de ancho, sin fondo, apoyados a los lados de la hora. Variantes Normal, Warning y Danger para foto, superficie y noche.
- **`Status/Capsule/*`**: versión compacta para los avisos.

### Avisos
- **Banner** (`Alert/Banner/*`, 827 × 96, radio 16): icono en círculo de 56, título en Label-large, texto en Body y botón Large de 72 a 12 del borde por arriba, abajo y a la derecha. Variantes Info, Warning, Critical, Photo (sobre el degradado, con borde `photo-edge`) y Night.
- **Pantalla completa** (`Alert/FullScreen/*`): icono de 40 en círculo de 80, título, subtítulo y dos botones de 72. Se usa para lo que no puede esperar (batería crítica, posponer o apagar la alarma).
- **Prioridad:** nueve niveles (pantalla 09.2). De noche solo suben la alarma, la batería que no llega a la alarma y la batería crítica.

## Do's and Don'ts

### Do:
- **Do** usar 72 (`touchLarge`) en todo lo que se toque medio dormido o con las manos ocupadas, y 48 como mínimo en configuración.
- **Do** mantener la hora a 7:1 o más sobre la foto con el degradado al 72 % (medido 8,0:1 con una foto de nieve).
- **Do** usar cifras tabulares para la hora, los temporizadores y los porcentajes.
- **Do** dar a cada pantalla una sola acción ámbar y resolver el resto con secundarios o *ghost*.
- **Do** colocar el botón de los banners con la misma regla en todas las pantallas (12 por arriba, abajo y a la derecha), igual que hace `bannerAction()` en Penpot.
- **Do** escribir los textos de los botones con el nombre del objeto para TalkBack («Detener Pasta», «Pausar Pasta»).

### Don't:
- **Don't** mostrar barra de estado, menú de tres puntos, listas que se desplazan ni nada que haga que Alba parezca un teléfono.
- **Don't** usar sombras ni elevación.
- **Don't** usar blanco o colores saturados de noche: solo `night-*`.
- **Don't** usar el ámbar de marca para avisos.
- **Don't** bajar de 14 en ningún texto de interfaz.
- **Don't** abrir el teclado salvo para nombrar un temporizador; en el resto, ruedas y fichas.
