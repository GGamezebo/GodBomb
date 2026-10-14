#!/usr/bin/env python3
"""Build all app icons from the painted store icon (assets/reference/store/google_play_icon_512.png).

Outputs under assets/:
  icon.png                    1024, full-bleed art fading to black at the edges (project icon)
  boot_splash.png             1024, art shrunk into the Android 12 splash circle (2/3 of canvas)
  icon_192.png                Android legacy launcher
  icon_adaptive_fg.png        432, transparent, art inside the safe zone
  icon_adaptive_bg.png        432, dark-red vignette matching the art edges
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
SRC = ASSETS / "reference/store/google_play_icon_512.png"


def fade_to_black(img: Image.Image, start: float = 0.45, end: float = 0.5) -> Image.Image:
	size = img.width
	mask = Image.new("L", (size, size), 0)
	px = mask.load()
	c = size / 2.0
	for y in range(size):
		for x in range(size):
			r = math.hypot(x + 0.5 - c, y + 0.5 - c) / size
			t = (end - r) / (end - start)
			px[x, y] = round(255 * min(1.0, max(0.0, t)))
	black = Image.new("RGB", img.size, (0, 0, 0))
	return Image.composite(img.convert("RGB"), black, mask).convert("RGBA")


def full_bleed(art: Image.Image, size: int) -> Image.Image:
	return fade_to_black(art.resize((size, size), Image.Resampling.LANCZOS))


def splash(art: Image.Image, size: int, art_scale: float) -> Image.Image:
	inner = round(size * art_scale)
	faded = full_bleed(art, inner)
	canvas = Image.new("RGBA", (size, size), (0, 0, 0, 255))
	offset = (size - inner) // 2
	canvas.paste(faded, (offset, offset))
	return canvas


def adaptive_foreground(art: Image.Image, size: int, art_px: int) -> Image.Image:
	canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	scaled = art.resize((art_px, art_px), Image.Resampling.LANCZOS).convert("RGBA")
	feather = 14
	mask = Image.new("L", (art_px, art_px), 0)
	ImageDraw.Draw(mask).rectangle((feather, feather, art_px - feather, art_px - feather), fill=255)
	mask = mask.filter(ImageFilter.GaussianBlur(feather / 2))
	scaled.putalpha(mask)
	offset = (size - art_px) // 2
	canvas.paste(scaled, (offset, offset), scaled)
	return canvas


def adaptive_background(art: Image.Image, size: int, art_px: int) -> Image.Image:
	# Radial profile taken from the clean top row of the art (distance from center 254..360).
	src = art.convert("RGB")
	half = src.width / 2.0
	row_y = 2
	dy = half - row_y
	profile = {}
	for x in range(src.width):
		r = math.hypot(x + 0.5 - half, dy)
		profile[round(r)] = src.getpixel((x, row_y))
	rmin, rmax = min(profile), max(profile)
	scale = art_px / src.width
	bg = Image.new("RGB", (size, size))
	px = bg.load()
	c = size / 2.0
	for y in range(size):
		for x in range(size):
			r_old = math.hypot(x + 0.5 - c, y + 0.5 - c) / scale
			key = min(max(round(r_old), rmin), rmax)
			while key not in profile and key < rmax:
				key += 1
			px[x, y] = profile.get(key, (0, 0, 0))
	return bg.convert("RGBA")


def main() -> None:
	art = Image.open(SRC).convert("RGB")
	master = full_bleed(art, 1024)
	master.save(ASSETS / "icon.png", optimize=True)
	splash(art, 1024, 0.74).save(ASSETS / "boot_splash.png", optimize=True)
	master.resize((192, 192), Image.Resampling.LANCZOS).save(ASSETS / "icon_192.png", optimize=True)

	art_px = 340
	adaptive_foreground(art, 432, art_px).save(ASSETS / "icon_adaptive_fg.png", optimize=True)
	adaptive_background(art, 432, art_px).save(ASSETS / "icon_adaptive_bg.png", optimize=True)
	print("Done.")


if __name__ == "__main__":
	main()
