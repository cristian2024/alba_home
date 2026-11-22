# Alba · Etapa 1: propuesta de diseño

Fecha: 2026-11-18. Estado: **pendiente de visto bueno**. No se ha tocado Penpot.

## 1. Paleta

Estructura igual que home_tasks: primitivos → semánticos por tema (`bg.*`, `text.*`, `border.*`, `action.*`), más un grupo `night.*` que no cambia con el tema y un grupo `scrim.*` para el degradado del reloj.

### Primitivos

| Rampa | Valores |
| :--- | :--- |
| `warm` (neutros cálidos) | 0 `#FFFCF7` · 50 `#FAF6EF` · 100 `#F2ECE2` · 200 `#E4DCCF` · 300 `#CFC5B6` · 400 `#ADA294` · 450 `#9C9184` · 500 `#8A7F72` · 550 `#7A6F63` · 600 `#6B6157` · 700 `#4F4740` · 800 `#36302B` · 850 `#2A2521` · 900 `#1F1B18` · 950 `#141210` · 1000 `#0B0A09` |
| `amber` (acento) | 50 `#FFF6E5` · 100 `#FDE9C2` · 200 `#FBD38A` · 300 `#F8BC55` · 400 `#F2A230` · 500 `#E08A14` · 600 `#BD6F0B` · 700 `#96560B` · 800 `#74420E` · 900 `#4F2E0D` · 950 `#2E1A07` |
| `night` | black `#000000` · amber `#C8811F` · amber-dim `#8A5A18` · red `#9E3A2B` |
| Estados | terracota (peligro) `#B8432F` · oliva (éxito) `#5E7A3A` · pizarra (info) `#4A6A85` · ocre (aviso) `#C2780F`, cada uno con su rampa 50–950 |
| `alpha` | `warm.1000` al 0, 40, 60 y 72 % para el degradado y los velos |

El aviso usa **ocre**, separado del ámbar de marca, para que una cápsula de batería baja no se confunda con un botón.

### Semánticos (claro / oscuro)

| Token | Claro | Oscuro |
| :--- | :--- | :--- |
| `bg.canvas` | warm.50 | warm.950 |
| `bg.surface` | warm.0 | warm.900 |
| `bg.surface-raised` | warm.0 | warm.850 |
| `bg.surface-sunken` | warm.100 | warm.1000 |
| `bg.brand-subtle` | amber.50 | amber.950 |
| `text.primary` | warm.900 | warm.100 |
| `text.secondary` | warm.600 | warm.400 |
| `text.tertiary` | warm.550 | warm.450 |
| `text.brand` | amber.700 | amber.300 |
| `text.on-brand` | warm.1000 | warm.1000 |
| `text.on-photo` | warm.0 | warm.0 |
| `action.primary-default` | amber.400 | amber.400 |
| `border.default` | warm.200 | warm.800 |
| `border.focus` | amber.600 | amber.300 |
| (resto: `-hover`, `-pressed`, `danger`, `success`, `warning`, `info`, `disabled`, `scrim`, igual que home_tasks) | | |

El botón principal es ámbar con texto casi negro en los dos temas: así el acento es el mismo de día y de noche y el contraste es 9,4:1.

### Contrastes medidos (WCAG)

| Par | Contraste |
| :--- | :--- |
| Claro `text.primary` sobre `bg.canvas` | 15,9 |
| Claro `text.secondary` sobre `bg.canvas` | 5,6 |
| Claro `text.tertiary` sobre `bg.surface` | 4,8 |
| Claro `text.brand` sobre `bg.canvas` | 5,4 |
| Oscuro `text.primary` sobre `bg.canvas` | 15,9 |
| Oscuro `text.secondary` sobre `bg.canvas` | 7,5 |
| Oscuro `text.tertiary` sobre `bg.surface` | 5,5 |
| Oscuro `text.brand` sobre `bg.canvas` | 11,0 |
| `text.on-brand` sobre `action.primary-default` | 9,4 |
| Noche: hora `night.amber` sobre negro | 6,6 |
| Noche: secundario `night.amber-dim` sobre negro | 3,6 |
| Noche: `night.red` sobre negro | 3,1 |

### Degradado del reloj (peor caso: foto blanca)

Hora en `warm.0` sobre `warm.1000` con opacidad *a* encima de blanco puro:

