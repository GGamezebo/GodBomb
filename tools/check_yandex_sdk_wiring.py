#!/usr/bin/env python3
"""Static checks that Yandex Games SDK wiring is export-ready (no Godot required)."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    ep = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
    head = re.search(r"\[preset\.2\](.*?)(?=\n\[preset\.2\.options\])", ep, re.S)
    opts = re.search(r"\[preset\.2\.options\](.*?)(?=\n\[preset\.|\Z)", ep, re.S)
    if not head or not opts:
        print("FAIL: preset.2 missing", file=sys.stderr)
        return 1
    h, o = head.group(1), opts.group(1)
    checks = [
        ('name="Web (Yandex Games)"' in h, "preset name"),
        ('custom_features="yandex"' in h, "custom_features=yandex"),
        ("bin/yandex/index.html" in h, "export index.html"),
        ("assets/reference/*,tools/*" in h, "exclude_filter"),
        ("addons/yandex_games/templates/yandex_template.html" in o, "html shell"),
        ("progressive_web_app/orientation=1" in o, "portrait orientation"),
    ]
    tpl = (ROOT / "addons/yandex_games/templates/yandex_template.html").read_text(encoding="utf-8")
    checks += [
        ("/sdk.js" in tpl, "template /sdk.js"),
        ("LoadingAPI" in tpl and "GameplayAPI" in tpl, "Loading/Gameplay API"),
        ("GodotYandexBridge" in tpl, "JS bridge"),
    ]
    pg = (ROOT / "project.godot").read_text(encoding="utf-8")
    checks += [
        ("YandexGames=" in pg and "PlatformServices=" in pg, "autoloads"),
        ("addons/yandex_games/plugin.cfg" in pg, "plugin enabled"),
        ("auto_call_game_ready=false" in pg, "manual game_ready"),
    ]
    ps = (ROOT / "src/common/platform/platform_services.gd").read_text(encoding="utf-8")
    yg = (ROOT / "addons/yandex_games/yandex_games.gd").read_text(encoding="utf-8")
    ads = (ROOT / "addons/yandex_games/modules/ads.gd").read_text(encoding="utf-8")
    mc = (ROOT / "src/contexts/main_context/main_context.gd").read_text(encoding="utf-8")
    for meth in ("ensure_initialized", "game_ready", "gameplay_start", "gameplay_stop"):
        checks.append((f"func {meth}" in yg and meth in ps, f"API {meth}"))
    checks += [
        ("signal sdk_initialized" in yg, "sdk_initialized signal"),
        ("show_interstitial_if_available" in ads and "show_interstitial_if_available" in ps, "interstitial gate"),
        ('OS.has_feature("yandex")' in ps, "feature gate"),
        ("await_return_to_menu_gate" in mc and "on_left_battle_context" in mc, "main_context hooks"),
        ("ev_game_state_changed" in (ROOT / "src/common/game_events.gd").read_text(encoding="utf-8"), "game events"),
    ]
    failed = [label for ok, label in checks if not ok]
    if failed:
        print("FAIL:", ", ".join(failed), file=sys.stderr)
        return 1
    print("OK: Yandex Games SDK wiring")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
