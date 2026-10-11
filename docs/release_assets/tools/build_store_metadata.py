#!/usr/bin/env python3
"""docs/release_info/l10n/<locale>.json -> Fastlane 등록정보 txt + 스토어 이미지 복사 + 길이/크기 검증.

    python3 docs/release_assets/tools/build_store_metadata.py           # 생성 + 검증
    python3 docs/release_assets/tools/build_store_metadata.py --check   # 검증만 (파일을 쓰지 않음)

Google Play: android/fastlane/metadata/android/<play>/
  title.txt(≤30) short_description.txt(≤80) full_description.txt(≤4000)
  images/phoneScreenshots/NN_*.png   <- final/locales/<loc>/phone/NN_*-google.png (1440x2880)
  images/tenInchScreenshots/NN_*.png <- final/locales/<loc>/tablet/NN_*.png (2064x2752)
  images/featureGraphic.png          <- final/locales/<loc>/common/feature_graphic_1024x500.png
  images/icon.png                    <- docs/release_assets/app_icon/play_icon_512.png
App Store: ios/fastlane/metadata/<asc>/
  name(≤30) subtitle(≤30) keywords(≤100 bytes) promotional_text(≤170) description(≤4000)
  privacy_url / support_url / marketing_url
  ios/fastlane/screenshots/<asc>/NN_*.png (1320x2868) + ipad_NN_*.png (2064x2752)
"""
import json
import pathlib
import re
import shutil
import sys

from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parents[3]
L10N = ROOT / "docs/release_info/l10n"
FINAL = ROOT / "docs/release_assets/final/locales"
ICON = ROOT / "docs/release_assets/app_icon/play_icon_512.png"
PLAY = ROOT / "android/fastlane/metadata/android"
ASC = ROOT / "ios/fastlane/metadata"
ASC_SHOTS = ROOT / "ios/fastlane/screenshots"

# 우리 로케일 -> (Google Play 코드, App Store Connect 코드)
LOCALES = {
    "ko-KR": ("ko-KR", "ko"),
    "en-US": ("en-US", "en-US"),
    "ja-JP": ("ja-JP", "ja"),
    "zh-CN": ("zh-CN", "zh-Hans"),
    "es-ES": ("es-ES", "es-ES"),
    "fr-FR": ("fr-FR", "fr-FR"),
    "de-DE": ("de-DE", "de-DE"),
    "pt-BR": ("pt-BR", "pt-BR"),
    "ru-RU": ("ru-RU", "ru"),
    "id-ID": ("id", "id"),
}

PRIVACY_URL = "https://rumururu.github.io/mkideabox/star_settlers/privacy.html"
SUPPORT_URL = "https://mkideabox.com"
MARKETING_URL = "https://mkideabox.com"

ROOT_FILES = {
    "copyright.txt": "2026 mkideabox Co. Ltd.",
    "primary_category.txt": "GAMES",
    "primary_first_sub_category.txt": "GAMES_CASUAL",
    "primary_second_sub_category.txt": "GAMES_ACTION",
    "review_information/notes.txt": (
        "No account or login is required. All features are available from the first launch.\n"
        "The app shows optional rewarded ads (Google AdMob) only when the user taps a \"watch ad\" button. "
        "Ads are configured as child-directed and non-personalized for all users.\n"
        "In-app purchases (gems, Starter Pack, Fleet Commander Pass) are optional; the whole game can be played without paying. "
        "Restore Purchases is in the Shop.\n"
        "The UI supports 10 languages and follows the device language (it can also be changed in Settings)."
    ),
}

CHAR_LIMITS = {"title": 30, "name": 30, "subtitle": 30, "short": 80, "full": 4000, "promo": 170}
PHONE_IOS = (1320, 2868)
PHONE_PLAY = (1440, 2880)
TABLET = (2064, 2752)
FEATURE = (1024, 500)


def validate(loc: str, d: dict) -> list[str]:
    errs = []
    for key, lim in CHAR_LIMITS.items():
        if len(d[key]) > lim:
            errs.append(f"{key} {len(d[key])}>{lim}")
    kw = d["keywords"]
    if len(kw.encode("utf-8")) > 100:
        errs.append(f"keywords {len(kw.encode('utf-8'))}B>100B")
    if re.search(r",\s", kw) or kw != kw.strip():
        errs.append("keywords: space after comma")
    title_words = {w.lower() for w in re.findall(r"\w+", d["name"])}
    dup = [w for w in kw.split(",") if any(p.lower() in title_words for p in w.split())]
    if dup:
        errs.append(f"keywords repeat name words: {dup}")
    return errs


