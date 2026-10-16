#!/usr/bin/env python3
"""Build all app and store icons from the square master art (assets/reference/store/app_icon_1024.png).

The master is a full-bleed square (phone bomb with dynamite on a red radial background).

Outputs:
  assets/icon.png                       1024, project icon (desktop, web/Yandex favicon, Godot boot splash)
  assets/boot_splash.png                1024, art shrunk into the Android 12 splash circle on black
  assets/icon_192.png                   Android legacy launcher
  assets/icon_adaptive_fg.png           432, art inside the adaptive-icon safe zone, feathered edges
  assets/icon_adaptive_bg.png           432, dark-red radial continuing the art background
  assets/icon_adaptive_mono.png         432, white silhouette with shading (Android 13+ themed icon; tinted by alpha)
  assets/reference/store/google_play_icon_512.png   Play store icon (square, Play rounds the corners)
  assets/reference/store/yandex_icon_512.png        Yandex Games / RuStore icon
"""

from __future__ import annotations

import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
STORE = ASSETS / "reference/store"
SRC = STORE / "app_icon_1024.png"


def radial(art: Image.Image, size: int, art_px: float) -> Image.Image:
	"""Background layer for the adaptive icon: the art's own edge colours continued outward.

	The radial profile (distance from centre -> colour) is read from the art's left and right
	edge columns, which are free of the object and cover radii 0.5..0.707 of the art width.
	"""
	src = art.convert("RGB")
	w = src.width
	half = w / 2.0
	sums: dict[int, list[int]] = {}
	for x in (1, w - 2):
		for y in range(w):
			r = round(math.hypot(x + 0.5 - half, y + 0.5 - half) / w * 1000)
			acc = sums.setdefault(r, [0, 0, 0, 0])
			px = src.getpixel((x, y))
			acc[0] += px[0]; acc[1] += px[1]; acc[2] += px[2]; acc[3] += 1
	profile = {r: tuple(c // a[3] for c in a[:3]) for r, a in sums.items()}
	rmin, rmax = min(profile), max(profile)
	keys = sorted(profile)
	lut = {}
	for r in range(rmin, rmax + 1):
		k = min(keys, key=lambda q: abs(q - r))
		lut[r] = profile[k]
	bg = Image.new("RGB", (size, size))
	px = bg.load()
	c = size / 2.0
	for y in range(size):
		for x in range(size):
			r = round(math.hypot(x + 0.5 - c, y + 0.5 - c) / art_px * 1000)
			px[x, y] = lut[min(max(r, rmin), rmax)]
	return bg.filter(ImageFilter.GaussianBlur(3))


def monochrome(fg: Image.Image, bg: Image.Image) -> Image.Image:
	"""Themed-icon layer: object mask (where the foreground differs from the background) shaded by luminance."""
	f = np.asarray(fg.convert("RGBA")).astype(np.float32)
	b = np.asarray(bg.convert("RGB")).astype(np.float32)
	diff = np.abs(f[..., :3] - b).max(-1) * f[..., 3] / 255
	mask = Image.fromarray((np.clip((diff - 45) / 40, 0, 1) * 255).astype(np.uint8))
	mask = np.asarray(mask.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(1.0))).astype(np.float32) / 255
	lum = np.asarray(fg.convert("L")).astype(np.float32) / 255
	out = np.zeros((fg.height, fg.width, 4), np.uint8)
	out[..., :3] = 255
	out[..., 3] = (mask * np.clip(0.45 + lum * 1.3, 0, 1) * 255).astype(np.uint8)
	return Image.fromarray(out, "RGBA")


def feathered(art: Image.Image, px: int, feather: int, shape: str = "rect") -> Image.Image:
	scaled = art.resize((px, px), Image.Resampling.LANCZOS).convert("RGBA")
	mask = Image.new("L", (px, px), 0)
	box = (feather, feather, px - feather, px - feather)
	draw = ImageDraw.Draw(mask)
	draw.ellipse(box, fill=255) if shape == "circle" else draw.rectangle(box, fill=255)
	scaled.putalpha(mask.filter(ImageFilter.GaussianBlur(feather / 2)))
	return scaled


def on_canvas(bg: Image.Image, layer: Image.Image) -> Image.Image:
	out = bg.convert("RGBA")
	off = ((out.width - layer.width) // 2, (out.height - layer.height) // 2)
	out.alpha_composite(layer, off)
	return out


def main() -> None:
	art = Image.open(SRC).convert("RGB")
	art.save(ASSETS / "icon.png", optimize=True)
	art.resize((192, 192), Image.Resampling.LANCZOS).save(ASSETS / "icon_192.png", optimize=True)
	for name in ("google_play_icon_512.png", "yandex_icon_512.png"):
		art.resize((512, 512), Image.Resampling.LANCZOS).save(STORE / name, optimize=True)

	# Android 12 splash shows the icon inside a circle of 2/3 of the canvas.
	splash_px = round(1024 * 0.64)
	on_canvas(Image.new("RGB", (1024, 1024), (0, 0, 0)), feathered(art, splash_px, 40, "circle")).save(
		ASSETS / "boot_splash.png", optimize=True)

	# Adaptive icon: launchers show ~2/3 of the 432 canvas; keep the phone inside that.
	art_px = 278
	fg = on_canvas(Image.new("RGBA", (432, 432), (0, 0, 0, 0)), feathered(art, art_px, 18))
	fg.save(ASSETS / "icon_adaptive_fg.png", optimize=True)
	bg = radial(art, 432, art_px)
	bg.save(ASSETS / "icon_adaptive_bg.png", optimize=True)
	monochrome(fg, bg).save(ASSETS / "icon_adaptive_mono.png", optimize=True)
	print("Done.")


if __name__ == "__main__":
	main()
