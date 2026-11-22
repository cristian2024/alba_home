# Alba · traspaso de la fase 1 (diseño en Penpot) al chat de orquestación

Fecha: 2026-11-21. Estado: **fase 1 terminada y aprobada por el usuario; fase 2 (auditoría con Impeccable) cubierta** con `auditoria_impeccable.md` y `DESIGN.md`.

## 1. Qué se entrega

Todo vive en `phone_work/design/`, salvo `DESIGN.md` y su sidecar, que van en la raíz (`phone_work/`) para que Impeccable y la fase 3 los encuentren. No se ha escrito código Flutter.

| Ruta | Qué es |
| :--- | :--- |
| `NOTA_diseno.md` | Documento principal del diseño: páginas, exportaciones, decisiones y sus porqués, cosas sin confirmar, cómo reconstruir, historial de Impeccable. **Es la entrada para las fases siguientes.** |
| `referencia_penpot/claro/`, `oscuro/`, `noche/` | Un PNG por pantalla a 1× (891 × 411): 46 en claro, 46 en oscuro y 12 en noche |
| `referencia_penpot/hojas/` | 22 hojas de contacto por página y tema, más las de componentes |
| `referencia_penpot/spec.json` | Árbol de cada pantalla y componente, con nombres de token en lugar de valores: 58 pantallas, 146 componentes, 58 iconos; 0 valores sin token |
| `referencia_penpot/tokens.json` | 82 primitivos, 58 semánticos (claro/oscuro), 6 de noche y 13 estilos de texto, con el nombre Dart propuesto |
| `auditoria_impeccable.md` | Entregable de la fase 2: hallazgos de Impeccable, gravedad y resolución (14/16) |
| `../DESIGN.md` y `../.impeccable/design.json` | Sistema de diseño final (formato DESIGN.md) para la fase 3 |
| `ESTADO.md` | Bitácora de trabajo y reglas aprendidas (para retomar en Penpot) |
| `penpot/` | Scripts que construyen y exportan el archivo (no es código de la app) |

Archivo de Penpot: proyecto **Alba**, archivo **«New File 3»**; el usuario tiene que renombrarlo a «Alba» a mano porque la API no lo permite. **No confundir con «New File 1»**, que es de home_tasks y no se debe tocar. El archivo quedó en el tema Light.

## 2. Pantallas (una página por flujo)

00 Tokens · 01 Componentes · 02 Reloj (12) · 03 Alarma (16) · 04 Sonidos (6) · 05 Cocina (7) · 06 Fotos (3) · 07 Batería (7) · 08 Ajustes (5) · 09 Navegación (2: mapa de modos y prioridad de avisos). El detalle por pantalla está en `NOTA_diseno.md` §1.

## 3. Decisiones que condicionan la implementación

- **No debe parecer un teléfono:** sin barra de estado, listas largas ni menús. Orientación fija horizontal, 891 × 411 dp, márgenes de 32 y separación de 16.
- **Temas:** claro, oscuro y **noche** (negro con ámbar, a brillo mínimo). Las pantallas de noche son únicas: no dependen del tema claro u oscuro.
- **Tipografía:** Inter en todo, también la hora (Bold). La hora a 205 se mantiene en ≥ 7:1 sobre la foto gracias a un degradado de `warm.1000` al 72 %. Escala completa en la nota, §3.
- **Áreas táctiles:** 72 en todo lo que se toca medio dormido o con las manos ocupadas (alarma, cocina, avisos y sus botones, cabeceras de cocina); 48 como mínimo en configuración. La × de las tarjetas de cocina se queda en 48 a propósito.
- **Navegación:** el reloj es la casa. Se desliza a Sonidos o a Cocina; mantener la hora 2 s abre Ajustes; tras 1 min sin tocar vuelve al reloj. Hay 9 niveles de prioridad de avisos (09.2).
- **Una sola pantalla con teclado** (05.4); en el resto se usan ruedas, fichas y atajos.

