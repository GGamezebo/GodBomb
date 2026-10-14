"""English store videos for Yandex (MP4 ≤28s) and Google Play (same files → YouTube).

Outputs (not part of the game build):
  assets/reference/store/en_gameplay_16x9.mp4
  assets/reference/store/en_gameplay_9x16.mp4
  assets/reference/store/en_promo_ad_16x9.mp4
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import imageio_ffmpeg
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
STORE = ROOT / "assets" / "reference" / "store"
EN = STORE / "yandex_screen_shots_en"
COVER = STORE / "yandex_cover_800x470.png"
SPLASH = STORE / "screenshots" / "00_title_splash.png"
ICON = STORE / "yandex_icon_512.png"
MUSIC = ROOT / "assets" / "audio" / "music" / "game_sound.mp3"
BOOM_SFX = ROOT / "assets" / "audio" / "sfx" / "Explosion.mp3"
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()

FPS = 30
FADE = 8  # frames of crossfade
CREAM = (255, 246, 230)
ORANGE = (242, 164, 52)
GOLD = (232, 190, 110)
WHITE = (255, 252, 248)

FONT_DISPLAY = Path(r"C:\Windows\Fonts\impact.ttf")
FONT_BODY = Path(r"C:\Windows\Fonts\segoeuib.ttf")
FONT_BODY_REG = Path(r"C:\Windows\Fonts\segoeui.ttf")


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def shot(name: str) -> Path:
    matches = sorted(EN.glob(f"photo_{name}_*.jpg"))
    if not matches:
        raise FileNotFoundError(name)
    return matches[0]


def fit_cover(im: Image.Image, w: int, h: int) -> Image.Image:
    scale = max(w / im.width, h / im.height)
    nw, nh = int(im.width * scale) + 1, int(im.height * scale) + 1
    resized = im.resize((nw, nh), Image.Resampling.LANCZOS)
    left = (nw - w) // 2
    top = (nh - h) // 2
    return resized.crop((left, top, left + w, top + h))


def blur_bg(src: Image.Image, w: int, h: int, radius: int = 26, dark: float = 0.55) -> Image.Image:
    bg = fit_cover(src, w, h).filter(ImageFilter.GaussianBlur(radius))
    bg = ImageEnhance.Brightness(bg).enhance(1.0 - dark)
    return bg


def text_size(draw: ImageDraw.ImageDraw, text: str, face: ImageFont.FreeTypeFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=face)
    return box[2] - box[0], box[3] - box[1]


def draw_centered(
    draw: ImageDraw.ImageDraw,
    text: str,
    y: int,
    face: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int],
    shadow: int = 4,
) -> int:
    w, h = text_size(draw, text, face)
    x = (draw.im.size[0] - w) // 2
    if shadow:
        draw.text((x + shadow, y + shadow), text, font=face, fill=(0, 0, 0))
    draw.text((x, y), text, font=face, fill=fill)
    return h


def rule(draw: ImageDraw.ImageDraw, y: int, width: int = 280, color: tuple[int, int, int] = ORANGE) -> None:
    x = (draw.im.size[0] - width) // 2
    draw.rectangle((x, y, x + width, y + 5), fill=color)


def paste_center(canvas: Image.Image, im: Image.Image, cx: int | None = None, cy: int | None = None) -> None:
    if cx is None:
        cx = canvas.width // 2
    if cy is None:
        cy = canvas.height // 2
    x = cx - im.width // 2
    y = cy - im.height // 2
    if im.mode == "RGBA":
        canvas.paste(im, (x, y), im)
    else:
        canvas.paste(im, (x, y))


def rounded_icon(size: int) -> Image.Image:
    src = Image.open(ICON).convert("RGBA")
    src = src.resize((size, size), Image.Resampling.LANCZOS)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle((1, 1, size - 2, size - 2), radius=int(size * 0.22), fill=255)
    src.putalpha(mask)
    return src


def load_rgb(path: Path) -> Image.Image:
    return Image.open(path).convert("RGB")


def phone_frame(src: Image.Image, w: int, h: int, phone_h: int, y_shift: int = -24) -> Image.Image:
    canvas = blur_bg(src, w, h, radius=28, dark=0.62)
    ph = phone_h
    pw = max(1, int(src.width * ph / src.height))
    phone = src.resize((pw, ph), Image.Resampling.LANCZOS)
    paste_center(canvas, phone, canvas.width // 2, canvas.height // 2 + y_shift)
    return canvas


def logo_frame(w: int, h: int, cover: Image.Image, subtitle: str | None = None) -> Image.Image:
    canvas = blur_bg(cover, w, h, radius=22, dark=0.42)
    target_w = int(w * (0.72 if w > h else 0.92))
    scale = target_w / cover.width
    logo = cover.resize((target_w, int(cover.height * scale)), Image.Resampling.LANCZOS)
    cy = h // 2 - (50 if subtitle else 0)
    paste_center(canvas, logo, canvas.width // 2, cy)
    if subtitle:
        draw = ImageDraw.Draw(canvas)
        face = font(FONT_BODY, 42 if w > h else 36)
        draw_centered(draw, subtitle, cy + logo.height // 2 + 28, face, GOLD, shadow=3)
    return canvas


def end_card(w: int, h: int, cover: Image.Image, icon: Image.Image) -> Image.Image:
    canvas = blur_bg(cover, w, h, radius=30, dark=0.72)
    draw = ImageDraw.Draw(canvas)
    icon_s = 280 if w > h else 420
    icon_r = rounded_icon(icon_s)
    block_h = icon_s + 210
    top = (h - block_h) // 2
    paste_center(canvas, icon_r, canvas.width // 2, top + icon_s // 2)
    y = top + icon_s + 28
    title_size = 78 if w > h else 64
    y += draw_centered(draw, "TIC-TAC-BADA-BOOM", y, font(FONT_DISPLAY, title_size), WHITE) + 16
    y += draw_centered(draw, "Play. Laugh. Explode.", y, font(FONT_BODY, 40 if w > h else 34), ORANGE) + 12
    draw_centered(draw, "Already a classic", y, font(FONT_BODY_REG, 30 if w > h else 26), CREAM, shadow=2)
    return canvas


def promo_ancient(w: int, h: int, cover: Image.Image) -> Image.Image:
    canvas = blur_bg(cover, w, h, radius=34, dark=0.78)
    draw = ImageDraw.Draw(canvas)
    y = h // 2 - 150
    rule(draw, y, 220)
    y += 28
    y += draw_centered(draw, "ANCIENT", y, font(FONT_DISPLAY, 108), WHITE) + 6
    y += draw_centered(draw, "AND AWESOME", y, font(FONT_DISPLAY, 72), ORANGE) + 18
    y += draw_centered(draw, "a party classic", y, font(FONT_BODY, 36), CREAM, shadow=2) + 18
    rule(draw, y, 220)
    return canvas


def promo_loves(w: int, h: int, cover: Image.Image) -> Image.Image:
    canvas = blur_bg(cover, w, h, radius=18, dark=0.55)
    overlay = Image.new("RGB", (w, h), (0, 0, 0))
    canvas = Image.blend(canvas, overlay, 0.35)
    draw = ImageDraw.Draw(canvas)
    y = h // 2 - 130
    y += draw_centered(draw, "EVERYONE LOVES", y, font(FONT_DISPLAY, 92), WHITE) + 4
    y += draw_centered(draw, "THIS GAME", y, font(FONT_DISPLAY, 92), WHITE) + 22
    draw_centered(draw, "two players to a full table", y, font(FONT_BODY, 36), ORANGE)
    return canvas


def caption_bar(canvas: Image.Image, text: str) -> Image.Image:
    out = canvas.copy()
    draw = ImageDraw.Draw(out)
    face = font(FONT_BODY, 42)
    tw, th = text_size(draw, text, face)
    y = out.height - 78
    x = (out.width - tw) // 2
    draw.text((x + 3, y + 3), text, font=face, fill=(0, 0, 0))
    draw.text((x, y), text, font=face, fill=GOLD)
    return out


def kenburns(base: Image.Image, n: int, out_w: int, out_h: int, z0: float, z1: float, pan: tuple[int, int]) -> list[Image.Image]:
    frames: list[Image.Image] = []
    iw, ih = base.size
    for i in range(n):
        t = 0 if n <= 1 else i / (n - 1)
        z = z0 + (z1 - z0) * t
        crop_w = min(iw, max(2, int(out_w / z)))
        crop_h = min(ih, max(2, int(out_h / z)))
        cx = iw // 2 + int(pan[0] * t)
        cy = ih // 2 + int(pan[1] * t)
        left = max(0, min(iw - crop_w, cx - crop_w // 2))
        top = max(0, min(ih - crop_h, cy - crop_h // 2))
        crop = base.crop((left, top, left + crop_w, top + crop_h))
        if crop.size != (out_w, out_h):
            crop = crop.resize((out_w, out_h), Image.Resampling.LANCZOS)
        frames.append(crop)
    return frames


def hi_res(image: Image.Image, out_w: int, out_h: int, super_scale: float = 1.12) -> Image.Image:
    return image.resize((int(out_w * super_scale), int(out_h * super_scale)), Image.Resampling.LANCZOS)


def write_video(path: Path, w: int, h: int, segments, audio_at: list[tuple[Path, int, float]], duration: float) -> None:
    silent = path.with_suffix(".silent.mp4")
    cmd = [
        FFMPEG, "-y", "-loglevel", "error",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{w}x{h}", "-r", str(FPS), "-i", "pipe:0",
        "-an", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-preset", "medium", "-crf", "18",
        "-movflags", "+faststart",
        str(silent),
    ]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    assert proc.stdin is not None
    hold: list[Image.Image] | None = None
    try:
        for frames in segments:
            if len(frames) <= FADE * 2:
                raise RuntimeError("segment shorter than crossfade")
            if hold is None:
                for fr in frames[:-FADE]:
                    proc.stdin.write(fr.tobytes())
                hold = frames[-FADE:]
                continue
            for i in range(FADE):
                blended = Image.blend(hold[i], frames[i], (i + 1) / (FADE + 1))
                proc.stdin.write(blended.tobytes())
            for fr in frames[FADE:-FADE]:
                proc.stdin.write(fr.tobytes())
            hold = frames[-FADE:]
        if hold:
            for fr in hold:
                proc.stdin.write(fr.tobytes())
    finally:
        proc.stdin.close()
        code = proc.wait()
    if code != 0:
        raise RuntimeError(f"ffmpeg video failed ({code})")

    inputs = [FFMPEG, "-y", "-loglevel", "error", "-i", str(silent)]
    for src, _delay, _vol in audio_at:
        inputs += ["-i", str(src)]
    filters = []
    labels = []
    # Music bed: trim to duration, fade in/out.
    fade_out_st = max(0.2, duration - 1.1)
    filters.append(
        f"[1:a]atrim=0:{duration:.3f},asetpts=PTS-STARTPTS,volume=0.72,"
        f"afade=t=in:st=0:d=0.35,afade=t=out:st={fade_out_st:.3f}:d=1.0[bed]"
    )
    labels.append("[bed]")
    for idx, (_src, delay_ms, vol) in enumerate(audio_at[1:], start=2):
        label = f"a{idx}"
        filters.append(
            f"[{idx}:a]adelay={delay_ms}|{delay_ms},volume={vol},apad=pad_dur=30[ {label}]".replace(" ", "")
        )
        labels.append(f"[{label}]")
    mix = "".join(labels)
    filters.append(
        f"{mix}amix=inputs={len(labels)}:duration=first:dropout_transition=0:normalize=0[aout]"
    )
    mux = inputs + [
        "-filter_complex", ";".join(filters),
        "-map", "0:v", "-map", "[aout]",
        "-c:v", "copy", "-c:a", "aac", "-b:a", "160k", "-shortest",
        "-movflags", "+faststart",
        str(path),
    ]
    subprocess.run(mux, check=True)
    silent.unlink(missing_ok=True)
    print(f"{path.name}  {duration:.2f}s")


def build_segments(
    specs: list[tuple[Image.Image, float, float, float, tuple[int, int]]],
    out_w: int,
    out_h: int,
) -> list[list[Image.Image]]:
    segments = []
    for image, seconds, z0, z1, pan in specs:
        n = max(FADE * 2 + 2, int(round(seconds * FPS)))
        base = hi_res(image, out_w, out_h)
        segments.append(kenburns(base, n, out_w, out_h, z0, z1, pan))
    return segments


def gameplay_specs(w: int, h: int, vertical: bool) -> tuple[list, int]:
    cover = load_rgb(COVER)
    icon = load_rgb(ICON)
    splash = load_rgb(SPLASH)
    phone_h = int(h * 0.92) if not vertical else h
    shots = [
        ("2", 2.4),
        ("4", 2.5),
        ("10", 2.5),
        ("9", 2.3),
        ("16", 2.7),
        ("12", 2.5),
        ("14", 2.3),
        ("21", 2.6),
    ]
    images: list[tuple[Image.Image, float, float, float, tuple[int, int]]] = []
    if vertical:
        images.append((fit_cover(splash, w, h), 2.5, 1.0, 1.06, (0, -12)))
    else:
        images.append((logo_frame(w, h, cover), 2.5, 1.0, 1.06, (0, -8)))
    boom_index = 1 + 6  # logo + 6 phones before boom (2,4,10,9,16,12) then boom is index 7
    pans = [(12, 0), (-10, 6), (0, -8), (8, 4), (-12, 0), (6, -6), (0, 8), (-8, 0)]
    for (name, seconds), pan in zip(shots, pans):
        src = load_rgb(shot(name))
        if vertical:
            frame = fit_cover(src, w, h)
        else:
            frame = phone_frame(src, w, h, phone_h=min(phone_h, 1000))
        images.append((frame, seconds, 1.0, 1.05, pan))
    images.append((end_card(w, h, cover, icon) if vertical else logo_frame(w, h, cover, "Play. Laugh. Explode."), 2.6, 1.02, 1.0, (0, 6)))
    # boom shot is the 8th entry (index 7): logo + 6 + boom
    assert boom_index == 7
    return images, boom_index


def boom_time(specs: list, boom_index: int) -> float:
    total = 0.0
    for i, spec in enumerate(specs):
        seconds = spec[1]
        if i == boom_index:
            return total + 0.15
        total += seconds
        if i < len(specs) - 1:
            total -= FADE / FPS
    return total


def promo_specs(w: int, h: int) -> tuple[list, int]:
    cover = load_rgb(COVER)
    icon = load_rgb(ICON)
    phone_h = 860

    def phone(name: str, caption: str) -> Image.Image:
        return caption_bar(phone_frame(load_rgb(shot(name)), w, h, phone_h, y_shift=-36), caption)

    images = [
        (promo_ancient(w, h, cover), 2.6, 1.0, 1.04, (0, 0)),
        (logo_frame(w, h, cover, "Everyone loves it. Everyone plays."), 2.5, 1.0, 1.05, (0, -6)),
        (promo_loves(w, h, cover), 2.6, 1.03, 1.0, (0, 0)),
        (phone("2", "The legendary pass ritual"), 2.3, 1.0, 1.04, (8, 0)),
        (phone("8", "Syllable. Word. Beat the fuse."), 2.4, 1.0, 1.04, (-8, 4)),
        (phone("16", "Pass the bomb — or BOOM"), 2.5, 1.0, 1.05, (0, -6)),
        (phone("10", "Millennia of tension"), 2.3, 1.0, 1.04, (6, 0)),
        (phone("14", "The coolest head wins"), 2.2, 1.02, 1.0, (0, 8)),
        (end_card(w, h, cover, icon), 2.8, 1.0, 1.04, (0, 0)),
    ]
    return images, 7


def iter_segments(specs: list, out_w: int, out_h: int):
    for image, seconds, z0, z1, pan in specs:
        n = max(FADE * 2 + 2, int(round(seconds * FPS)))
        base = hi_res(image, out_w, out_h)
        yield kenburns(base, n, out_w, out_h, z0, z1, pan)
        del base


def render(path: Path, w: int, h: int, specs: list, boom_index: int | None) -> None:
    audio: list[tuple[Path, int, float]] = [(MUSIC, 0, 0.72)]
    if boom_index is not None:
        delay = int(boom_time(specs, boom_index) * 1000)
        audio.append((BOOM_SFX, delay, 0.85))
    frames = sum(max(FADE * 2 + 2, int(round(spec[1] * FPS))) for spec in specs)
    duration = (frames - FADE * (len(specs) - 1)) / FPS
    write_video(path, w, h, iter_segments(specs, w, h), audio, duration)


def preview(folder: Path) -> None:
    folder.mkdir(parents=True, exist_ok=True)
    w, h = 1920, 1080
    specs, _ = promo_specs(w, h)
    for i, spec in enumerate(specs):
        spec[0].resize((960, 540), Image.Resampling.LANCZOS).save(folder / f"promo_{i:02d}.jpg", quality=85)
    gspecs, _ = gameplay_specs(w, h, vertical=False)
    for i, spec in enumerate(gspecs):
        spec[0].resize((640, 360), Image.Resampling.LANCZOS).save(folder / f"gp_{i:02d}.jpg", quality=85)
    vspecs, _ = gameplay_specs(1080, 1920, vertical=True)
    for i, spec in enumerate(vspecs):
        spec[0].resize((270, 480), Image.Resampling.LANCZOS).save(folder / f"v_{i:02d}.jpg", quality=85)
    print("previews", folder)


def main() -> None:
    if "--preview" in sys.argv:
        preview(STORE / "_en_build" / "preview")
        return
    render(STORE / "en_gameplay_16x9.mp4", 1920, 1080, *gameplay_specs(1920, 1080, vertical=False))
    render(STORE / "en_gameplay_9x16.mp4", 1080, 1920, *gameplay_specs(1080, 1920, vertical=True))
    render(STORE / "en_promo_ad_16x9.mp4", 1920, 1080, *promo_specs(1920, 1080))


if __name__ == "__main__":
    main()
