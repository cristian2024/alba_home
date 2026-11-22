# Alba · nota de diseño (fase 1, Penpot)

Fecha: 2026-11-20. Entrada para el chat de auditoría con Impeccable.

Alba convierte un Huawei Mate 20 Lite en un aparato de mesa de noche y de cocina: horizontal (891 × 411 dp), siempre enchufado, como lanzador. La regla de fondo es que **no parezca un teléfono**: nada de barras de estado, listas largas ni menús; la hora y la foto mandan, y todo lo demás aparece solo cuando hace falta.

## 1. Archivo

- Penpot, proyecto **Alba**, archivo **«New File 3»** (copiar el enlace desde Penpot al renombrarlo). La API no permite renombrarlo: hay que llamarlo «Alba» a mano.
- No confundir con «New File 1», que es el archivo de home_tasks.
- El archivo queda en el tema **Light**. Para ver el oscuro hay que activar el tema Dark **y** reconstruir (ver §5): los textos guardan el color con el que se dibujaron.
- 146 componentes, todos los colores, bordes y textos enlazados a tokens (la auditoría `audit.js` da 0 valores sueltos en todas las páginas). La única excepción son las paradas del degradado del reloj: Penpot no enlaza paradas a tokens; sus valores son copia de `alpha.scrim-0` y `alpha.scrim-72`.

### Qué hay en cada página

- **00 Tokens**: colores (primitivos, claro, oscuro, noche, estados), tipografía, espaciado, radios, tamaños táctiles y opacidades del degradado.
- **01 Componentes**: iconos, botones (72, 48, icono), bloques de estado, reloj (`Clock/Time/*`), cápsulas, banners, avisos a pantalla completa, temporizador de cocina, fila de alarma, sonidos, ajustes, ruedas y estado vacío. 146 componentes.
- **02 Reloj** (12 pantallas): `02.1` Reloj · día con foto; `02.2` Reloj · día sin fotos; `02.4a` Reloj · transición 1 de 3 · 22:00; `02.4b` Reloj · transición 2 de 3 · 22:15; `02.5` Reloj · con temporizador; `02.6` Reloj · con aviso de batería; `02.7` Reloj · pulsación larga; `02.8` Reloj · prueba con foto clara; `02.9` Reloj · pista tras un toque corto; `02.3` Reloj · noche · transición 3 de 3; `02.5n` Reloj · temporizador · noche; `02.6n` Reloj · aviso de batería · noche.
- **03 Alarma** (16 pantallas): `03.1` Alarma · lista; `03.2` Alarma · lista vacía; `03.3` Alarma · editar; `03.3b` Alarma · descartar cambios; `03.4` Alarma · repetir; `03.5` Alarma · sonando; `03.5n` Alarma · sonando · noche; `03.5b` Alarma · manteniendo apagar; `03.5bn` Alarma · manteniendo apagar · noche; `03.6` Alarma · pospuesta; `03.6n` Alarma · pospuesta · noche; `03.6b` Alarma · pospuesta, tras tocar el bloque; `03.6bn` Alarma · pospuesta, tras tocar el bloque · noche; `03.7` Alarma · sin permiso de alarma exacta; `03.8` Reloj · alarma sin permiso; `03.8n` Reloj · alarma sin permiso · noche.
- **04 Sonidos** (6 pantallas): `04.1` Sonidos · selector; `04.2` Sonidos · reproduciendo; `04.2n` Sonidos · reproduciendo · noche; `04.3` Sonidos · apagado automático; `04.5` Sonidos · no se puede reproducir; `04.4n` Sonidos · vista de noche.
- **05 Cocina** (7 pantallas): `05.1` Cocina · sin temporizadores; `05.2` Cocina · varios en marcha; `05.2b` Cocina · un temporizador; `05.3` Cocina · nuevo temporizador; `05.4` Cocina · nombre del temporizador; `05.5` Cocina · terminado sonando; `05.6` Cocina · dos terminados.
- **06 Fotos** (3 pantallas): `06.1` Fotos · carpeta vacía; `06.2` Fotos · presentación; `06.3` Fotos · sin permiso.
- **07 Batería** (7 pantallas): `07.1` Batería · carga alta; `07.2` Batería · carga baja; `07.3` Batería · nivel crítico; `07.3n` Batería · nivel crítico · noche; `07.4` Batería · temperatura alta; `07.5` Batería · no llega a la alarma; `07.5n` Batería · no llega a la alarma · noche.
- **08 Ajustes** (5 pantallas): `08.1` Ajustes · índice; `08.2` Ajustes · horario de noche; `08.3` Ajustes · avisos de batería; `08.4` Ajustes · idioma; `08.5` Ajustes · guía de Huawei.
- **09 Navegación** (2 pantallas): `09.1` Navegación · mapa de modos; `09.2` Navegación · prioridad de avisos.

