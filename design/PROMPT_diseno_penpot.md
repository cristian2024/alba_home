# Prompt para el chat de diseño en Penpot

Antes de pegarlo:

1. En Penpot, crea un archivo nuevo llamado **Alba** y ábrelo en Zen. La API no puede renombrar archivos, así que hazlo desde la interfaz.
2. Copia en un chat nuevo de este workspace todo lo que está debajo de la línea.

---

Vamos a diseñar en Penpot la app **Alba**: convierte un Huawei Mate 20 Lite en un aparato de mesa de noche y cocina con reloj, alarma, sonidos para dormir, temporizadores de cocina, marco de fotos y avisos de batería. Va siempre en horizontal, siempre enchufado, sin internet, y es la pantalla de inicio del teléfono: **debe dejar de parecer un celular**.

Lee primero `PLAN.md` en la raíz del workspace, sobre todo el §3 (diseño), el §6 (qué hace cada funcionalidad) y el §9 (decisiones). Este chat cubre **solo la fase 1, el diseño**. La auditoría con Impeccable (fase 2) se hará en otro chat, para que la revise alguien que no diseñó. No escribas código Flutter ni toques nada fuera de `design/`.

## Conexión con Penpot

Se reutiliza la herramienta de `/Users/daniel/Documents/projects/design_system/tools/penpot-mcp`. Antes de empezar, lee `/Users/daniel/Documents/projects/design_system/NOTA_migracion_penpot.md`, que explica cómo conectar y qué falla.

1. Comprueba si el servidor ya está escuchando en los puertos 4400 a 4403. Si no, arráncalo **en segundo plano** con `/Users/daniel/Documents/projects/design_system/tools/penpot-mcp/start.sh`.
2. Pídeme que abra el archivo **Alba**, pulse `⌘⌥P`, abra **Penpot MCP Plugin** y pulse **Connect to MCP server**. No uses el menú **MCP server** del archivo: ese es el servidor alojado.
3. Comprueba la conexión con `node call.mjs` desde esa carpeta, confirmando que responde con el archivo Alba y no con otro. **No toques el archivo de home_tasks («New File 1»).**
4. La pestaña debe quedar visible. Antes de cerrarla, espera a que Penpot guarde.

No modifiques los scripts de `design_system/tools/penpot-mcp/migration`: son de home_tasks. Si te sirven de base, cópialos a `phone_work/design/penpot/` y adáptalos ahí.

## Reglas del archivo

- **Una página por flujo**, y el sistema de diseño en páginas propias. Las páginas son las del §3.2 de `PLAN.md`, de `00 Tokens` a `09 Navegación`.
- Pantallas de **891 × 411** (Mate 20 Lite en horizontal), sin barra de estado ni botones de navegación.
- Variantes: **claro** y **oscuro** en todas las pantallas, y además **noche** en el reloj y en las pantallas que se vean de noche (alarma sonando, sonidos). El modo noche no es el tema oscuro: es negro puro con texto ámbar o rojo tenue y brillo mínimo, igual en los dos temas.
- Tokens en Penpot (con temas Light y Dark) y todos los rellenos, bordes y textos enlazados a un token. Nada de colores sueltos.
- Componentes reutilizables y pantallas hechas con instancias de esos componentes.
- Textos reales en español, como los vería el usuario. Datos de ejemplo verosímiles.

## Identidad visual

- Tema propio de ambiente, **no** la paleta morada de home_tasks. Punto de partida: negro y grises cálidos, blanco cálido y ámbar como acento. En claro, el equivalente cálido. Propón la paleta antes de aplicarla.
- Se reutiliza la **estructura** de tokens de home_tasks (primitivos → semánticos por tema; nombres como `bg.surface-raised` o `text.on-brand`), para que el paquete `design_system` en Flutter siga el mismo patrón. Míralo en `/Users/daniel/Documents/projects/home_tasks/packages/design_system` y en `design_system/referencia_penpot/tokens.json`.
- Tipografía del reloj: números tabulares, gruesa, sin confusión entre 1 y 7. Debe tener licencia libre (OFL o similar) porque irá incluida en la app. Propón dos o tres opciones con su licencia.

## Criterios obligatorios (§3.3 del plan)

- Reloj con la **distribución B**: hora abajo al centro, con un degradado inferior sobre la foto. La hora ocupa unos 35 a 40 % del alto y se lee a 2 m.
- Contraste de la hora de **al menos 7:1** sobre el peor caso de foto. Comprueba con una foto clara (cielo o nieve) y anota la opacidad del degradado que lo consigue.
- Áreas táctiles de al menos 48, y de unos 72 en alarma sonando y cocina.
- Sin barra superior de app, sin menús de tres puntos ni nada que recuerde a un celular. Ajustes detrás de una pulsación larga sobre la hora.
- Las cápsulas de estado (próxima alarma, temporizador en marcha, batería) y los avisos (alarma, temporizador terminado, batería) son componentes genéricos: icono, texto, prioridad y urgencia. Así cualquier funcionalidad los usa igual.
- Estados vacíos, de error y de permisos (p. ej. alarma exacta denegada, carpeta de fotos vacía).

## Cómo trabajar

Ve por etapas y **para a pedirme visto bueno** al final de cada una:

1. **Propuesta:** paleta clara y oscura, opciones de tipografía y la lista completa de pantallas por página. Sin tocar Penpot todavía.
2. **Tokens** (`00 Tokens`) con temas Light y Dark.
3. **Componentes** (`01 Componentes`).
4. **Reloj** (`02 Reloj`): es la pantalla principal y fija el estilo del resto. Muéstramela exportada en PNG antes de seguir.
5. **Resto de flujos**, página por página.
6. **Exportación:** PNG de cada pantalla en `design/referencia_penpot/{claro,oscuro,noche}/` con numeración y nombre (`01_reloj_dia_foto.png`…), un `spec.json` con medidas y el token de cada color y texto, y un `tokens.json`. Puedes usar como guía la estructura de `design_system/referencia_penpot/`.

Revisa cada pantalla en el PNG exportado, no solo en el archivo: la primera exportación después de cambiar de tema es poco fiable.

Versiona en `design/penpot/` los scripts que generen tokens, componentes y pantallas, para poder rehacer el archivo.

## Al terminar

Escribe `design/NOTA_diseno.md` con:
- Enlace al archivo Alba y qué contiene cada página.
- Decisiones tomadas y por qué (paleta, tipografía, opacidad del degradado, tamaños).
- Lo que quedó sin confirmar o con fallos conocidos.
- Cómo volver a conectar y cómo reconstruir con los scripts.

Esa nota es la entrada del chat de auditoría con Impeccable.
