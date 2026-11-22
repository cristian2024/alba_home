# Alba · auditoría con Impeccable (fase 2)

Fecha: 2026-11-21. Estado: **sin hallazgos graves abiertos** (P0–P2). Esto cumple la puerta de la fase 2 de `PLAN.md`.

Durante la fase 1, cada página pasó por este ciclo con la skill `impeccable` sobre sus PNG exportados:
1. Crítica de heurísticas, puntuada sobre 40.
2. Correcciones en Penpot.
3. Auditoría técnica final, puntuada sobre 16: rendimiento no aplica a un diseño en Penpot y las otras cuatro dimensiones valen 4 cada una.

Al final se auditó toda la exportación (claro, oscuro y noche). Este documento reúne esos resultados. Los informes completos de las críticas están en `phone_work/.impeccable/critique/`, y el detalle de cada corrección en `design/ESTADO.md`.

Gravedad: **P0** bloquea · **P1** grave, se corrige antes del visto bueno · **P2** importante · **P3** pulido.

## 1. Resumen por página

| Página | Crítica (/40) | Hallazgos | Auditoría final (/16) | Estado |
| :--- | :--- | :--- | :--- | :--- |
| 00–02 Tokens, componentes y reloj | 25 · Aceptable | 3 P1, 2 P2 | corregido todo | Cerrada |
| 03 Alarma | 26 · Aceptable | 3 P1, 2 P2 | corregido todo | Cerrada |
| 04 Sonidos | 27 · Aceptable | 2 P1, 3 P2 | corregido todo | Cerrada |
| 05 Cocina | 30 · Bueno | 2 P1, 2 P2 | 13 | Cerrada |
| 06 Fotos | 30 · Bueno | 1 P1, 3 P2 | 13 | Cerrada |
| 07 Batería | 31 · Bueno | 1 P1, 2 P2 | 13 | Cerrada |
| 08 Ajustes | 30 · Bueno | 1 P1, 1 P2 | 13 | Cerrada |
| 09 Navegación | 30 · Bueno | 1 P1, 1 P2 | corregido | Cerrada |
| **Exportación completa** | — | 1 P1, 2 P2, 3 P3 | **13 → 14** | Cerrada; quedan 2 observaciones a decidir |

Las notas de las críticas suben de 25 a 31 a medida que lo aprendido en las primeras páginas se aplicaba a las siguientes.

## 2. Hallazgos y cómo se resolvieron

### 00–02 Tokens, componentes y reloj (crítica 2026-11-19)
- **[P1] Información secundaria ilegible a 1–2 m:** la fecha y las cápsulas iban a 20 px. Se resolvió con la fecha en `subtitle` 26 y valores de bloque en `display` 40, con dos bloques como máximo.
- **[P1] Franja superior que imitaba la barra de estado:** los bloques bajaron a la banda inferior, a los lados de la hora, sobre el degradado. Arriba solo queda la foto y los puntos de modo aparecen solo al deslizar.
- **[P1] Detener un temporizador con un toque y sin deshacer; «+» sin cantidad:** ahora el botón dice «+1 min» y existe el estado detenido con «Deshacer».
- **[P2] «Entendido» en rojo en batería crítica:** el rojo queda solo para acciones destructivas y «Entendido» pasa a primario o secundario.
- **[P2] La transición no se veía:** 02.4a, 02.4b y 02.3 muestran la transición al modo noche en tres fotogramas.

### 03 Alarma (crítica 2026-11-19)
- **[P1] Noche sonando con «Posponer» y «Apagar» iguales y la pista a 14 px:** toda la pantalla pospone, apagar exige mantener y muestra el progreso, y se indica cuántas posposiciones quedan.
- **[P1] Alarma pospuesta sin salida:** hay un bloque «6:40 · Pospuesta» que al tocarlo abre 03.6b («Seguir durmiendo» / «Apagar alarma»).
- **[P1] El permiso de alarma exacta solo se avisaba en Alarma:** ahora también avisa el reloj, con bloque urgente y banner (03.8). Las filas muestran «bloqueada por Android» y «Activar» es la acción principal.
- **[P2] «Eliminar» junto a «Guardar»:** se movió abajo a la izquierda y se añadió la confirmación de descartar cambios (03.3b).
- **[P2] Repetir:** quedan tres atajos solo con nombre, y sin días significa una sola vez.
- **Mantenido a sabiendas:** los números vecinos de la rueda siguen en `text.tertiary`, porque bajarlos más rompería 4,5:1.

### 04 Sonidos (crítica 2026-11-19)
- **[P1] Noche con toda la rejilla encendida:** 04.2n muestra solo el sonido activo, con tres botones de noche de 72.
- **[P1] No se veía qué sonaba:** la cabecera dice «Lluvia · sonando», con icono ámbar.
- **[P2] Ajustes de botones y textos:**
  - La pausa pasa a `Icon72/Primary`.
  - El botón dice «Apagar a las 23:45».
  - Los atajos de 04.3 quedan centrados por columna.

### 05 Cocina (crítica 2026-11-20)
- **[P1] Temporizador terminado con «×»:** se para con un botón de 72 con ✓.
- **[P1] Tarjetas que rompían los márgenes:** `Timer/Card` pasa a 264 de ancho, y caben tres con márgenes de 32.
- **[P2] Cambios en 05.2b y 05.3:** un solo temporizador se muestra con cifra de 160. En 05.3 los tiempos guardados se reparten por el ancho y «min» y «seg» van sobre las ruedas.
- **Auditoría final (13/16):**
  - La nota del teclado pasó de 4,2:1 a 5,9:1.
  - Se añadió la nota de accesibilidad de la página (TalkBack y escala de texto).

