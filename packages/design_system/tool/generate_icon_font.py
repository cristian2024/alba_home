"""Genera assets/fonts/AlbaIcons.ttf con los 58 iconos de Penpot.

Los iconos se dibujan desde sus trazados con `AppIcon`; la fuente da además un
`IconData` por icono (`AppIconData.iconData`) para los contratos que usan el de
Flutter (`HomePlugin.icon`, cápsulas y avisos de `core_contracts`). Cada icono
va en el código 0xE000 + su posición en `spec.json`, el mismo que escribe
`tool/generate_tokens.dart`.

    python3 tool/generate_icon_font.py

Necesita fontTools (`pip install fonttools`).
"""

import json
import re
from pathlib import Path

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen

ROOT = Path(__file__).resolve().parent.parent
SPEC = ROOT.parent.parent / "design" / "referencia_penpot" / "spec.json"
OUT = ROOT / "assets" / "fonts" / "AlbaIcons.ttf"
FIRST_CODEPOINT = 0xE000
UNITS_PER_EM = 1024
VIEWBOX = 24.0
TOKEN = re.compile(r"[MLHVQZ]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?")


def to_font(x, y):
    """Caja de 24 con y hacia abajo → unidades de la fuente con y hacia arriba."""
    scale = UNITS_PER_EM / VIEWBOX
    return round(x * scale), round((VIEWBOX - y) * scale)


def draw(path_data, pen):
    tokens = TOKEN.findall(path_data)
    i, command, x, y, open_contour = 0, "M", 0.0, 0.0, False

    def number():
        nonlocal i
        value = float(tokens[i])
        i += 1
        return value

    while i < len(tokens):
        if tokens[i] in "MLHVQZ":
            command = tokens[i]
            i += 1
            if command == "Z":
                if open_contour:
                    pen.closePath()
                    open_contour = False
                continue
        if command == "M":
            if open_contour:
                pen.closePath()
            x, y = number(), number()
            pen.moveTo(to_font(x, y))
            open_contour = True
            command = "L"
        elif command == "L":
            x, y = number(), number()
            pen.lineTo(to_font(x, y))
        elif command == "H":
            x = number()
            pen.lineTo(to_font(x, y))
        elif command == "V":
            y = number()
            pen.lineTo(to_font(x, y))
        elif command == "Q":
            cx, cy = number(), number()
            x, y = number(), number()
            pen.qCurveTo(to_font(cx, cy), to_font(x, y))
    if open_contour:
        pen.closePath()


def main():
    icons = json.loads(SPEC.read_text())["icons"]
    names = [".notdef"] + [icon["name"] for icon in icons]
    glyphs, metrics, cmap = {}, {}, {}

    notdef = TTGlyphPen(None)
    glyphs[".notdef"] = notdef.glyph()
    metrics[".notdef"] = (UNITS_PER_EM, 0)
    for index, icon in enumerate(icons):
        pen = TTGlyphPen(None)
        draw(icon["d"], pen)
        glyphs[icon["name"]] = pen.glyph()
        metrics[icon["name"]] = (UNITS_PER_EM, 0)
        cmap[FIRST_CODEPOINT + index] = icon["name"]

    builder = FontBuilder(UNITS_PER_EM, isTTF=True)
    builder.setupGlyphOrder(names)
    builder.setupCharacterMap(cmap)
    builder.setupGlyf(glyphs)
    builder.setupHorizontalMetrics(metrics)
    builder.setupHorizontalHeader(ascent=UNITS_PER_EM, descent=0)
    builder.setupNameTable({"familyName": "AlbaIcons", "styleName": "Regular"})
    builder.setupOS2(sTypoAscender=UNITS_PER_EM, sTypoDescender=0, usWinAscent=UNITS_PER_EM, usWinDescent=0)
    builder.setupPost()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    builder.save(str(OUT))
    print(OUT.name, len(icons), "iconos,", OUT.stat().st_size // 1024, "KB")


if __name__ == "__main__":
    main()
