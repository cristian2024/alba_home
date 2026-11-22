# Alba · estado del diseño en Penpot

Última actualización: 2026-11-21. **Fase 1 terminada y aprobada** (visto bueno del usuario, 2026-11-21): P2 y P3 aplicados, auditoría final 14/16 en `NOTA_diseno.md` §6 y exportación completa al día (46 claro + 46 oscuro + 12 noche, `spec.json` 58 pantallas y 0 sin token, `tokens.json`, 22 hojas). El archivo queda en **Light**. Fase 2 cubierta (2026-11-21): `design/auditoria_impeccable.md` y `phone_work/DESIGN.md` (+ `.impeccable/design.json`). Abiertas, a decidir: cabecera de Alarma en 48 y texto del aviso de noche. Traspaso al orquestador: `design/TRASPASO_orquestacion.md`.

## Dónde estamos

| Etapa del prompt (`PROMPT_diseno_penpot.md`) | Estado |
| :--- | :--- |
| 1. Propuesta (`propuesta_etapa1.md`) | Aprobada, con Inter |
| 2. Tokens (`00 Tokens`) | Aprobados |
| 3. Componentes (`01 Componentes`) | Aprobados; luego corregidos tras la auditoría |
| 4. Reloj (`02 Reloj`) | Aprobado (2026-11-19) |
| 5. Resto de flujos (03 a 09) | `03 Alarma` hecha y corregida tras Impeccable (16 pantallas: 11 claro/oscuro + 5 noche); aprobada (2026-11-19). `04 Sonidos` aprobada. `05 Cocina` aprobada. `06 Fotos` aprobada. `07 Batería` aprobada. `08 Ajustes` aprobada. `09 Navegación` aprobada. **Etapa 5 terminada.** |
| 6. Exportación final y `NOTA_diseno.md` | **Aprobada (2026-11-21).** Antes: Plan y hallazgos abajo, en «Etapa 6». Ya existen `referencia_penpot/tokens.json` y las hojas de 01–09 |

**Siguiente paso:** etapa 6 (ver «Etapa 6» abajo). El usuario la aplazó porque tarda mucho: lanzarla en segundo plano.

## Etapa 6 · plan (en curso desde 2026-11-20)

Hecho: `export-all.mjs`, `export-spec.mjs`, `export-comps.mjs` (hoja de 01 apilando las secciones), `make-hojas.sh`, secuencia `out/_final.sh` (log en `out/_final.log`) y borrador de `NOTA_diseno.md` (faltan el enlace y la lista de páginas: `@@ENLACE@@`, `@@PAGINAS@@`). Primera secuencia limpia (0 fallos, 0 sin token, 46 claro + 46 oscuro + 12 noche), pero la revisión de hojas encontró que el último «0» de la hora sale recortado (03.5 y toda hora acabada en 0): los dígitos van alineados a la izquierda en cajas de `dw` = 0,9 × ancho máximo y el tablero del componente recortaba. Corregido con `b.clipContent = false` en `comp-clock.js`; secuencia relanzada; la pasada Dark terminó limpia (0 sin token, verify ✓) y la exportación se cortó en ~12/46.

**Al retomar:** arrancar servidor, conectar plugin, `bash out/_final.sh > out/_final.log 2>&1` en segundo plano (secuencia completa otra vez, ~1 h 15 min; `_resume.sh` ya no vale porque el archivo no quedó en Dark). Si vuelven a fallar 02.8/02.9, reexportarlas a mano con `shot.mjs`. Comprobar el «0» de `oscuro/03_5_alarma_sonando.png` (borde derecho > 731). Luego revisar hojas, poner el enlace del archivo en `NOTA_diseno.md` si se quiere, y auditoría final de Impeccable sobre los PNG. `NOTA_diseno.md` ya está escrita (lista de páginas incluida). Queda: revisar el log («fallo», `verify-pages`), revisar hojas, completar la nota y la auditoría final.


