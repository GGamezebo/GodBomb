#!/usr/bin/env python3
"""Resize GodBomb image assets for portrait mobile (1080x1920 design)."""

from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Callable

from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets")
ROOT = os.path.normpath(ROOT)

DESIGN_W = 1080
DESIGN_H = 1920
IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".webp"}


@dataclass
class ResizeAction:
    rel_path: str
    before: tuple[int, int]
    after: tuple[int, int]
    rule: str


def _scale_to_max(width: int, height: int, max_edge: int) -> tuple[int, int]:
    longest = max(width, height)
    if longest <= max_edge:
        return width, height
    factor = max_edge / float(longest)
    return max(1, int(round(width * factor))), max(1, int(round(height * factor)))


def _pick_rule(rel_path: str, width: int, height: int) -> tuple[tuple[int, int], str] | None:
    normalized = rel_path.replace("\\", "/").lower()

    if width == DESIGN_W and height == DESIGN_H:
        return None

    if normalized.endswith("background_menu.png"):
        return (DESIGN_W, DESIGN_H), "menu_background"

    if normalized.startswith("textures/background/") or normalized.endswith("/background.png"):
        return (DESIGN_W, DESIGN_H), "game_background"

    if normalized.endswith("/bp.png") and height >= 1500:
        return (DESIGN_W, DESIGN_H), "bp_background"

    if normalized.startswith("slimes/"):
        target = _scale_to_max(width, height, 256)
        if target == (width, height):
            return None
        return target, "slime_icon"

    if "quit.png" in normalized or "playersschemes.png" in normalized:
        target = _scale_to_max(width, height, 512)
        if target == (width, height):
            return None
        return target, "large_ui_panel"

    if normalized.endswith("/chair.png"):
        target = _scale_to_max(width, height, 160)
        if target == (width, height):
            return None
        return target, "chair_icon"

    if normalized.endswith("cartoonbomb1.png"):
        target = _scale_to_max(width, height, 512)
        if target == (width, height):
            return None
        return target, "bomb_sprite"

    return None


def _save_image(path: str, image: Image.Image) -> None:
    ext = os.path.splitext(path)[1].lower()
    if ext in {".jpg", ".jpeg"}:
        rgb = image.convert("RGB")
        rgb.save(path, quality=90, optimize=True)
        return
    if ext == ".webp":
        image.save(path, quality=90, method=6)
        return
    image.save(path, optimize=True)


def resize_assets(dry_run: bool = False) -> list[ResizeAction]:
    actions: list[ResizeAction] = []

    for dirpath, _, files in os.walk(ROOT):
        for filename in files:
            ext = os.path.splitext(filename)[1].lower()
            if ext not in IMAGE_EXTS:
                continue

            abs_path = os.path.join(dirpath, filename)
            rel_path = os.path.relpath(abs_path, ROOT)
            with Image.open(abs_path) as image:
                width, height = image.size
                picked = _pick_rule(rel_path, width, height)
                if picked is None:
                    continue

                target_size, rule = picked
                if target_size == (width, height):
                    continue

                actions.append(
                    ResizeAction(
                        rel_path=rel_path,
                        before=(width, height),
                        after=target_size,
                        rule=rule,
                    )
                )

                if dry_run:
                    continue

                resized = image.resize(target_size, Image.Resampling.LANCZOS)
                _save_image(abs_path, resized)

    return actions


if __name__ == "__main__":
    changed = resize_assets(dry_run=False)
    print("Resized {} files:".format(len(changed)))
    for action in changed:
        print(
            "  [{}] {} ({}x{}) -> {}x{}".format(
                action.rule,
                action.rel_path,
                action.before[0],
                action.before[1],
                action.after[0],
                action.after[1],
            )
        )
