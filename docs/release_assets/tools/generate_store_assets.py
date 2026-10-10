#!/usr/bin/env python3
"""Star Settlers store assets generator.

captures/{phone,tablet}/*.png  ->  intermediate/trimmed/*  ->  screenshot/html/*  ->  final/locales/<locale>/...

Usage:  python3 docs/release_assets/tools/generate_store_assets.py [--locale ko-KR]
Renders HTML with headless Google Chrome (no Playwright), then normalises to RGB PNG and
asserts exact pixel sizes:
  phone  App Store 6.9"  1320x2868   ->  final/locales/<loc>/phone/NN.png
  phone  Google Play     1440x2880   ->  final/locales/<loc>/phone/NN-google.png (Play: long side <= 2x short side)
  tablet App Store 13"   2752x2064   ->  final/locales/<loc>/tablet/NN.png (also valid for Play tablets)
  feature graphic        1024x500    ->  final/locales/<loc>/common/feature_graphic_1024x500.png
"""
import argparse, json, random, subprocess, sys, tempfile, time
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]          # docs/release_assets
APP = ROOT.parents[1]                                # project root
SPRITES = APP / "assets" / "sprites"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# status/navigation bar trim (px) for 1320x2868 Android captures (STORE_ASSET_GUIDE §1 + measured status bar)
# tablet: iPad 상태바(약 50px) / 하단 오른쪽 창 크기 조절 표시(약 60px)
TRIM = {"phone": (150, 41), "tablet": (52, 70)}
# HTML lang (글꼴 모양: 한자 언어별 자형). main에서 locale로 맞춘다
LANG = "ko"

SIZES = {"apple_phone": (1320, 2868), "google_phone": (1440, 2880), "tablet": (2752, 2064), "tablet_portrait": (2064, 2752)}


def stars(w, h, seed, n):
    r = random.Random(seed)
    out = []
    for _ in range(n):
        s = r.choice([2, 2, 3, 3, 4, 6])
        out.append(f'<i style="left:{r.random()*w:.0f}px;top:{r.random()*h:.0f}px;width:{s}px;height:{s}px;'
                   f'opacity:{r.uniform(.25, .9):.2f}"></i>')
    return "".join(out)


def trim(src: Path, kind: str) -> Path:
    top, bottom = TRIM[kind]
    im = Image.open(src).convert("RGB")
    # 언어별 캡처(captures/<kind>/<locale>/NN.png)는 언어 폴더를 유지해 덮어쓰지 않는다
    sub = src.parent.name if src.parent.name != kind else ""
    out = ROOT / "intermediate" / "trimmed" / kind / sub / src.name
    out.parent.mkdir(parents=True, exist_ok=True)
    im.crop((0, top, im.width, im.height - bottom)).save(out)
    return out