Requisitos del prompt: PNG de cada pantalla en `referencia_penpot/{claro,oscuro,noche}/` con numeración y nombre (p. ej. `02_1_reloj_dia_con_foto.png`), `spec.json` con medidas y el token de cada color y texto, `tokens.json` (ya existe; regenerar con `export-tokens.mjs`). Guía de estructura: `design_system/referencia_penpot/` (`spec.json` = `{icons, comps, screens}`, cada nodo `{t, name, w, h, …, color/type/radius, kids}`). Después `NOTA_diseno.md` (enlace al archivo y qué hay en cada página, decisiones y porqués, lo pendiente y fallos conocidos, cómo reconectar y reconstruir) y auditoría final de Impeccable.

Pasos:
1. Script `export-all.mjs` (por escribir): por página 02–09, tableros cuyo nombre empieza por `NN.`; nombre de archivo = id con `.`→`_` + nombre en minúsculas sin tildes (`02.5n Reloj · temporizador · noche` → `02_5n_reloj_temporizador_noche.png`). Carpeta: si el tablero tiene `fillTok` = `night.bg` → `noche/` (solo en la pasada Light); si no, `claro/` u `oscuro/` según el tema. Exportar dos veces (la primera puede salir sin foto).
2. Pasada Dark completa (componentes + 02–09) → `verify-pages.mjs` → exportar `oscuro/`.
3. Pasada Light completa → `verify-pages.mjs` → exportar `claro/` y `noche/` → extraer `spec.json` → regenerar hojas de 01–09 con `hoja.py` → el archivo queda en Light.
4. `spec.json` (por escribir, `export-spec.mjs`): recorrer cada pantalla en el plugin. API comprobada el 2026-11-20:
   - `shape.tokens` devuelve los tokens aplicados, p. ej. `{fill: 'bg.surface-raised', strokeColor: 'border.default', borderRadiusTopLeft: 'radius.large', …}`; en textos `{typography: 'type.body-large', fill: 'text.primary'}`.
   - `shape.isComponentInstance()` y `shape.component()` → componente (`fullName(c)` da `Alarm/Row/On`).
   - Plugin data de respaldo: `fillTok`, `strokeTok`, `typo`, `color`.
   - Iconos: `out/icons.json` (58 trazados).
   - Hacer la extracción por página (respuestas grandes) y unir en Node.
5. Toda la secuencia tarda más de 1 h: lanzarla en segundo plano con `run_in_background` y revisar «fallo» y `verify-pages` al terminar.

## 03 Alarma

- Crítica de Impeccable: `.impeccable/critique/2026-11-19T12-29-01Z__…03-alarma-claro-png.md` (26/40, 3 P1). El usuario eligió: corregir **todo**, **toda la pantalla pospone**, permiso con **bloque urgente + banner** en el reloj.
- Cabecera común `header()` en `lib.js`: botón de 72 (volver o cerrar), título, resumen opcional (`sub`) y acción `Button/Standard`.
- Componentes: `Alarm/Row` 827 × 96; nuevo `Settings/Row/Field` (443 × 72); `Day/Toggle` con tres letras; nuevo `Button/Large/Night-Primary` (ámbar lleno, texto negro, 6,6:1), solo para cuando ya se está despierto.
- Sonando: «Mantén para apagar» + «Posponer 10 min» (principal); tocar en cualquier sitio pospone, «quedan 2». 03.5b muestra el progreso de mantener.
- Pospuesta: bloque «6:40 · Pospuesta»; tocarlo abre 03.6b («Vuelve a sonar a las 6:40», «Seguir durmiendo» / «Apagar alarma»).
- Editar: resumen «Sonará en…» en la cabecera, «Eliminar alarma» abajo a la izquierda, 03.3b para descartar cambios.
- Repetir: tres atajos solo con nombre; sin días = una sola vez.
- Sin permiso: filas «bloqueada por Android» con escudo en vez de interruptor; el reloj (03.8) avisa con bloque urgente y banner.
- Contraste: peligro en oscuro 5,9:1; en claro 8,1:1.
- No se tocó: los vecinos de la rueda siguen en `text.tertiary` (bajar más rompería 4,5:1).
- Hojas: `referencia_penpot/hojas/03_alarma_{claro,oscuro,noche}.png`.

