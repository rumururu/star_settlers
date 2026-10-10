"""스토어 이미지 검수 페이지: review/<locale>/index.html
usage: python3 docs/release_assets/tools/build_review.py [--locale ko-KR]"""
import argparse, html, json, os
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--locale", default="ko-KR")
    loc = ap.parse_args().locale
    out_dir = ROOT / "review" / loc
    out_dir.mkdir(parents=True, exist_ok=True)
    fin = ROOT / "final" / "locales" / loc
    copy = json.loads((ROOT / "screenshot" / "copy" / f"{loc}.json").read_text(encoding="utf-8"))

    def rel(p): return os.path.relpath(p, out_dir)

    def size(p): w, h = Image.open(p).size; return f"{w}×{h}"

    def cards(kind):
        out = []
        for i, s in enumerate(copy["slots"], 1):
            name = f'{i:02d}_{s["file"].split("_", 1)[1]}'
            main = fin / kind / f"{name}.png"
            title = s["title"].replace("<br>", " / ").replace("<em>", "").replace("</em>", "")
            if not main.exists():
                out.append(f'<figure class="card"><div class="ph"></div><figcaption><b>{i:02d} {html.escape(title)}</b>'
                           f'<span class="miss">캡처 없음</span></figcaption></figure>')
                continue
            extra = ""
            g = fin / kind / f"{name}-google.png"
            if g.exists():
                extra = f' · <a href="{rel(g)}" target="_blank">구글플레이용 {size(g)}</a>'
            out.append(f'''<figure class="card {kind}"><a href="{rel(main)}" target="_blank"><img src="{rel(main)}" loading="lazy"></a>
<figcaption><b>{i:02d} {html.escape(title)}</b><span>{html.escape(s.get("sub", ""))}</span>
<small>{html.escape(s.get("detail", ""))}</small><em>{size(main)}{extra}</em></figcaption></figure>''')
        return "".join(out)

    fg = fin / "common" / "feature_graphic_1024x500.png"
    page = f'''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Star Settlers 스토어 이미지 검수 ({loc})</title>
<style>
body{{margin:0;background:#0d0b26;color:#eee;font-family:-apple-system,"Apple SD Gothic Neo",sans-serif}}
header{{padding:20px 24px;border-bottom:1px solid #333}} h1{{margin:0 0 6px;font-size:22px}} p{{margin:4px 0;color:#aab}}
h2{{padding:0 24px;font-size:18px;color:#8ad8ff}}
.grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:18px;padding:0 24px 24px}}
.grid.tab{{grid-template-columns:repeat(auto-fill,minmax(300px,1fr))}}
.card{{margin:0;background:#151236;border:1px solid #333;border-radius:14px;padding:10px}}
.card img{{width:100%;border-radius:8px;display:block}} .ph{{aspect-ratio:1320/2868;background:#222;border-radius:8px}}
figcaption{{display:flex;flex-direction:column;gap:3px;margin-top:8px;font-size:13px}} figcaption span{{color:#ccd}} figcaption small{{color:#889}}
figcaption em{{color:#7cffb2;font-style:normal;font-size:12px}} a{{color:#8ad8ff}} .miss{{color:#ffd54f}}
.fg img{{max-width:min(1024px,calc(100% - 48px));border-radius:10px;display:block;margin:0 24px 24px}}
</style>
<header><h1>Star Settlers · 스토어 이미지 검수 — {loc}</h1>
<p>폰 (앱스토어 1320×2868 / 구글플레이 1440×2880) · 아이패드 13″ 세로 2064×2752 · 피처 그래픽 1024×500. 이미지를 누르면 원본 크기로 열려요.</p></header>
<h2>폰 스크린샷</h2><div class="grid">{cards("phone")}</div>
<h2>아이패드 13″</h2><div class="grid tab">{cards("tablet")}</div>
<h2>구글플레이 피처 그래픽</h2><div class="fg">{f'<img src="{rel(fg)}">' if fg.exists() else '<p>없음</p>'}</div>
'''
    (out_dir / "index.html").write_text(page, encoding="utf-8")
    print(out_dir / "index.html")


if __name__ == "__main__":
    main()
