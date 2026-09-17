#!/usr/bin/env python3
"""Shrink GodBomb audio/textures for mobile + HTML memory/size.

- Re-encodes music/SFX MP3 to mono lower bitrate (needs imageio-ffmpeg).
- Optimizes Background.png (no upscale).
- Patches .import for VRAM compression / SVG size limits / WAV downmix.
"""

from __future__ import annotations

import configparser
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"

try:
	import imageio_ffmpeg
except ImportError as exc:  # pragma: no cover
	raise SystemExit("pip install imageio-ffmpeg") from exc

try:
	from PIL import Image
except ImportError as exc:  # pragma: no cover
	raise SystemExit("pip install Pillow") from exc

FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()

# Mobile-friendly bitrates. Loops don't need CD quality.
MP3_JOBS = [
	("audio/music/background.mp3", ["-ac", "1", "-ar", "44100", "-b:a", "64k"]),
	("audio/music/game_sound.mp3", ["-ac", "1", "-ar", "44100", "-b:a", "64k"]),
	("audio/music/win.mp3", ["-ac", "1", "-ar", "44100", "-b:a", "80k"]),
	("audio/sfx/Explosion.mp3", ["-ac", "1", "-ar", "44100", "-b:a", "96k"]),
	("audio/sfx/FastTick.mp3", ["-ac", "1", "-ar", "44100", "-b:a", "64k"]),
	("audio/sfx/SlowTick.mp3", ["-ac", "1", "-ar", "44100", "-b:a", "64k"]),
]

# Godot texture compress/mode: 0 lossless, 1 lossy, 2 VRAM Compressed
TEXTURE_VRAM_PARAMS = {
	"compress/mode": "2",
	"compress/high_quality": "false",
	"compress/lossy_quality": "0.7",
	"mipmaps/generate": "false",
	"process/size_limit": "0",
}

FLAG_PARAMS = {
	**TEXTURE_VRAM_PARAMS,
	"process/size_limit": "512",
	"svg/scale": "2.0",
}

SLIME_PARAMS = {
	**TEXTURE_VRAM_PARAMS,
	"process/size_limit": "256",
	"svg/scale": "2.0",
}

UI_ICON_PARAMS = {
	**TEXTURE_VRAM_PARAMS,
	"process/size_limit": "256",
	"svg/scale": "1.0",
}

BACKGROUND_PARAMS = {
	**TEXTURE_VRAM_PARAMS,
	"process/size_limit": "1024",
}

WAV_UI_PARAMS = {
	"force/8_bit": "false",
	"force/mono": "true",
	"force/max_rate": "true",
	"force/max_rate_hz": "22050",
	"edit/trim": "false",
	"edit/normalize": "false",
	"edit/loop_mode": "0",
	"edit/loop_begin": "0",
	"edit/loop_end": "-1",
	"compress/mode": "2",
}

WAV_COUNTDOWN_PARAMS = {
	**WAV_UI_PARAMS,
	"force/max_rate_hz": "44100",
}


def _human(n: int) -> str:
	if n >= 1024 * 1024:
		return f"{n / (1024 * 1024):.2f} MB"
	return f"{n / 1024:.1f} KB"


def reencode_mp3(rel: str, ffmpeg_args: list[str]) -> tuple[int, int]:
	src = ASSETS / rel
	before = src.stat().st_size
	with tempfile.TemporaryDirectory() as tmp:
		dst = Path(tmp) / src.name
		cmd = [
			FFMPEG,
			"-y",
			"-i",
			str(src),
			"-vn",
			"-map_metadata",
			"-1",
			*ffmpeg_args,
			str(dst),
		]
		proc = subprocess.run(cmd, capture_output=True, text=True)
		if proc.returncode != 0:
			raise RuntimeError(f"ffmpeg failed for {rel}:\n{proc.stderr[-800:]}")
		after = dst.stat().st_size
		if after >= before * 0.98:
			print(f"  skip {rel}: already small ({_human(before)})")
			return before, before
		shutil.copy2(dst, src)
	return before, src.stat().st_size