## 04 Sonidos

- Crítica: `.impeccable/critique/2026-11-19T22-57-33Z__design-penpot-out-png-test-04-png.md` (27/40, 2 P1). El usuario eligió corregir **todo** y **añadir iconos Lucide** (`storm` = cloud-lightning, `sprout`; 58 iconos).
- Modo de deslizamiento: cabecera sin «volver» (`header(..., { lead: false })`); opciones nuevas `icon`, `titleColor`, `subColor`.
- 04.1 rejilla de 8 `Sound/Tile`; 04.2 cabecera «Lluvia · sonando» con volumen, «Apagar a las 23:45» y pausa de 72.
- 04.2n de noche: solo el sonido activo y tres `Button/Large/Night` (Pausa, Apagar a las 23:45, Cambiar sonido); la rejilla no se enciende de noche.
- 04.3 apagado automático: seis atajos centrados por columna, aviso del fundido final. 04.5 error de reproducción con `Alert/Banner/Warning`.
- 04.4n vista de noche: reloj de noche con bloques «28 min · Lluvia» y «6:30 · Alarma».
- Una pasada completa (componentes + 02 + 03 + 04) tarda más de 10 min: lanzarla en segundo plano.

## 05 Cocina

- Crítica: `.impeccable/critique/2026-11-20T00-19-27Z__design-penpot-out-png-test-05-png.md` (30/40, 2 P1). El usuario eligió corregir **todo**.
- Auditoría final de Impeccable (2026-11-20): 13/16 (rendimiento no aplica). Corregido: nota del teclado a `text.secondary` (4,2:1 → 5,9:1); nueva «Nota · accesibilidad» en la página con etiquetas de TalkBack y escala de texto. `05.4` oscuro ya reexportado.
- «✓» no está en la tabla de anchos: en 05.6 el resumen se ensancha 24 px a mano.
- Componentes: `Timer/Card/*` pasa a 264 de ancho (tres caben con márgenes de 32); `Timer/Card/Finished` se para con ✓ (sin «x»); nuevo `Clock/Time/Large` (`clock.large`, 160).
- 05.1 vacía con tiempos guardados; 05.2 tres tarjetas; 05.2b un temporizador con cifra de 160; 05.3 ruedas min/seg con unidades encima y tiempos guardados repartidos por ancho; 05.4 nombre con teclado del sistema (bloque de referencia); 05.5 `Alert/FullScreen/Default`; 05.6 dos terminados con «Parar los dos».

## 06 Fotos

- Crítica: `.impeccable/critique/2026-11-20T01-23-50Z__design-penpot-out-png-test-06-png.md` (30/40, 1 P1). Corregido todo.
- P1 de herramienta: `swapIcon` ahora conserva tamaño y posición del icono sustituido (antes volvía a 24). Afecta a todas las páginas: algunos iconos de 02–05 recuperan su tamaño de diseño; las hojas de esas páginas se regenerarán en la exportación final.
- `full()` (pantalla completa con dos botones) pasó a `lib.js`.
- 06.1 pasos numerados con estado «Buscando fotos nuevas…»; 06.2 tres filas de ajustes; 06.3 permiso con la consecuencia de «Ahora no».
- Auditoría final: 13/16 (rendimiento no aplica); añadida «Nota · accesibilidad» con TalkBack, escala de texto y el selector de carpetas del sistema.

## 07 Batería

- Crítica: `.impeccable/critique/2026-11-20T02-16-07Z__design-penpot-out-png-test-07-png.md` (31/40, 1 P1). Corregido todo: texto del banner de 07.1 acortado, sin bloque de batería en carga alta (no es alerta), el crítico avisa de que recuerda al 3 %.
- Los avisos van sobre el reloj: banner arriba + bloque de estado; el crítico es pantalla completa (`Alert/FullScreen/Danger` y `Night` con «Entendido» en `Night-Primary`).
- Auditoría final: 13/16; añadida «Nota · accesibilidad» (anuncios de TalkBack, contraste de noche documentado).
- En la pasada en claro falló una vez la sección `note` de 05 Cocina (tiempo de espera); se rehízo a mano.