def check_image(path: pathlib.Path, size: tuple[int, int]) -> list[str]:
    im = Image.open(path)
    errs = []
    if im.size != size:
        errs.append(f"{path.name} {im.size} != {size}")
    if im.mode not in ("RGB",):
        errs.append(f"{path.name} mode {im.mode} (alpha not allowed)")
    return errs


def write(path: pathlib.Path, text: str, dry: bool) -> None:
    if dry:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.rstrip("\n") + "\n", encoding="utf-8")


def copy(src: pathlib.Path, dst: pathlib.Path, size, dry: bool, errs: list[str]) -> None:
    errs += check_image(src, size)
    if not dry:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, dst)


def main() -> int:
    dry = "--check" in sys.argv
    problems = 0
    errs: list[str] = check_image(ICON, (512, 512))
    for rel, text in ROOT_FILES.items():
        write(ASC / rel, text, dry)
    for loc, (play, asc) in LOCALES.items():
        d = json.loads((L10N / f"{loc}.json").read_text(encoding="utf-8"))
        loc_errs = validate(loc, d)

        pdir = PLAY / play
        write(pdir / "title.txt", d["title"], dry)
        write(pdir / "short_description.txt", d["short"], dry)
        write(pdir / "full_description.txt", d["full"], dry)
        img = pdir / "images"
        if not dry:
            for sub in ("phoneScreenshots", "tenInchScreenshots"):
                shutil.rmtree(img / sub, ignore_errors=True)
        for src in sorted((FINAL / loc / "phone").glob("*-google.png")):
            copy(src, img / "phoneScreenshots" / src.name.replace("-google", ""), PHONE_PLAY, dry, loc_errs)
        for src in sorted((FINAL / loc / "tablet").glob("*.png")):
            copy(src, img / "tenInchScreenshots" / src.name, TABLET, dry, loc_errs)
        copy(FINAL / loc / "common/feature_graphic_1024x500.png", img / "featureGraphic.png", FEATURE, dry, loc_errs)
        copy(ICON, img / "icon.png", (512, 512), dry, loc_errs)

        adir = ASC / asc
        write(adir / "name.txt", d["name"], dry)
        write(adir / "subtitle.txt", d["subtitle"], dry)
        write(adir / "keywords.txt", d["keywords"], dry)
        write(adir / "promotional_text.txt", d["promo"], dry)
        write(adir / "description.txt", d["full"], dry)
        write(adir / "privacy_url.txt", PRIVACY_URL, dry)
        write(adir / "support_url.txt", SUPPORT_URL, dry)
        write(adir / "marketing_url.txt", MARKETING_URL, dry)
        sdir = ASC_SHOTS / asc
        if not dry:
            shutil.rmtree(sdir, ignore_errors=True)
        phones = sorted(p for p in (FINAL / loc / "phone").glob("*.png") if not p.stem.endswith("-google"))
        for src in phones:
            copy(src, sdir / src.name, PHONE_IOS, dry, loc_errs)
        tablets = sorted((FINAL / loc / "tablet").glob("*.png"))
        for src in tablets:
            copy(src, sdir / f"ipad_{src.name}", TABLET, dry, loc_errs)
        if len(phones) > 10 or len(tablets) > 10:
            loc_errs.append("App Store allows at most 10 screenshots per device")

        kb = len(d["keywords"].encode("utf-8"))
        print(
            f"{loc:6} play={play:6} asc={asc:8} title={len(d['title'])} subtitle={len(d['subtitle'])} "
            f"short={len(d['short'])} full={len(d['full'])} promo={len(d['promo'])} kw={kb}B "
            f"phone={len(phones)} tablet={len(tablets)} " + ("OK" if not loc_errs else "FAIL " + "; ".join(loc_errs))
        )
        problems += len(loc_errs)
    if errs:
        print("FAIL", "; ".join(errs))
    return 1 if problems or errs else 0


if __name__ == "__main__":
    sys.exit(main())