Cada pantalla de 02–08 existe en claro y en oscuro; las de noche (fondo `night.bg`) son únicas y no cambian con el tema.

## 2. Exportaciones (`design/referencia_penpot/`)

| Ruta | Contenido |
| :--- | :--- |
| `claro/`, `oscuro/`, `noche/` | Un PNG por pantalla a 1×: `<id>_<nombre>.png`, p. ej. `02_5n_reloj_temporizador_noche.png` |
| `hojas/` | Hojas de contacto por página y tema (`NN_<página>_<tema>.png`) y de componentes (`01_componentes_{claro,oscuro}.png`) |
| `spec.json` | `{ file, icons, comps, screens }`. Cada nodo: `t` (box, text, icon, image, shape), `name`, `x`, `y` relativos al padre, `w`, `h`, `color`, `stroke`, `sw`, `radius`, `type` (estilo de texto), `s` (texto), `align`, `comp` (componente de origen, p. ej. `Alarm/Row/On`), `kids`. Los colores son **nombres de token**, válidos en los dos temas; las pantallas de noche usan `night.*`. Los iconos llevan `id` y el trazado está en `icons` (viewBox 24) |
| `tokens.json` | Primitivos, semánticos claro/oscuro, `night.*`, espaciado, radios, tamaños, layout, opacidades, fuentes y estilos de texto, con el nombre Dart propuesto |

## 3. Decisiones y porqués

### Paleta
- **Neutros cálidos** (`warm`) en lugar de grises: el aparato vive en un dormitorio y una cocina; el gris azulado de un teléfono es justo lo que se quería evitar.
- **Ámbar** como único acento (`amber.400` en el botón principal, texto casi negro encima, 9,4:1). Es el mismo de día y de noche, así el usuario reconoce «lo que se toca» en cualquier modo.
- **Aviso en ocre**, separado del ámbar de marca: una cápsula de batería baja no debe parecer un botón. Peligro en terracota, éxito en oliva, información en pizarra.
- **Modo noche** con su propio grupo `night.*`, independiente del tema: negro puro (la pantalla es LCD: el negro no apaga píxeles, pero es lo menos luminoso que puede dar), hora en `night.amber` (6,6:1), secundario en `night.amber-dim` (3,6:1, a propósito: de noche debe molestar lo menos posible), alerta en `night.red`. Sin azules ni blancos.
- Botón «ya estoy despierto» de noche: `Button/Large/Night-Primary` (ámbar lleno, texto negro, 6,6:1), solo cuando el usuario ya se ha levantado (apagar alarma, batería crítica).

### Tipografía
- **Inter** en todo, también la hora (Bold, 700). Se eligió frente a Atkinson Hyperlegible y Barlow por tener cifras tabulares, el 1 con bandera y el 7 recto, y estar ya en Penpot y en home_tasks. Licencia SIL OFL 1.1.
- Hora en **cajas de ancho fijo** (`Clock/Digit`) para que no baile; en Flutter, `FontFeature.tabularFigures()`.
- Escala: `clock.hero` 205 (reloj y noche), `clock.large` 160 (un solo temporizador), `clock.medium` 96, `clock.small` 56; `display` 40, `title` 28, `subtitle` 26 (fecha, legible a ~1 m), `heading` 22, `body-large` 20, `body` 18, `label-large` 20, `label` 16, `caption` 14. Nada de texto de interfaz por debajo de 14.

### Degradado sobre la foto
- `warm.1000` al **72 %** en la franja de la hora, bajando a 0 % (alto 371, sólido hasta el 42 %). Con una foto blanca pura da 9,1:1 en teoría; medido en PNG con una foto de nieve: hora **8,0:1**, fecha 5,6:1, bloques 8,1:1. Se dejó margen sobre 7:1 para fotos con brillos.

### Tamaños
- Pantalla 891 × 411, márgenes 32, separación 16.
- Áreas táctiles: **72** en todo lo que se toca medio dormido o con las manos sucias (alarma, cocina, avisos a pantalla completa, botones de cabecera), **48** como mínimo en ajustes.
- Iconos Lucide (ISC), 58, en 20/24/32/48.