## 08 Ajustes

- Crítica: `.impeccable/critique/2026-11-20T03-02-55Z__design-penpot-out-png-test-08-png.md` (30/40, 1 P1). Corregido todo.
- Nuevos `Settings/Row/Half` y `Settings/Row/Half-Attention` (405 × 80): índice en dos columnas de tres, sin desplazar; Huawei primero con tinte de aviso mientras esté pendiente. 146 componentes.
- 08.2 dos pares de ruedas (empieza/termina); 08.3 filas con `Settings/Stepper`; 08.4 idiomas como fichas; 08.5 guía de EMUI con «Abrir ajustes» y estado «Sin comprobar».
- Auditoría final: 13/16; paso 3 acortado y pasos más juntos (margen inferior); «Nota · accesibilidad». `08.5` oscuro ya reexportado.
- En la pasada en claro se cortó un momento la conexión: fallaron 11 secciones del reloj y 04.2 (no eran tiempos de espera). Se rehicieron y se comprobaron en PNG. Tras cada pasada, revisar que no haya «fallo» antes de seguir.

## 09 Navegación

- Crítica: `.impeccable/critique/2026-11-20T04-14-34Z__design-penpot-out-png-test-09-1-png.md` (30/40). Corregido todo: texto de la tarjeta Ajustes, tarjeta «Atajos del reloj» (tocar un bloque abre su pantalla).
- 09.1 mapa de modos (Sonidos ⇄ Reloj ⇄ Cocina, mantener la hora → Ajustes → seis destinos, vuelta al reloj tras 1 min, gesto atrás). 09.2 prioridad de avisos (9 niveles, forma y comportamiento de noche).
- Auditoría final: añadido el gesto atrás de Android al mapa.
- `verify-pages.mjs` cuenta las pantallas de cada página tras una pasada (02: 12, 03: 16, 04: 6, 05: 7, 06: 3, 07: 7, 08: 5, 09: 2); la última pasada dio todo ✓.
- Una página sin textos de componentes (como 09) se puede rehacer sola en cada tema sin rehacer componentes.

## Archivo de Penpot

- Proyecto **Alba**, archivo **«New File 3»** (pendiente de renombrar a mano). No tocar «New File 1» (home_tasks).
- Queda en tema **Light**. 139 componentes. Las páginas 00, 01 y 02 tienen todos los rellenos y bordes enlazados a tokens (`audit.js` da 0); la excepción documentada son los degradados.

## Auditoría con Impeccable (adelantada a petición del usuario)

- Informe: `.impeccable/critique/2026-11-19T02-52-34Z__design-referencia-penpot-hojas.md` (25/40, 3 P1).
- El usuario eligió: corregir **todo**, cápsulas a la **banda inferior**, hora de noche a **205**.
- Aplicado:
  - Bloques de estado `Status/Block/*` abajo, a los lados de la hora (máx. 2); arriba solo la foto; sin indicador de modo en el reloj.
  - Fecha con `type.subtitle` (26 px); cápsulas a 28 px; hora de noche con `clock.hero`.
  - `night.border` → `night.amber-dim` (3,6:1); `night.amber-faint` → `#2A1A08` (botón de noche 5,3:1).
  - Tarjeta de temporizador: «+ 1 min» con etiqueta, detener apartado arriba a la derecha, variante `Timer/Card/Stopped` con «Deshacer · 5 s», barra llena al terminar.
  - «Entendido» en ámbar (no rojo) en la pantalla de batería crítica; banner `Alert/Banner/Photo` oscuro sobre foto, con botón primario.
  - Transición en fotogramas (02.4a, 02.4b, 02.3) más nota en la página; pantalla nueva 02.9 con la pista tras un toque corto.
  - «Reproduciendo» en la tarjeta de sonido; icono «info» en el estado vacío.
- Contraste medido en PNG: hora sobre nieve 8,0:1; fecha sobre nieve 5,6:1; bloques 8,1:1.
- Queda abierto: en noche, la fecha y las etiquetas de los bloques usan `night.text-secondary` (3,6:1) a propósito.

