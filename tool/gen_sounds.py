"""효과음/배경음악 합성 스크립트.

외부 음원 없이 numpy로 칩튠 스타일 사운드를 만든다 (저작권 걱정 없음).
실행: python3 tool/gen_sounds.py  ->  assets/audio/*.wav
"""
import os
import wave

import numpy as np

SR = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")


def save(name, x, vol=0.8):
    x = np.clip(x * vol, -1, 1)
    data = (x * 32767).astype(np.int16)
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())


def t(sec):
    return np.linspace(0, sec, int(SR * sec), endpoint=False)


def env(n, attack=0.005, release=None):
    e = np.ones(n)
    a = max(1, int(SR * attack))
    e[:a] = np.linspace(0, 1, a)
    r = n - a if release is None else int(SR * release)
    e[-r:] *= np.linspace(1, 0, r) ** 2
    return e


def sweep(f0, f1, sec, shape="square"):
    tt = t(sec)
    f = np.linspace(f0, f1, len(tt))
    ph = 2 * np.pi * np.cumsum(f) / SR
    if shape == "square":
        return np.sign(np.sin(ph))
    if shape == "saw":
        return 2 * ((ph / (2 * np.pi)) % 1) - 1
    return np.sin(ph)


def noise(sec, seed=0):
    return np.random.default_rng(seed).uniform(-1, 1, int(SR * sec))


def lowpass(x, k=8):
    return np.convolve(x, np.ones(k) / k, mode="same")


def main():
    os.makedirs(OUT, exist_ok=True)

    s = sweep(1400, 300, 0.12) * env(int(SR * 0.12))
    save("shoot", s, 0.25)

    s = lowpass(noise(0.08, 1), 3) * env(int(SR * 0.08))
    save("hit", s, 0.35)

    n = noise(0.5, 2)
    s = lowpass(n, 12) * env(int(SR * 0.5)) + sweep(200, 40, 0.5, "sine") * env(int(SR * 0.5)) * 0.6
    save("explode", s, 0.6)

    n = noise(1.2, 3)
    s = lowpass(n, 20) * env(int(SR * 1.2)) + sweep(150, 25, 1.2, "sine") * env(int(SR * 1.2))
    save("big_explode", s, 0.8)

    s = np.concatenate([sweep(900, 900, 0.05, "square"), sweep(1350, 1350, 0.08, "square")])
    save("pickup", s * env(len(s)), 0.2)

    s = np.concatenate([sweep(1975, 1975, 0.06, "square"), sweep(2637, 2637, 0.14, "square")])
    save("coin", s * env(len(s)), 0.18)

    notes = [1047, 1319, 1568, 2093]
    s = np.concatenate([sweep(f, f, 0.07, "sine") for f in notes])
    save("gem", s * env(len(s), release=0.15), 0.5)

    notes = [523, 659, 784, 1047, 1319]
    s = np.concatenate([sweep(f, f, 0.06, "square") * 0.5 + sweep(f * 2, f * 2, 0.06, "sine") * 0.5 for f in notes])
    save("upgrade", s * env(len(s), release=0.12), 0.35)

    s = np.concatenate([sweep(880, 660, 0.25, "square"), sweep(880, 660, 0.25, "square")])
    save("alarm", s * env(len(s)), 0.22)

    tt = t(1.2)
    s = sweep(100, 1800, 1.2, "sine") * (0.6 + 0.4 * np.sin(2 * np.pi * 18 * tt))
    s += lowpass(noise(1.2, 4), 6) * np.linspace(0, 0.5, len(tt))
    save("warp", s * env(len(s), attack=0.2, release=0.4), 0.5)

    s = sweep(300, 900, 0.35, "saw") * 0.5 + lowpass(noise(0.35, 5), 4) * 0.5
    save("missile", s * env(len(s)), 0.35)

    tt = t(0.5)
    s = sweep(400, 1200, 0.5, "sine") * (0.5 + 0.5 * np.sin(2 * np.pi * 30 * tt))
    save("shield", s * env(len(s), release=0.2), 0.45)

    s = lowpass(noise(0.3, 6), 2) * np.linspace(1, 0, int(SR * 0.3)) + sweep(200, 600, 0.3, "sine") * 0.5
    save("boost", s * env(len(s)), 0.4)

    s = sweep(300, 120, 0.18, "square") * env(int(SR * 0.18))
    save("hurt", s, 0.3)

    save("bgm", make_bgm(), 0.5)
    make_music()


def note_freq(n):
    return 440.0 * 2 ** ((n - 69) / 12)