### 06 Fotos (crítica 2026-11-20)
- **[P1] Al sustituir un icono no se conservaba su tamaño** (06.3: icono de 24 en un hueco de 40). Era un fallo de la herramienta; se arregló y afectó a todas las páginas.
- **[P2] Cambios en 06.1 y 06.3:** 06.1 muestra el estado «Buscando fotos nuevas…». En 06.3 «Ahora no» explica su consecuencia. Títulos y subtítulos se reescribieron.
- **Auditoría final (13/16):** se añadió la nota de accesibilidad (selector de carpetas del sistema).

### 07 Batería (crítica 2026-11-20)
- **[P1] El texto del banner de 07.1 se desbordaba:** se acortó.
- **[P2] Carga alta y nivel crítico:** con carga alta ya no aparece el bloque de batería, porque no es una alerta. El nivel crítico avisa de que vuelve a recordar al 3 %.
- **Auditoría final (13/16):** se añadió la nota de accesibilidad y se documentó el contraste de noche.

### 08 Ajustes (crítica 2026-11-20)
- **[P1] El índice obligaba a desplazar:** ahora son dos columnas de tres con `Settings/Row/Half`, y la guía de Huawei va primero, teñida mientras esté pendiente.
- **[P2] Cambios en 08.5:** el botón va bajo la explicación, aparece el estado «Sin comprobar» y los pasos se ajustan a la altura real.
- **Auditoría final (13/16):** pasos más juntos y nota de accesibilidad.

### 09 Navegación (crítica 2026-11-20)
- **[P1] Texto superpuesto en la tarjeta de Ajustes:** corregido.
- **[P2] Faltaba el atajo de tocar un bloque de estado:** se añadió la tarjeta «Atajos del reloj».
- **Auditoría final:** se añadió al mapa el gesto atrás de Android.

### Exportación completa (2026-11-20 y 2026-11-21)

| # | Dimensión | Nota | Hallazgo principal |
| :--- | :--- | :--- | :--- |
| 1 | Accesibilidad | 3 → 4 | Ningún control baja de 48. Cocina y los banners usan 72; la × de las tarjetas de cocina se queda en 48 a propósito |
| 2 | Rendimiento | — | No aplica a un diseño en Penpot |
| 3 | Temas | 4 | 0 valores sin token en 58 pantallas y 146 componentes; claro, oscuro y noche completos |
| 4 | Conformidad | 3 | No parece un teléfono; el teclado de 05.4 es solo de referencia |
| 5 | Adaptabilidad | 3 | Solo horizontal 891 × 411, a propósito; la escala de texto está documentada solo en 05–09 |
| | **Total** | **14/16** | Bueno |

- **[P1] El último «0» de la hora salía recortado** en las horas acabadas en 0: el componente del reloj recortaba su contenido. Se quitó el recorte y se comprobó en los tres temas.
- **[P2] La hoja de contacto de 09 salía recortada:** ahora apila los tableros grandes.
- **[P2] Las acciones de cabecera de Cocina medían 48:** pasaron a `Button/Large` de 72 (05.1–05.4).
- **[P3] La acción de los banners medía 48:** pasó a 72, con 12 px de margen arriba, abajo y a la derecha, aplicado igual en las 11 pantallas mediante `bannerAction()`.
- **[P3] La × de las tarjetas de cocina mide 48:** se mantiene a propósito, para no detener sin querer, y queda documentado en la nota de accesibilidad de 05.
- **[P3] Cifras alineadas a la izquierda en sus cajas:** no se cambia en Penpot. En Flutter se usarán cifras tabulares con la hora centrada como bloque (`DESIGN.md`, «The Steady Clock Rule»).
- **Exportaciones desfasadas:** la primera exportación tras reconstruir podía salir con el estado anterior. Ahora la secuencia completa exporta dos veces cada tema.

## 3. Observaciones abiertas (no son fallos; las decide el usuario)

- Las acciones de cabecera de Alarma («Nueva», «Guardar») miden 48. Son pantallas de configuración y cumplen la regla de 48, pero podrían pasar a 72 como en Cocina.
- El mismo aviso de noche dice cosas distintas: «No llega a la alarma» en 02.6n y «Con 9 % no llega a las 6:30» en 07.5n. Es una decisión de contenido.

## 4. Decisiones mantenidas a sabiendas

- El texto secundario de noche (`night.text-secondary`, 3,6:1) y el rojo de noche (`night.red`, 3,1:1) quedan por debajo de 4,5:1 para no subir el brillo a oscuras. Está documentado en las notas de accesibilidad.
- El lienzo solo existe en horizontal, a 891 × 411: el aparato no gira.

## 5. Pendiente de comprobar en el teléfono

Ninguna de estas cosas se puede auditar sobre PNG:
- Lectura a 2 m.
- Brillo mínimo de la pantalla LCD y si el ámbar de noche deslumbra.
- Contraste con fotos reales: las de ejemplo son sintéticas.
- Nombres de menú de EMUI (08.5).

Quedan como criterios de prueba de las fases 4 y 5.

## 6. Sistema de diseño resultante

`phone_work/DESIGN.md`, con su sidecar `phone_work/.impeccable/design.json`, recoge el sistema final: tokens, tipografía, formas, componentes y reglas. Es la fuente del paquete `design_system` de la fase 3, junto con `design/referencia_penpot/tokens.json` (todos los semánticos por tema) y `spec.json`.