| Opacidad | 60 % | 64 % | 66 % | 70 % | **72 %** | 76 % |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Contraste | 5,6 | 6,5 | 7,1 | 8,3 | **9,1** | 10,6 |

Propuesta: **72 %** en la franja de la hora (margen sobre 7:1 para fotos con brillos), bajando a 0 % a un 62 % del alto. Se comprobará en el PNG exportado con una foto de nieve.

## 2. Tipografía de la hora

Todas con licencia **SIL Open Font License 1.1**, que permite incluirlas en la app.

| # | Fuente | A favor | En contra |
| :--- | :--- | :--- | :--- |
| 1 | **Inter Display Bold** (recomendada) | Ya está en Penpot y en home_tasks; cifras tabulares (`tnum`); el 1 lleva bandera y el 7 es recto | Algo neutra; el carácter lo dan la foto y el ámbar |
| 2 | Atkinson Hyperlegible Next Bold | Diseñada para baja visión: la menor confusión 1/7 y 0/8 | Hay que comprobar que Penpot la tenga; más ancha |
| 3 | Barlow Semi Condensed SemiBold | Estrecha: deja más foto visible con la hora grande | El 1 y el 7 se parecen más a 2 m |

El resto de textos, en Inter. En Penpot los dígitos del reloj se maquetan en cajas de ancho fijo (componente `Clock/Digit`), así la hora no baila aunque Penpot no active `tnum`. En Flutter se usará `FontFeature.tabularFigures()`.

Tamaño: hora de unos **150 px de alto de cifra** (≈ 37 % de 411), fuente a ~205 px.

## 3. Pantallas por página

Pantallas de 891 × 411. Todas en **claro** y **oscuro**; las marcadas con ☾ también en **noche**.

### 00 Tokens
Colores (primitivos, claro, oscuro, noche, estados), tipografía, espaciado, radios, tamaños táctiles (48 / 72), opacidades del degradado.

### 01 Componentes
`Clock/Digit` y `Clock/Time`, `Status/Capsule` (icono, texto, prioridad: baja/media/alta, urgencia: normal/urgente), `Alert/Banner` y `Alert/FullScreen` (mismas propiedades), `Button/Large` (72) y `Button/Standard` (48) en primario, secundario y fantasma, `Timer/Card`, `Alarm/Row`, `Day/Toggle`, `Sound/Tile`, `Settings/Row`, `Settings/Switch`, `Settings/Stepper`, `Wheel/Picker`, `Empty/State`, `Mode/Dots` (indicador de deslizamiento), iconos.

### 02 Reloj
1. Día con foto (distribución B)
2. Día sin fotos
3. Noche ☾ (solo noche)
4. Transición día → noche (atardecer)
5. Con temporizador en marcha ☾
6. Con próxima alarma y aviso de batería ☾
7. Pulsación larga en curso (anillo de 2 s antes de abrir Ajustes)

### 03 Alarma
1. Lista
2. Lista vacía
3. Crear o editar
4. Repetición por días
5. Alarma sonando ☾
6. Pospuesta (reloj con cápsula de cuenta atrás) ☾
7. Permiso de alarma exacta denegado

### 04 Sonidos
1. Selector de sonido
2. Reproduciendo ☾
3. Temporizador de apagado
4. Vista de noche (pantalla casi negra) ☾

### 05 Cocina
1. Sin temporizadores
2. Varios en marcha
3. Crear con tiempos guardados
4. Nombre del temporizador (único caso con teclado)
5. Terminado sonando
6. Dos terminados a la vez

### 06 Fotos
1. Carpeta vacía con instrucciones (copiar por USB)
2. Ajustes de la presentación
3. Sin permiso de acceso a la carpeta

### 07 Batería
1. Carga alta (quitar el cargador)
2. Carga baja
3. Nivel crítico (pantalla completa) ☾
4. Temperatura alta
5. No llega a la próxima alarma ☾

### 08 Ajustes
1. Índice de ajustes
2. Horario de noche
3. Umbrales de batería
4. Idioma
5. Guía de Huawei: desactivar la gestión automática en *Inicio de aplicaciones*

### 09 Navegación
Mapa de modos: Reloj ⇄ Sonidos ⇄ Cocina deslizando; Alarma y Fotos desde Ajustes; vuelta al reloj tras 1 min sin tocar; qué aviso gana si coinciden dos.

**Total:** 44 pantallas × 2 temas + 11 en noche ≈ 99 exportaciones, más los tableros de tokens, componentes y navegación.