def render(html: str, w: int, h: int, out: Path, html_path: Path):
    html_path.parent.mkdir(parents=True, exist_ok=True)
    html_path.write_text(html, encoding="utf-8")
    with tempfile.TemporaryDirectory() as prof:
        tmp = Path(prof) / "shot.png"
        # headless Chrome sometimes keeps running after writing the screenshot: poll, then terminate
        proc = subprocess.Popen([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", f"--user-data-dir={prof}",
                                 "--force-device-scale-factor=1", f"--window-size={w},{h}", "--allow-file-access-from-files",
                                 f"--screenshot={tmp}", html_path.as_uri()],
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        last = -1
        for _ in range(240):
            time.sleep(0.5)
            if tmp.exists() and tmp.stat().st_size == last and last > 0:
                break
            last = tmp.stat().st_size if tmp.exists() else -1
        proc.terminate()
        try:
            proc.wait(5)
        except subprocess.TimeoutExpired:
            proc.kill()
        im = Image.open(tmp).convert("RGB")
    assert im.size == (w, h), f"{out}: {im.size} != {(w, h)}"
    out.parent.mkdir(parents=True, exist_ok=True)
    im.save(out, optimize=True)
    print(f"  {out.relative_to(ROOT)}  {im.size[0]}x{im.size[1]}")


def sheet(slot, idx, total, brand, cap: Path, w, h, land=False, tablet=False):
    cw, ch = Image.open(cap).size
    css = (ROOT / "templates" / "marketing.css").as_uri()
    mascot = (SPRITES / slot["mascot"]).as_uri()
    logo = (SPRITES / "logo.png").as_uri()
    cls = f'sheet {slot["theme"]}{" land" if land else ""}{" tab" if tablet else ""}'
    return f"""<!doctype html><html lang="{LANG}"><meta charset="utf-8"><link rel="stylesheet" href="{css}">
<body><div class="{cls}" style="--w:{w};--h:{h};--cap-ar:{cw}/{ch}">
<div class="stars">{stars(w, h, idx * 7 + 1, int(w * h / 9000))}</div>
<header><div class="brand"><img src="{logo}" alt="">{brand}</div>
<h1>{slot["title"]}</h1><p class="sub">{slot["sub"]}</p></header>
<div class="stage"><div class="device"><img src="{cap.as_uri()}" alt=""></div></div>
<img class="mascot {slot['mascot_pos']}" src="{mascot}" alt="">
<footer><span>{slot["detail"]}</span><span class="page">{idx:02d} / {total:02d}</span></footer>
</div></body></html>"""


def feature_graphic(copy: dict, loc: str):
    art = (ROOT / "feature_graphic" / "art" / "fg_art.png").as_uri()
    logo = (SPRITES / "logo.png").as_uri()
    font = (APP / "assets" / "fonts" / "Jua-Regular.ttf").as_uri()
    TITLE_FONT, TITLE_WEIGHT = {"ko": ("Jua,sans-serif", 400), "ja": ('"Hiragino Maru Gothic ProN",sans-serif', 800),
                                "zh-Hans": ('"Yuanti SC","PingFang SC",sans-serif', 800)}.get(LANG, ("ui-rounded,system-ui,sans-serif", 800))
    html = f"""<!doctype html><html lang="{LANG}"><meta charset="utf-8"><style>
@font-face{{font-family:Jua;src:url("{font}")}}
html,body{{margin:0}}.fg{{width:1024px;height:500px;position:relative;overflow:hidden;background:#0d0a2a}}
.fg>img.art{{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;object-position:{copy.get("art_position", "60% 50%")}}}
.shade{{position:absolute;inset:0;background:linear-gradient(90deg,#0b0826f2 0%,#0b0826c8 30%,#0b082600 52%)}}
.txt{{position:absolute;left:40px;top:0;bottom:0;width:430px;display:flex;flex-direction:column;justify-content:center}}
.txt img{{width:355px;filter:drop-shadow(0 6px 14px #000a)}}
.tag{{margin-top:14px;font-family:{TITLE_FONT};font-weight:{TITLE_WEIGHT};font-size:38px;color:#fff;line-height:1.25;text-shadow:0 3px 10px #000c;word-break:keep-all}}
.tag em{{font-style:normal;color:#ffd54a}}
.sub{{margin-top:10px;font-family:"Apple SD Gothic Neo",sans-serif;font-weight:600;font-size:20px;color:#d4ccff;text-shadow:0 2px 8px #000c}}
</style><body><div class="fg"><img class="art" src="{art}"><div class="shade"></div>
<div class="txt"><img src="{logo}"><div class="tag">{copy["tagline"]}</div><div class="sub">{copy["sub"]}</div></div></div></body></html>"""
    render(html, 1024, 500, ROOT / "final" / "locales" / loc / "common" / "feature_graphic_1024x500.png",
           ROOT / "feature_graphic" / "html" / f"{loc}.html")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--locale", default="ko-KR")
    loc = ap.parse_args().locale
    global LANG
    LANG = {"zh-CN": "zh-Hans"}.get(loc, loc.split("-")[0])
    fin = ROOT / "final" / "locales" / loc
    for kind in ("phone", "tablet"):
        copy_file = ROOT / "screenshot" / "copy" / f"{loc}.{kind}.json"
        if not copy_file.exists():
            # 태블릿 전용 문구가 없으면 폰 문구를 그대로 쓴다
            copy_file = ROOT / "screenshot" / "copy" / f"{loc}.json"
        if not copy_file or not copy_file.exists():
            print(f"skip {kind}: no copy file"); continue
        copy = json.loads(copy_file.read_text(encoding="utf-8"))
        def capture_of(s):
            # 언어별 캡처가 있으면 우선 (cozy_pet과 같이 앱 화면도 그 언어로), 없으면 공용 캡처
            own = ROOT / "captures" / kind / loc / s["capture"]
            # 공용(언어 폴더 밖) 캡처는 한국어 화면이라 ko-KR에만 쓴다
            return own if (own.exists() or loc != "ko-KR") else ROOT / "captures" / kind / s["capture"]

        slots = [s for s in copy["slots"] if capture_of(s).exists()]
        print(f"{kind}: {len(slots)} slots")
        for i, s in enumerate(slots, 1):
            cap = trim(capture_of(s), kind)
            name = f'{i:02d}_{s["file"].split("_", 1)[1]}'
            if kind == "phone":
                for key, suffix in (("apple_phone", ""), ("google_phone", "-google")):
                    w, h = SIZES[key]
                    render(sheet(s, i, len(slots), copy["brand"], cap, w, h), w, h,
                           fin / "phone" / f"{name}{suffix}.png", ROOT / "screenshot" / "html" / loc / f"{name}{suffix}.html")
            else:
                # 세로 캡처(iPad 2064x2752)면 세로 13" 규격, 가로면 가로 규격
                cw, ch = Image.open(cap).size
                portrait = ch > cw
                w, h = SIZES["tablet_portrait" if portrait else "tablet"]
                render(sheet(s, i, len(slots), copy["brand"], cap, w, h, land=not portrait, tablet=portrait), w, h,
                       fin / "tablet" / f"{name}.png", ROOT / "screenshot" / "html" / loc / f"tablet_{name}.html")
    fg = ROOT / "feature_graphic" / "copy" / f"{loc}.json"
    if fg.exists():
        feature_graphic(json.loads(fg.read_text(encoding="utf-8")), loc)


if __name__ == "__main__":
    sys.exit(main())
