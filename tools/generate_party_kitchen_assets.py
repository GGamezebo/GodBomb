#!/usr/bin/env python3
"""Generate Party Kitchen SVG assets (stdlib only, no Pillow)."""

from __future__ import annotations

import os

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "assets", "party_kitchen"))


SLIME_PALETTE = [
    ("#D71E22", "#9A1518"),
    ("#132ED1", "#0E2299"),
    ("#117F2D", "#0C5A20"),
    ("#ED54BA", "#B53D8E"),
    ("#EF7D0D", "#B35E0A"),
    ("#F5F557", "#C4C445"),
    ("#3F474E", "#2A2F33"),
    ("#D6E0F0", "#A8B4C8"),
    ("#6B2FBC", "#4F2290"),
    ("#71491E", "#523610"),
    ("#38FEDC", "#2ABFB0"),
    ("#50EF39", "#3DB82C"),
]


def write(path: str, content: str) -> None:
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8") as f:
        f.write(content)
    print("wrote", path)


def slime_svg(main: str, dark: str) -> str:
    outline = "#1A1410"
    main_u = main.upper()
    rim = dark
    gloss_main = "0.30"
    gloss_hot = "0.46"
    if main_u == "#3F474E":
        rim = "#252B30"
        gloss_main = "0.16"
        gloss_hot = "0.24"
    elif main_u == "#D6E0F0":
        rim = "#A8B4C8"
        gloss_main = "0.38"
        gloss_hot = "0.55"
    elif main_u in ("#F5F557", "#50EF39", "#38FEDC"):
        gloss_main = "0.34"
        gloss_hot = "0.50"

    bump_dark = "#8F5E2C"
    bump = "#C68642"
    pupil = "#12100E"

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <ellipse cx="64" cy="116" rx="36" ry="8" fill="#000000" opacity="0.24"/>
  <circle cx="64" cy="72" r="46" fill="{rim}"/>
  <circle cx="64" cy="70" r="42" fill="{main}" stroke="{outline}" stroke-width="2"/>
  <ellipse cx="64" cy="92" rx="30" ry="16" fill="#FF7A2A" opacity="0.07"/>
  <ellipse cx="64" cy="86" rx="34" ry="20" fill="{dark}" opacity="0.40"/>
  <ellipse cx="50" cy="50" rx="20" ry="14" fill="#FFFFFF" opacity="{gloss_main}"/>
  <ellipse cx="44" cy="44" rx="9" ry="6" fill="#FFFFFF" opacity="{gloss_hot}"/>
  <ellipse cx="52" cy="32" rx="8" ry="10" fill="{bump_dark}" stroke="{outline}" stroke-width="1.5"/>
  <ellipse cx="52" cy="31" rx="6" ry="7" fill="{bump}"/>
  <ellipse cx="76" cy="32" rx="8" ry="10" fill="{bump_dark}" stroke="{outline}" stroke-width="1.5"/>
  <ellipse cx="76" cy="31" rx="6" ry="7" fill="{bump}"/>
  <ellipse cx="50" cy="68" rx="13" ry="15" fill="#FFFFFF" stroke="{outline}" stroke-width="2"/>
  <ellipse cx="78" cy="68" rx="13" ry="15" fill="#FFFFFF" stroke="{outline}" stroke-width="2"/>
  <circle cx="53" cy="70" r="5" fill="{pupil}"/>
  <circle cx="81" cy="70" r="5" fill="{pupil}"/>
  <circle cx="51" cy="66" r="2.2" fill="#FFFFFF" opacity="0.95"/>
  <circle cx="79" cy="66" r="2.2" fill="#FFFFFF" opacity="0.95"/>
</svg>
"""


def color_swatch_svg(main: str, dark: str, locked: bool = False) -> str:
    lock = ""
    if locked:
        lock = """
  <line x1="16" y1="16" x2="56" y2="56" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round"/>
  <line x1="56" y1="16" x2="16" y2="56" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round"/>
  <rect x="0" y="0" width="72" height="72" rx="36" fill="#000000" opacity="0.45"/>
"""
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 72 72" width="72" height="72">
  <circle cx="36" cy="36" r="32" fill="{dark}" stroke="#2A2118" stroke-width="3"/>
  <circle cx="36" cy="36" r="26" fill="{main}"/>
{lock}
</svg>
"""


def background_svg() -> str:
    return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1080 1920" width="1080" height="1920">
  <defs>
    <linearGradient id="wall" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#FFF4E8"/>
      <stop offset="55%" stop-color="#FFE8D6"/>
      <stop offset="100%" stop-color="#FFDCC4"/>
    </linearGradient>
    <pattern id="tiles" width="120" height="120" patternUnits="userSpaceOnUse">
      <rect width="120" height="120" fill="#FFE8D6"/>
      <rect x="4" y="4" width="112" height="112" rx="8" fill="#FFF7EF" opacity="0.65"/>
    </pattern>
  </defs>
  <rect width="1080" height="1920" fill="url(#wall)"/>
  <rect width="1080" height="960" fill="url(#tiles)" opacity="0.35"/>
  <ellipse cx="540" cy="980" rx="520" ry="420" fill="#000000" opacity="0.06"/>
  <text x="540" y="120" text-anchor="middle" font-family="Arial, sans-serif" font-size="72" font-weight="700" fill="#5C4033">БОМБА</text>
  <text x="540" y="175" text-anchor="middle" font-family="Arial, sans-serif" font-size="28" fill="#8B6914" opacity="0.85">Party Kitchen</text>