def make_bgm():
    """신나는 우주 모험 느낌의 8마디 반복 칩튠 (BPM 120)."""
    bpm = 120
    beat = 60 / bpm
    step = beat / 2  # 8분음표
    # 코드 진행: Am - F - C - G (2마디씩)
    chords = [(57, 60, 64), (53, 57, 60), (48, 52, 55), (55, 59, 62)]
    melody = [
        76, 0, 74, 72, 74, 0, 69, 0, 72, 74, 76, 0, 79, 76, 74, 0,
        72, 0, 69, 72, 74, 0, 72, 0, 69, 0, 67, 69, 72, 0, 0, 0,
        76, 0, 79, 81, 79, 0, 76, 0, 74, 76, 72, 0, 74, 72, 69, 0,
        71, 0, 74, 0, 79, 0, 78, 79, 81, 0, 79, 0, 74, 0, 0, 0,
    ]
    total_steps = len(melody)
    n_step = int(SR * step)
    out = np.zeros(total_steps * n_step)
    rng = np.random.default_rng(9)
    for i in range(total_steps):
        seg = slice(i * n_step, (i + 1) * n_step)
        tt = np.arange(n_step) / SR
        chord = chords[(i // 16) % 4]
        # 베이스 (옥타브 점프)
        bn = chord[0] - 12 + (12 if i % 2 else 0)
        bass = np.sign(np.sin(2 * np.pi * note_freq(bn) * tt)) * 0.18
        bass *= np.linspace(1, 0.3, n_step)
        # 아르페지오
        an = chord[i % 3] + 12
        arp = np.sign(np.sin(2 * np.pi * note_freq(an) * tt)) * 0.06 * np.linspace(1, 0.2, n_step)
        # 멜로디
        mel = np.zeros(n_step)
        if melody[i]:
            f = note_freq(melody[i])
            vib = 1 + 0.004 * np.sin(2 * np.pi * 6 * tt)
            mel = (0.6 * np.sign(np.sin(2 * np.pi * f * vib * tt)) + 0.4 * np.sin(2 * np.pi * f * tt)) * 0.14
            mel *= np.minimum(1, np.linspace(1.3, 0.2, n_step))
        # 드럼
        drum = np.zeros(n_step)
        if i % 4 == 0:  # 킥
            drum += np.sin(2 * np.pi * np.cumsum(np.linspace(150, 40, n_step)) / SR) * np.linspace(1, 0, n_step) ** 3 * 0.5
        if i % 4 == 2:  # 스네어
            drum += rng.uniform(-1, 1, n_step) * np.linspace(1, 0, n_step) ** 4 * 0.22
        drum += rng.uniform(-1, 1, n_step) * np.exp(-tt * 120) * 0.05  # 하이햇
        out[seg] = bass + arp + mel + drum
    # 두 바퀴 = 약 16초
    return np.concatenate([out, out])


# ---------- 배경음악 여러 곡 ----------
# 곡마다 박자·조성·코드·음색이 다르다. 멜로디는 코드 음을 따라 시드로 만들고 A A' B A 형식으로 짠다.
# wav로 만든 뒤 ffmpeg로 AAC(.m4a)로 줄여 assets/audio/music/ 에 둔다 (안드로이드·iOS 모두 재생).

MAJOR = [0, 2, 4, 5, 7, 9, 11]
MINOR = [0, 2, 3, 5, 7, 8, 10]

TRACKS = [
    # 이름, BPM, 으뜸음(MIDI), 음계, 코드(음계 도수 0~6), 멜로디 음색, 베이스 방식, 시드
    dict(name="drift", bpm=92, root=62, scale=MAJOR, prog=[0, 5, 3, 4], lead="sine", bass="long", drums="soft", seed=11),
    dict(name="frontier", bpm=132, root=64, scale=MINOR, prog=[0, 5, 2, 6], lead="square", bass="drive", drums="full", seed=23),
    dict(name="nebula", bpm=108, root=65, scale=MAJOR, prog=[3, 4, 2, 5], lead="bell", bass="walk", drums="light", seed=37),
    dict(name="pursuit", bpm=144, root=60, scale=MINOR, prog=[0, 3, 4, 0], lead="saw", bass="drive", drums="full", seed=41),
    # 보스전: 빠르고 낮은 단조, 감화음(ii°)으로 긴장감. 보스가 있는 동안 반복한다
    dict(name="boss", bpm=156, root=57, scale=MINOR, prog=[0, 0, 5, 1], lead="saw", bass="drive", drums="full", seed=53),
]


def _deg(tr, d, octave=0):
    sc = tr["scale"]
    return tr["root"] + sc[d % 7] + 12 * (d // 7 + octave)


def _chord(tr, deg):
    return [_deg(tr, deg), _deg(tr, deg + 2), _deg(tr, deg + 4)]


def _tone(kind, f, tt):
    ph = 2 * np.pi * f * tt
    if kind == "square":
        return 0.6 * np.sign(np.sin(ph)) + 0.4 * np.sin(ph)
    if kind == "saw":
        return 2 * ((f * tt) % 1) - 1
    if kind == "bell":
        return np.sin(ph) * 0.7 + np.sin(ph * 2.01) * 0.3 * np.exp(-tt * 6)
    return np.sin(ph) * 0.8 + np.sin(ph * 2) * 0.2


def _phrase(tr, rng, bars):
    """한 소절에 8분음표 8칸. 강박에는 코드 음, 나머지는 음계를 한 칸씩 움직인다."""
    rhythms = [
        [1, 0, 1, 1, 1, 0, 1, 0], [1, 0, 0, 1, 1, 0, 1, 1], [1, 1, 1, 0, 1, 0, 0, 0],
        [1, 0, 1, 0, 1, 1, 1, 0], [1, 0, 0, 0, 1, 0, 1, 0],
    ]
    notes = []
    cur = 7 + tr["prog"][0]  # 한 옥타브 위 으뜸 근처에서 시작
    for b in range(bars):
        deg = tr["prog"][b % len(tr["prog"])]
        tones = [deg + 7, deg + 9, deg + 11]
        rh = rhythms[rng.integers(len(rhythms))]
        for i in range(8):
            if not rh[i]:
                notes.append(None)
                continue
            if i % 4 == 0:
                cur = min(tones, key=lambda x: abs(x - cur))
            else:
                cur += int(rng.choice([-1, 1, 1, -2, 2]))
                cur = max(5, min(cur, 15))
            notes.append(cur)
        if b % 4 == 3:  # 4소절 끝은 길게 쉰다
            notes[-3:] = [notes[-3], None, None]
    return notes


def make_track(tr):
    rng = np.random.default_rng(tr["seed"])
    step = 60 / tr["bpm"] / 2
    n = int(SR * step)
    tt = np.arange(n) / SR
    a = _phrase(tr, rng, 8)
    a2 = a[:-16] + _phrase(tr, rng, 2)
    b = _phrase(tr, rng, 8)
    melody = a + a2 + b + a
    bars = len(melody) // 8
    out = np.zeros(len(melody) * n)
    drng = np.random.default_rng(tr["seed"] + 1)
    for i, m in enumerate(melody):
        bar = i // 8
        in_b = 16 <= bar < 24
        deg = tr["prog"][bar % len(tr["prog"])]
        chord = _chord(tr, deg)
        x = np.zeros(n)
        # 베이스
        if tr["bass"] == "long":
            if i % 4 == 0:
                x += np.sin(2 * np.pi * note_freq(chord[0] - 24) * tt) * 0.22
            x += np.sin(2 * np.pi * note_freq(chord[0] - 24) * tt) * 0.12
        elif tr["bass"] == "walk":
            bn = [chord[0], chord[2], chord[1], chord[2]][(i // 2) % 4] - 24
            x += np.sign(np.sin(2 * np.pi * note_freq(bn) * tt)) * 0.12 * np.linspace(1, 0.4, n)
        else:  # drive: 8분 옥타브
            bn = chord[0] - 24 + (12 if i % 2 else 0)
            x += np.sign(np.sin(2 * np.pi * note_freq(bn) * tt)) * 0.16 * np.linspace(1, 0.3, n)
        # 화음 (잔잔한 곡은 패드, 나머지는 아르페지오)
        if tr["drums"] == "soft":
            for c in chord:
                x += np.sin(2 * np.pi * note_freq(c) * tt) * 0.035
        else:
            an = chord[i % 3] + 12
            x += np.sign(np.sin(2 * np.pi * note_freq(an) * tt)) * 0.05 * np.linspace(1, 0.2, n)
        # 멜로디 (B 구간은 한 옥타브 낮게 대비)
        if m is not None:
            f = note_freq(_deg(tr, m, -1 if in_b else 0))
            vib = 1 + 0.004 * np.sin(2 * np.pi * 5.5 * tt)
            decay = np.exp(-tt * (3 if tr["lead"] in ("sine", "bell") else 5))
            x += _tone(tr["lead"], f * vib, tt) * 0.13 * decay
        # 드럼
        d = tr["drums"]
        if d in ("full", "light") and i % 4 == 0:
            x += np.sin(2 * np.pi * np.cumsum(np.linspace(150, 40, n)) / SR) * np.linspace(1, 0, n) ** 3 * (0.45 if d == "full" else 0.3)
        if d == "full" and i % 4 == 2:
            x += drng.uniform(-1, 1, n) * np.linspace(1, 0, n) ** 4 * 0.2
        if d != "soft" or i % 2 == 0:
            x += drng.uniform(-1, 1, n) * np.exp(-tt * 120) * (0.04 if d != "soft" else 0.02)
        out[i * n:(i + 1) * n] = x
    # 끝을 짧게 페이드해 이어 붙일 때 딱 소리가 나지 않게
    fade = int(SR * 0.05)
    out[-fade:] *= np.linspace(1, 0, fade)
    return out, bars


def make_music():
    import subprocess
    import tempfile
    dst = os.path.join(OUT, "music")
    os.makedirs(dst, exist_ok=True)
    for tr in TRACKS:
        x, bars = make_track(tr)
        x = np.clip(x * 0.55, -1, 1)
        with tempfile.NamedTemporaryFile(suffix=".wav") as f:
            with wave.open(f.name, "wb") as w:
                w.setnchannels(1)
                w.setsampwidth(2)
                w.setframerate(SR)
                w.writeframes((x * 32767).astype(np.int16).tobytes())
            subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", f.name, "-c:a", "aac", "-b:a", "64k",
                            os.path.join(dst, tr["name"] + ".m4a")], check=True)
        print(tr["name"], f"{len(x) / SR:.0f}s", bars, "bars")


if __name__ == "__main__":
    main()
