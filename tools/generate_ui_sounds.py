#!/usr/bin/env python3
"""Generate short UI WAV assets for GodBomb."""

import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44100
OUT_DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "ui"


def write_wav(path, samples):
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for sample in samples:
            clamped = max(-1.0, min(1.0, sample))
            frames.extend(struct.pack("<h", int(clamped * 32767)))
        wav_file.writeframes(frames)


def sine(freq, t):
    return math.sin(2.0 * math.pi * freq * t)


def env_decay(t, duration, attack=0.004, release=0.035):
    if t < 0.0 or t > duration:
        return 0.0
    if t < attack:
        return t / attack
    return math.exp(-(t - attack) / max(release, 0.001))


def render(duration, fn):
    count = int(SAMPLE_RATE * duration)
    return [fn(i / SAMPLE_RATE) for i in range(count)]


def click_pop():
    def sample(t):
        e = env_decay(t, 0.055, release=0.028)
        body = sine(920.0, t) * 0.55 + sine(540.0, t) * 0.25
        return body * e * 0.42

    return render(0.055, sample)


def confirm_pop():
    def sample(t):
        e = env_decay(t, 0.09, release=0.04)
        freq = 620.0 + 420.0 * min(1.0, t / 0.045)
        return sine(freq, t) * e * 0.45

    return render(0.09, sample)


def toggle_pop():
    def sample(t):
        e = env_decay(t, 0.05, release=0.03)
        return sine(760.0, t) * e * 0.34

    return render(0.05, sample)


def slider_tick():
    def sample(t):
        e = env_decay(t, 0.028, attack=0.001, release=0.016)
        return sine(1380.0, t) * e * 0.22

    return render(0.028, sample)


def modal_open():
    def sample(t):
        e = env_decay(t, 0.12, attack=0.008, release=0.05)
        freq = 420.0 + 680.0 * (t / 0.12)
        return sine(freq, t) * e * 0.28

    return render(0.12, sample)


def modal_close():
    def sample(t):
        e = env_decay(t, 0.1, attack=0.004, release=0.045)
        freq = 980.0 - 520.0 * (t / 0.1)
        return sine(freq, t) * e * 0.26

    return render(0.1, sample)


def lobby_add():
    notes = [523.25, 659.25, 783.99]

    def sample(t):
        value = 0.0
        for index, freq in enumerate(notes):
            start = index * 0.045
            local_t = t - start
            if local_t < 0.0 or local_t > 0.08:
                continue
            e = env_decay(local_t, 0.08, release=0.035)
            value += sine(freq, local_t) * e
        return value * 0.24

    return render(0.22, sample)


def lobby_remove():
    def sample(t):
        e = env_decay(t, 0.14, attack=0.003, release=0.055)
        freq = 760.0 - 360.0 * (t / 0.14)
        tone = sine(freq, t) * 0.55 + sine(freq * 0.5, t) * 0.2
        return tone * e * 0.36

    return render(0.14, sample)


def lobby_swap():
    def sample(t):
        e = env_decay(t, 0.16, attack=0.006, release=0.06)
        sweep = 520.0 + 820.0 * math.sin(math.pi * t / 0.16)
        wobble = sine(sweep, t) * 0.65 + sine(sweep * 1.5, t) * 0.18
        pan = math.sin(math.pi * t / 0.16)
        return wobble * e * 0.34 * (0.82 + 0.18 * pan)

    return render(0.16, sample)


def main():
    sounds = {
        "ui_click.wav": click_pop(),
        "ui_confirm.wav": confirm_pop(),
        "ui_toggle.wav": toggle_pop(),
        "ui_slider_tick.wav": slider_tick(),
        "ui_modal_open.wav": modal_open(),
        "ui_modal_close.wav": modal_close(),
        "lobby_player_add.wav": lobby_add(),
        "lobby_player_remove.wav": lobby_remove(),
        "lobby_player_swap.wav": lobby_swap(),
    }
    for filename, samples in sounds.items():
        path = OUT_DIR / filename
        write_wav(path, samples)
        print(f"Wrote {path}")


if __name__ == "__main__":
    main()