</svg>
"""


def table_svg() -> str:
    return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640" width="640" height="640">
  <defs>
    <radialGradient id="wood" cx="45%" cy="40%" r="60%">
      <stop offset="0%" stop-color="#E8B87A"/>
      <stop offset="100%" stop-color="#B87941"/>
    </radialGradient>
  </defs>
  <ellipse cx="320" cy="340" rx="290" ry="270" fill="#000000" opacity="0.15"/>
  <ellipse cx="320" cy="320" rx="290" ry="270" fill="url(#wood)" stroke="#8B5A2B" stroke-width="8"/>
  <ellipse cx="320" cy="300" rx="220" ry="200" fill="#C98952" opacity="0.35"/>
  <ellipse cx="250" cy="260" rx="80" ry="40" fill="#FFFFFF" opacity="0.12"/>
  <circle cx="320" cy="320" r="52" fill="#A66B38" opacity="0.25"/>
  <circle cx="320" cy="320" r="36" fill="#8B5A2B" opacity="0.2"/>
</svg>
"""


def chair_svg() -> str:
    return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100" height="100">
  <ellipse cx="50" cy="88" rx="34" ry="8" fill="#000000" opacity="0.12"/>
  <rect x="22" y="58" width="56" height="14" rx="6" fill="#8B5A2B"/>
  <rect x="26" y="18" width="48" height="44" rx="14" fill="#D4956A" stroke="#8B5A2B" stroke-width="3"/>
  <rect x="30" y="24" width="40" height="32" rx="10" fill="#E8B87A"/>
  <rect x="24" y="66" width="8" height="22" rx="3" fill="#6B4423"/>
  <rect x="68" y="66" width="8" height="22" rx="3" fill="#6B4423"/>
</svg>
"""


def plate_button_svg(kind: str, accent: str, bg: str) -> str:
    if kind == "plus":
        symbol = f"""  <line x1="72" y1="48" x2="72" y2="88" stroke="{accent}" stroke-width="10" stroke-linecap="round"/>
  <line x1="52" y1="68" x2="92" y2="68" stroke="{accent}" stroke-width="10" stroke-linecap="round"/>"""
    else:
        symbol = f"""  <line x1="52" y1="68" x2="92" y2="68" stroke="{accent}" stroke-width="10" stroke-linecap="round"/>"""
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 144 144" width="144" height="144">
  <ellipse cx="72" cy="78" rx="58" ry="14" fill="#000000" opacity="0.12"/>
  <circle cx="72" cy="68" r="56" fill="#FFFDF8" stroke="#E8D5C4" stroke-width="4"/>
  <circle cx="72" cy="68" r="44" fill="{bg}" opacity="0.15"/>
{symbol}
</svg>
"""


def start_button_svg(active: bool) -> str:
    if active:
        fill, stroke = "#FF6B4A", "#C44E32"
    else:
        fill, stroke = "#B8B0A8", "#8A827A"
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 440 120" width="440" height="120">
  <rect x="8" y="14" width="424" height="92" rx="46" fill="#000000" opacity="0.12"/>
  <rect x="0" y="6" width="424" height="92" rx="46" fill="{fill}" stroke="{stroke}" stroke-width="5"/>
</svg>
"""


def panel_svg() -> str:
    return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 840" width="720" height="840">
  <defs>
    <linearGradient id="panel" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#FFF9F2"/>
      <stop offset="100%" stop-color="#FFEEDD"/>
    </linearGradient>
  </defs>
  <rect x="8" y="12" width="704" height="820" rx="36" fill="#000000" opacity="0.12"/>
  <rect x="0" y="0" width="704" height="820" rx="36" fill="url(#panel)" stroke="#E8C9A8" stroke-width="6"/>
  <rect x="24" y="24" width="656" height="772" rx="28" fill="#FFFFFF" opacity="0.35"/>
</svg>
"""


def main() -> None:
    write("background_menu.svg", background_svg())
    write("table.svg", table_svg())
    write("chair.svg", chair_svg())
    write("edit_panel.svg", panel_svg())
    write("buttons/start_active.svg", start_button_svg(True))
    write("buttons/start_inactive.svg", start_button_svg(False))
    write("buttons/add_player.svg", plate_button_svg("plus", "#2EAE55", "#2EAE55"))
    write("buttons/remove_player.svg", plate_button_svg("minus", "#D64545", "#D64545"))

    for i, (main, dark) in enumerate(SLIME_PALETTE):
        write(f"slimes/{i}.svg", slime_svg(main, dark))
        write(f"color_swatches/{i}.svg", color_swatch_svg(main, dark, False))
        write(f"color_swatches/{i}_locked.svg", color_swatch_svg(main, dark, True))

    print("Done:", ROOT)


if __name__ == "__main__":
    main()