def optimize_background_png() -> tuple[int, int] | None:
	path = ASSETS / "textures/Background/Background.png"
	if not path.exists():
		return None
	before = path.stat().st_size
	with Image.open(path) as img:
		w, h = img.size
		# Keep below design; do not upscale. Cap longest edge at 1024.
		longest = max(w, h)
		if longest > 1024:
			factor = 1024 / float(longest)
			target = (max(1, int(round(w * factor))), max(1, int(round(h * factor))))
			img = img.resize(target, Image.Resampling.LANCZOS)
		elif img.mode not in ("RGB", "RGBA"):
			img = img.convert("RGBA" if "A" in img.getbands() else "RGB")
		else:
			img = img.copy()
		tmp = path.with_suffix(".opt.png")
		img.save(tmp, format="PNG", optimize=True, compress_level=9)
	after = tmp.stat().st_size
	if after < before:
		tmp.replace(path)
		return before, after
	tmp.unlink(missing_ok=True)
	return before, before


def _patch_import_params(import_path: Path, updates: dict[str, str]) -> bool:
	if not import_path.exists():
		return False
	text = import_path.read_text(encoding="utf-8")
	if "[params]" not in text:
		return False
	head, params = text.split("[params]", 1)
	changed = False
	for key, value in updates.items():
		pattern = re.compile(rf"(?m)^{re.escape(key)}=.*$")
		replacement = f"{key}={value}"
		if pattern.search(params):
			new_params, n = pattern.subn(replacement, params, count=1)
			if n and new_params != params:
				params = new_params
				changed = True
		else:
			params = params.rstrip() + "\n" + replacement + "\n"
			changed = True
	# Force reimport: clear stale vram_texture=false metadata hint by leaving remap;
	# Godot refreshes metadata on next import.
	if "vram_texture" in head and updates.get("compress/mode") == "2":
		head2 = re.sub(r'"vram_texture":\s*false', '"vram_texture": true', head)
		if head2 != head:
			head = head2
			changed = True
	if not changed:
		return False
	import_path.write_text(head + "[params]" + params, encoding="utf-8")
	return True


def patch_imports() -> list[str]:
	touched: list[str] = []
	bg = ASSETS / "textures/Background/Background.png.import"
	if _patch_import_params(bg, BACKGROUND_PARAMS):
		touched.append(str(bg.relative_to(ROOT)))

	for path in (ASSETS / "ui/flags").glob("*.svg.import"):
		if _patch_import_params(path, FLAG_PARAMS):
			touched.append(str(path.relative_to(ROOT)))

	for path in (ASSETS / "party_kitchen/slimes").glob("*.svg.import"):
		if _patch_import_params(path, SLIME_PARAMS):
			touched.append(str(path.relative_to(ROOT)))

	for path in (ASSETS / "party_kitchen").rglob("*.svg.import"):
		if "slimes" in path.parts:
			continue
		if _patch_import_params(path, UI_ICON_PARAMS):
			touched.append(str(path.relative_to(ROOT)))

	for path in (ASSETS / "ui/theme").glob("*.svg.import"):
		if _patch_import_params(path, UI_ICON_PARAMS):
			touched.append(str(path.relative_to(ROOT)))

	countdown = ASSETS / "audio/sfx/Countdown.wav.import"
	if _patch_import_params(countdown, WAV_COUNTDOWN_PARAMS):
		touched.append(str(countdown.relative_to(ROOT)))

	for path in (ASSETS / "audio/ui").glob("*.wav.import"):
		if _patch_import_params(path, WAV_UI_PARAMS):
			touched.append(str(path.relative_to(ROOT)))

	return touched


def ensure_reference_gdignore() -> None:
	ref = ASSETS / "reference"
	ref.mkdir(parents=True, exist_ok=True)
	gdignore = ref / ".gdignore"
	if not gdignore.exists():
		gdignore.write_text("# Editor/concept art — not shipped in builds.\n", encoding="utf-8")


def main() -> None:
	print("FFmpeg:", FFMPEG)
	ensure_reference_gdignore()

	print("\n== MP3 re-encode ==")
	saved = 0
	for rel, args in MP3_JOBS:
		before, after = reencode_mp3(rel, args)
		delta = before - after
		saved += max(0, delta)
		print(f"  {rel}: {_human(before)} -> {_human(after)} ({_human(delta)} saved)")

	print("\n== Background PNG ==")
	bg = optimize_background_png()
	if bg:
		b, a = bg
		saved += max(0, b - a)
		print(f"  Background.png: {_human(b)} -> {_human(a)}")

	print("\n== Import patches ==")
	for path in patch_imports():
		print(f"  patched {path}")

	print(f"\nSource bytes saved (approx): {_human(saved)}")
	print("Open the project in Godot once so .import caches rebuild.")


if __name__ == "__main__":
	main()