## 4. Indicaciones para Flutter (fase 3 en adelante)

- Generar los tokens y estilos del paquete `design_system` desde `tokens.json`, y usar `spec.json` como referencia de estructura. Los nombres de token sirven para los dos temas; noche usa `night.*`.
- **Hora:** usar `FontFeature.tabularFigures()` y centrar la hora como bloque. En Penpot cada dígito va en una caja de ancho fijo alineado a la izquierda, y por eso horas como «11:17» se ven algo descentradas. No hay que copiar esas cajas.
- El teclado de 05.4 es solo de referencia: se usa el del sistema.
- Las etiquetas de TalkBack y el comportamiento con escala de texto están en las notas de accesibilidad de cada página de Penpot (05–09) y resumidos en la nota.

## 5. Abierto o sin confirmar

A decidir por el usuario (sin cambiar en el diseño):
- «Nueva» y «Guardar» en la cabecera de Alarma miden 48. Son pantallas de configuración y cumplen la regla, pero podrían subir a 72 como las de Cocina.
- El mismo aviso de noche tiene textos distintos en 02.6n («No llega a la alarma») y 07.5n («Con 9 % no llega a las 6:30»).

Pendiente de probar en el teléfono:
- Lectura a 2 m y tamaño real de la hora.
- Brillo mínimo de la pantalla LCD y si el ámbar de noche deslumbra.
- Contraste con fotos reales: las de ejemplo son sintéticas.
- Nombres de menú de EMUI en la guía de Huawei (08.5).

Decisiones mantenidas a sabiendas: el texto secundario de noche (3,6:1) y el rojo de noche (3,1:1) quedan por debajo de 4,5:1 para no subir el brillo.

## 6. Fase 2 del plan (auditoría con Impeccable): cubierta

- `design/auditoria_impeccable.md`: reúne todas las críticas y auditorías de Impeccable. Para cada hallazgo indica su gravedad y cómo se resolvió en Penpot. Nota final **14/16**; no quedan P0–P2 abiertos, que es la puerta de la fase 2. Los informes originales están en `phone_work/.impeccable/critique/`.
- `phone_work/DESIGN.md` (raíz del proyecto, donde lo busca Impeccable): el sistema de diseño final en el formato DESIGN.md.
  - El frontmatter lleva los tokens: colores clave de claro, oscuro y noche, 13 estilos de texto, radios, espaciado y componentes.
  - Después vienen 8 secciones con las reglas, entre ellas «The One Hearth Rule», «The Steady Clock Rule» y «The Flat Appliance Rule».
  - North Star: «El reloj de la casa».
  - Sidecar con metadatos y fragmentos de componentes en `phone_work/.impeccable/design.json`.
- Fuente para el paquete `design_system` (fase 3): `DESIGN.md` para las reglas y `referencia_penpot/tokens.json` para los valores completos por tema. `DESIGN.md` no sustituye a `tokens.json`.
- Siguiente puerta: **fase 3, base del monorepo**.

## 7. Cómo se trabaja con Penpot (por si hay que volver a tocarlo)

- Arrancar el servidor MCP local con `design_system/tools/penpot-mcp/start.sh`. El usuario conecta el plugin con ⌘⌥P → Penpot MCP Plugin → Connect to MCP server.
- Comprobar siempre con `node call.mjs execute_code @ping.js` que el archivo es «New File 3».
- Los textos no cambian de color con el tema: cambiar de tema exige reconstruir los componentes y todas las páginas.
- **Proceso acordado con el usuario:**
  1. Reconstruir solo lo afectado.
  2. Exportar solo esas pantallas.
  3. Auditar con Impeccable y corregir.
  4. Con el visto bueno, lanzar **una sola vez** la secuencia completa `bash out/_final.sh` (unos 90 min, en segundo plano).
- Antes de cerrar la pestaña de Penpot hay que esperar a que guarde. Detalle en `ESTADO.md` y en `NOTA_diseno.md` §5.
