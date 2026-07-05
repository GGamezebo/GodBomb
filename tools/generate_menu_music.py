#!/usr/bin/env python
"""Generate original loopable menu music for GodBomb (stdlib only)."""

import math
import os
import struct
import subprocess
import sys
import wave

SAMPLE_RATE = 44100
LOOP_SEC = 120.0
BPM = 96.0
BEAT = 60.0 / BPM
BAR = 4.0 * BEAT
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "assets", "audio", "music")
OUT_WAV = os.path.join(OUT_DIR, "background.wav")
OUT_MP3 = os.path.join(OUT_DIR, "background.mp3")

NOTE_HZ = {
    "A2": 110.0,
    "B2": 123.47,
    "C3": 130.81,
    "D3": 146.83,
    "E3": 164.81,
    "F3": 174.61,
    "G3": 196.0,
    "A3": 220.0,
    "B3": 246.94,
    "C4": 261.63,
    "D4": 293.66,
    "E4": 329.63,
    "F4": 349.23,
    "G4": 392.0,
    "A4": 440.0,
    "B4": 493.88,
    "C5": 523.25,
    "D5": 587.33,
    "E5": 659.25,
}

# 4 chords x 4 bars = 16 bars = 40s, repeats 3x in 120s.
CHORDS = (
    ("Am", ("A3", "C4", "E4", "A4")),
    ("F", ("F3", "A3", "C4", "F4")),
    ("C", ("C4", "E4", "G4", "C5")),
    ("G", ("G3", "B3", "D4", "G4")),
)
CHORD_BARS = 4

# Lead melody: (note_name, start_beat, duration_beats) within 48-bar form.
LEAD = (
    ("E4", 0, 1.5), ("G4", 1.5, 1.0), ("A4", 3, 2.0), ("C5", 5, 1.5),
    ("B4", 7, 1.0), ("A4", 8, 2.0), ("G4", 10, 1.0), ("E4", 11, 2.0),
    ("D4", 14, 1.5), ("E4", 16, 1.0), ("G4", 17, 2.0), ("A4", 19, 2.0),
    ("C5", 22, 1.5), ("D5", 24, 1.0), ("E5", 25, 2.5), ("D5", 28, 1.0),
    ("C5", 29, 2.0), ("A4", 31, 1.5), ("G4", 33, 2.0), ("E4", 36, 1.0),
    ("A4", 38, 3.0), ("G4", 42, 2.0), ("E4", 45, 3.0),
)

# Pluck arp per chord slot (16th-note indices 0..15, -1 = rest).
ARP = {
    "Am": (0, 2, 4, 7, 4, 2, 0, -1, 2, 4, 7, 9, 7, 4, 2, 0),
    "F":  (5, 8, 10, 13, 10, 8, 5, -1, 8, 10, 13, 15, 13, 10, 8, 5),
    "C":  (0, 3, 5, 7, 5, 3, 0, -1, 3, 5, 7, 10, 7, 5, 3, 0),
    "G":  (2, 5, 7, 10, 7, 5, 2, -1, 5, 7, 10, 12, 10, 7, 5, 2),
}


def loop_freq(hz):
    k = int(round(hz * LOOP_SEC))
    return float(k) / LOOP_SEC


def sine(freq, t, phase=0.0):
    return math.sin(2.0 * math.pi * freq * t + phase)


def tri(freq, t):
    p = (freq * t) % 1.0
    return 4.0 * abs(p - 0.5) - 1.0


def soft_clip(x):
    return math.tanh(x * 1.22)


def beat_index(t):
    return int(t / BEAT)


def bar_index(t):
    return int(t / BAR)


def chord_at(t):
    prog_bar = bar_index(t) % (len(CHORDS) * CHORD_BARS)
    return CHORDS[prog_bar / CHORD_BARS]


def chord_notes(t):
    return chord_at(t)[1]


def chord_root(t):
    return NOTE_HZ[chord_at(t)[1][0]]


def env_adsr(local, attack, decay, sustain, release, dur):
    if local < 0.0 or local > dur:
        return 0.0
    if local < attack:
        return local / attack
    if local < attack + decay:
        return 1.0 - (1.0 - sustain) * ((local - attack) / decay)
    if local < dur - release:
        return sustain
    return sustain * (1.0 - (local - (dur - release)) / release)


def pluck(freq, t, local, dur, bright=1.0):
    e = env_adsr(local, 0.004, 0.08, 0.15, min(0.12, dur * 0.35), dur)
    body = sine(freq, t) * 0.55 + tri(freq, t) * 0.25 * bright
    tick = sine(freq * 2.02, t) * math.exp(-local * 28.0) * 0.18
    return (body + tick) * e


def pad_voice(freq, t, gain):
    wobble = 1.0 + 0.008 * sine(loop_freq(0.25), t)
    return sine(freq * wobble, t) * gain