### Estructura e interacción
- **Reloj como casa.** Sonidos ⇄ Reloj ⇄ Cocina deslizando; mantener la hora 2 s abre Ajustes (con anillo de progreso; un toque corto muestra la pista, 02.9). Alarma y Fotos se entran desde Ajustes. Tras 1 min sin tocar vuelve al reloj. Mapa en `09.1`.
- **Bloques de estado** (`Status/Block/*`) en la banda inferior, a los lados de la hora, máximo dos; tocar uno abre su pantalla. Arriba solo la foto: sin barra de estado ni indicador de modo en el reloj.
- **Prioridad de avisos** (`09.2`): 9 niveles; lo urgente pasa a banner o a pantalla completa, y de noche solo sube lo que lo justifica (alarma, batería que no llega a la alarma, crítica).
- **Alarma sonando:** toda la pantalla pospone; apagar exige mantener (no se apaga dormido). «Quedan 2» posposiciones.
- **Una sola pantalla con teclado** (05.4, nombre del temporizador); el resto se resuelve con ruedas, fichas y atajos.
- **Ajustes sin desplazamiento:** índice en dos columnas de tres; la guía de Huawei va primero y teñida mientras esté pendiente.

## 4. Sin confirmar y fallos conocidos

- **Contraste de noche:** `night.text-secondary` 3,6:1 y `night.red` 3,1:1 sobre negro, por debajo de 4,5:1 a propósito (brillo mínimo de noche). Documentado en las notas de accesibilidad de las páginas.
- **Fotos sintéticas:** las fotos de ejemplo están generadas (`penpot/photos/gen-photos.py`); el contraste se midió con la peor (nieve), pero falta probar con fotos reales del usuario.
- **LCD, no OLED:** el Mate 20 Lite tiene LCD; el negro de noche no apaga píxeles. Falta comprobar en el aparato el brillo mínimo real y si `night.amber` deslumbra a oscuras.
- **Lectura a 2 m** y **tamaño de la hora** solo se han comprobado en pantalla de ordenador, no en el aparato.
- **Teclado del sistema** en 05.4 es un bloque de referencia, no el teclado real de EMUI.
- **Guía de Huawei (08.5):** los nombres de menú de EMUI («Inicio de aplicaciones», gestión manual) están sin comprobar en el teléfono; el estado es «Sin comprobar» en el propio diseño.
- **Herramienta:** «✓» no está en la tabla de anchos de `font.json`; en 05.6 el resumen se ensancha 24 px a mano.
- **Herramienta:** el plugin corta a los 30 s; algunos «fallo» al reconstruir son solo tiempos de espera. `verify-pages.mjs` cuenta pantallas para distinguirlo.
- El archivo sigue llamándose «New File 3».

## 5. Cómo volver a conectar y reconstruir

Todo desde `design/penpot/`. Detalle y reglas aprendidas en `design/ESTADO.md`.

1. Servidor MCP (si no escucha en 4400–4403): `/Users/daniel/Documents/projects/design_system/tools/penpot-mcp/start.sh`.
2. Abrir el archivo en el navegador, `⌘⌥P` → **Penpot MCP Plugin** → **Connect to MCP server**. La pestaña debe quedar **visible**; al terminar, esperar a que Penpot guarde antes de cerrarla.
3. Comprobar: `node call.mjs execute_code @ping.js` (lista las páginas 00–09).
4. Reconstruir un tema: `node theme.mjs Light|Dark`, luego `./rebuild-components.sh` y **todas** las páginas (`./rebuild-reloj.sh`, `alarma`, `sonidos`, `cocina`, `fotos`, `bateria`, `ajustes`, `navegacion`): rehacer componentes deja huérfanas las instancias. `node verify-pages.mjs` comprueba que no falte ninguna pantalla.
5. Exportar: `node export-all.mjs oscuro` (tras la pasada Dark) y `node export-all.mjs claro` (tras la pasada Light; incluye `noche/`), `node export-comps.mjs <tema>`, `node export-spec.mjs`, `node export-tokens.mjs`, `./make-hojas.sh`.
6. Secuencia completa (más de 1 h): `bash out/_final.sh` en segundo plano. Termina en Light.
7. Los tokens salen de `tokens.src.mjs`. **No** usar `gen-tokens.mjs` con el archivo montado: borra el catálogo.

## 6. Historial de revisiones con Impeccable

| Página | Crítica | Auditoría final |
| :--- | :--- | :--- |
| 00–02 (adelantada) | 25/40, 3 P1 | corregido todo |
| 03 Alarma | 26/40, 3 P1 | corregido todo |
| 04 Sonidos | 27/40, 2 P1 | corregido todo |
| 05 Cocina | 30/40, 2 P1 | 13/16 |
| 06 Fotos | 30/40, 1 P1 | 13/16 |
| 07 Batería | 31/40, 1 P1 | 13/16 |
| 08 Ajustes | 30/40, 1 P1 | 13/16 |
| 09 Navegación | 30/40 | corregido |
| Exportación final (todas) | — | 13/16, 14/16 tras los P3 (rendimiento no aplica); ver abajo |