## Cómo retomar

1. Arrancar el servidor en segundo plano si no escucha en 4400–4403:
   `/Users/daniel/Documents/projects/design_system/tools/penpot-mcp/start.sh`
2. Pedir al usuario: abrir el archivo en Zen, `⌘⌥P`, **Penpot MCP Plugin**, **Connect to MCP server**. La pestaña debe quedar **visible** (en segundo plano `setTimeout` no funciona).
3. Comprobar desde `design/penpot`: `node call.mjs execute_code @ping.js` (debe listar las páginas `00 Tokens` … `09 Navegación`).

## Herramientas (`design/penpot/`)

- `tokens.src.mjs` es la fuente de verdad de los tokens. `gen-tokens.mjs` **borra y rehace** el catálogo: no usarlo con el archivo ya montado; los cambios pequeños se hacen por API (ver `out/tk2.js`) y además en `tokens.src.mjs`.
- `run.mjs <script> [sección]` antepone `lib.js` y los datos (fuente, fotos). Cada script comprueba la página con `need()`: abrirla antes con `open.mjs "<página>"`.
- `rebuild-tokens.sh`, `rebuild-components.sh`, `rebuild-reloj.sh`, `rebuild-alarma.sh` `rebuild-sonidos.sh`, `rebuild-cocina.sh`, `rebuild-fotos.sh`, `rebuild-bateria.sh`, `rebuild-ajustes.sh` y `rebuild-navegacion.sh` rehacen cada página con el tema activo. `theme.mjs Light|Dark` cambia de tema.
- `shot.mjs <carpeta> <nombres…>` exporta tableros de la página actual. `audit.js` lista colores sin token. `fix-tokens.js` repone los tokens que Penpot pierde en hijos de instancias (ejecutarlo dos veces). `measure-scrim.py` mide el contraste de la hora.
- Fotos de ejemplo sintéticas: `photos/gen-photos.py` y `upload-photos.mjs` (referencias en `out/photos.json`).

## Reglas aprendidas

- **Auditar antes de exportar todo:** tras un cambio, reconstruir en el tema actual solo lo afectado, exportar esas pantallas (`node export-all.mjs claro 05`), auditar y retrabajar. `out/_final.sh` se lanza una sola vez, con el visto bueno.

- **Flujo por página:** construir → exportar solo lo cambiado → crítica de Impeccable → corregir → **auditoría final de Impeccable** sobre esas pantallas → visto bueno → pasadas Dark y Light y exportación completa (una vez) → revisar hojas.

- **Cada tema se reconstruye entero** (componentes y pantallas) y se exporta; los textos guardan el color del tema con el que se dibujaron. Orden: Dark → exportar `oscuro/` → Light → reconstruir → exportar `claro/` y `noche/`. El archivo siempre queda en Light.
- `openPage` no es inmediato: abrir la página en un paso aparte.
- Penpot no mide textos: `text()` calcula el tamaño con `out/font.json`.
- Un nombre de capa que acaba en «/» rompe el script; `text()` ya lo limpia.
- Tras `swapComponent`, el icono conserva su id y pasa a llamarse `Icon/<nombre>`.
- La primera exportación tras cambiar de tema es poco fiable: exportar dos veces.
- Rehacer componentes deja huérfanas las instancias de las pantallas: tras `rebuild-components.sh` hay que rehacer también todas las páginas de pantallas (en la pasada final en Light).
- Las fotos pueden no salir en la primera exportación tras construir: comprobar un píxel de arriba y reexportar.
- Tras `swapComponent`, la instancia conserva el borde de la variante anterior y el nombre nuevo solo se ve en otra llamada: `screens-alarma.js` lo limpia en la sección `post`.
- Revisar las hojas de verdad, no solo el log: un recorte de la hora pasó las críticas porque sobre foto apenas se nota.
- `hoja.py` une PNG de pantallas en una hoja de dos columnas.
- Los scripts no deben superar los 30 s: se dividen en secciones.