def drums(t):
    beat = beat_index(t)
    local = t - beat * BEAT
    bar = bar_index(t)
    beat_in_bar = beat % 4

    out = 0.0

    # Kick on 1 and 3 (+ occasional pickup).
    if beat_in_bar in (0, 2) and local < 0.11:
        f = loop_freq(52.0) * (1.0 - local * 5.5)
        env = (1.0 - local / 0.11) ** 2.2
        out += sine(max(f, loop_freq(42.0)), t) * env * 0.34

    # Snare/clap on 2 and 4.
    if beat_in_bar in (1, 3) and local < 0.07:
        env = (1.0 - local / 0.07) ** 1.8
        tone = sine(loop_freq(180.0), t) * 0.12
        noise = math.sin(t * 8231.4 + bar) * math.cos(t * 5920.7) * 0.22
        out += (tone + noise) * env

    # Hi-hats on 8ths with swing.
    eighth = BEAT * 0.5
    step = int(t / eighth)
    local8 = t - step * eighth
    if local8 < 0.028:
        swing = 0.92 if (step % 2) else 1.08
        if step % 4 != 3:
            env = (1.0 - local8 / 0.028) ** 2.5
            n = math.sin(t * 12007.0 * swing) * math.cos(t * 8011.0)
            accent = 1.0 if step % 2 == 0 else 0.62
            out += n * env * 0.045 * accent

    # Shaker on offbeats in chorus bars.
    if (bar % 16) >= 8 and beat_in_bar in (1, 3) and 0.04 < local < 0.09:
        n = math.sin(t * 15000.0) * math.cos(t * 11000.0)
        out += n * 0.018

    return out


def bass(t):
    beat = beat_index(t)
    beat_in_bar = beat % 4
    local = t - beat * BEAT
    root = loop_freq(chord_root(t))
    fifth = loop_freq(chord_root(t) * 1.5)

    if local >= BEAT * 0.95:
        return 0.0

    if beat_in_bar == 0:
        hz, amp = root, 0.30
    elif beat_in_bar == 1:
        hz, amp = fifth, 0.16
    elif beat_in_bar == 2:
        hz, amp = root, 0.24
    else:
        hz, amp = fifth, 0.14

    env = math.exp(-local * 6.8) * (1.0 - math.exp(-local * 100.0))
    return sine(hz, t) * env * amp + sine(hz * 2.0, t) * env * amp * 0.18


def pad(t):
    notes = chord_notes(t)
    bar = bar_index(t)
    swell = 0.55 + 0.45 * sine(loop_freq(0.0625), t)
    if (bar % 16) >= 8:
        swell *= 1.12
    out = 0.0
    for i, name in enumerate(notes):
        hz = NOTE_HZ[name]
        gain = (0.055 - i * 0.007) * swell
        out += pad_voice(loop_freq(hz), t, gain)
        out += pad_voice(loop_freq(hz * 0.999), t, gain * 0.35)
    return out


def arpeggio(t):
    bar = bar_index(t)
    prog_bar = bar % (len(CHORDS) * CHORD_BARS)
    chord_name = CHORDS[prog_bar / CHORD_BARS][0]
    notes = CHORDS[prog_bar / CHORD_BARS][1]
    sixteenth = BEAT * 0.25
    step = int((t % (CHORD_BARS * BAR)) / sixteenth) % 16
    idx = ARP[chord_name][step]
    if idx < 0:
        return 0.0
    note = notes[min(idx, len(notes) - 1)]
    local = t - int(t / sixteenth) * sixteenth
    freq = loop_freq(NOTE_HZ[note])
    vel = 0.13 if (bar % 16) < 8 else 0.16
    return pluck(freq, t, local, sixteenth * 0.95, bright=0.9) * vel


def lead(t):
    form_beat = beat_index(t) % 48
    out = 0.0
    for name, start, dur in LEAD:
        if form_beat < start or form_beat >= start + dur:
            continue
        local = t - (int(t / BEAT) - form_beat + start) * BEAT
        freq = loop_freq(NOTE_HZ[name])
        vibrato = 1.0 + 0.004 * sine(loop_freq(5.5), t)
        note = pluck(freq * vibrato, t, local, dur * BEAT, bright=1.15) * 0.22
        out += note
    return out


def render_dry():
    count = int(SAMPLE_RATE * LOOP_SEC)
    samples = []
    for i in range(count):
        t = float(i) / SAMPLE_RATE
        mix = (
            drums(t)
            + bass(t)
            + pad(t)
            + arpeggio(t)
            + lead(t)
        )
        samples.append(soft_clip(mix) * 0.9)
    return samples


def apply_delay(samples, delay_sec, feedback):
    delay = int(delay_sec * SAMPLE_RATE)
    out = list(samples)
    for i in range(delay, len(out)):
        out[i] += samples[i - delay] * feedback
    return out


def render():
    dry = render_dry()
    wet = apply_delay(dry, 0.5, 0.18)
    wet = apply_delay(wet, 0.25, 0.10)
    return [soft_clip(s) * 0.92 for s in wet]


def write_wav(path, samples):
    parent = os.path.dirname(path)
    if not os.path.isdir(parent):
        os.makedirs(parent)
    wav = wave.open(path, "w")
    try:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for s in samples:
            clamped = max(-1.0, min(1.0, s))
            frames.extend(struct.pack("<h", int(clamped * 32767)))
        wav.writeframes(frames)
    finally:
        wav.close()


def to_mp3(wav_path, mp3_path):
    cmd = [
        "ffmpeg", "-y", "-i", wav_path,
        "-ar", "44100", "-ac", "2", "-b:a", "160k",
        mp3_path,
    ]
    subprocess.check_call(cmd)


def main():
    samples = render()
    write_wav(OUT_WAV, samples)
    to_mp3(OUT_WAV, OUT_MP3)
    if os.path.exists(OUT_WAV):
        os.remove(OUT_WAV)
    print("Wrote %s (%.0fs loop @ %.0f BPM)" % (OUT_MP3, LOOP_SEC, BPM))
    return 0


if __name__ == "__main__":
    sys.exit(main())