Informes en `phone_work/.impeccable/critique/`. Las páginas 05–09 llevan una «Nota · accesibilidad» con etiquetas de TalkBack y escala de texto.

### Auditoría final de la exportación (2026-11-20)

| # | Dimensión | Nota | Hallazgo principal |
| :--- | :--- | :--- | :--- |
| 1 | Accesibilidad | 3 → 4 | Ningún control baja de 48; Cocina y los banners ya usan 72; «Detener» de las tarjetas en 48 a propósito |
| 2 | Rendimiento | — | No aplica a un diseño en Penpot |
| 3 | Temas | 4 | 0 valores sin token en 58 pantallas y 146 componentes; claro, oscuro y noche completos |
| 4 | Conformidad | 3 | No parece un teléfono; teclado de 05.4 solo de referencia |
| 5 | Adaptabilidad | 3 | Solo horizontal 891 × 411 (a propósito); escala de texto documentada solo en 05–09 |
| | **Total** | **13/16 → 14/16** | Bueno; 14 tras los P3 |

Corregido en esta exportación:
- **[P1] Último «0» de la hora recortado** en toda hora acabada en 0 (03.5 «06:30», 07.1 «16:20», filas de alarma…): los dígitos van alineados a la izquierda en cajas de 0,9 × el ancho máximo y el componente `Clock/Time/*` recortaba. Ahora no recorta (`comp-clock.js`). Comprobado en claro, oscuro y noche.
- **[P2] Hoja de 09 recortada** por `hoja.py` (suponía 891 × 411); ahora apila los tableros grandes.
- **[P2] Acciones de cabecera de Cocina en 48** (05.1 «Otro tiempo», 05.2 «Nuevo», 05.2b, 05.3 «Empezar», 05.4 «Listo»): ahora son `Button/Large` de 72 (`header(..., { actionKind: 'Large' })`); la cabecera baja 4 px para no tocar el borde y en 05.4 el campo y las sugerencias bajan 8 (teclado de referencia de 176).
- **Exportaciones desfasadas:** la primera exportación tras reconstruir puede salir con el estado anterior (9 PNG distintos al repetir). `out/_final.sh` exporta ahora dos veces cada tema.

Corregido después (P3, 2026-11-20), auditado solo sobre las pantallas afectadas en claro y noche:
- **[P3] Acción de los banners a 72:** `Alert/Banner/*` usa `Button/Large` con 12 px de margen arriba, abajo y a la derecha; el texto queda a 37 px o más del botón. La revisión encontró que cada página colocaba el botón con su propia cuenta (24 o 48 px del borde en 7 de 11 pantallas): ahora todas usan `bannerAction()` de `lib.js`. Medido en Penpot: 12 px en las 11 pantallas con banner (02.6, 02.6n, 03.7, 03.8, 03.8n, 04.5, 07.1, 07.2, 07.4, 07.5, 07.5n).
- **[P3] «Detener» de las tarjetas en 48:** se mantiene a propósito y queda explicado en la «Nota · accesibilidad» de 05 (más pequeña y lejos de «+1 min» y pausa para no detener sin querer; con un solo temporizador, 05.2b, es de 72).
- **[P3] Cifras alineadas a la izquierda en sus cajas:** no se cambia en Penpot. En Flutter usar `FontFeature.tabularFigures()` con la hora centrada como bloque, no repetir las cajas (p. ej. 02.8 «11:17» queda algo descentrada aquí).

Auditoría de los P3: Accesibilidad sube a 4 (todo lo que se toca desde la cama o en la cocina mide 72; los 48 que quedan son de configuración o intencionados y documentados). Total **14/16**.

Observaciones abiertas (sin cambiar, a decidir):
- **Cabecera de Alarma en 48** («Nueva» en 03.1 y 03.7, «Guardar» en 03.3): son pantallas de configuración que se usan despierto y de cerca, coherentes con la regla de 48 en ajustes; pasarlas a 72 sería el mismo cambio que en Cocina.
- **Texto distinto para el mismo aviso de noche:** 02.6n dice «No llega a la alarma» y 07.5n «Con 9 % no llega a las 6:30». Unificar el texto es decisión de contenido.
- **Decisión mantenida:** secundario de noche a 3,6:1.

