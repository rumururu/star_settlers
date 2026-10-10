"""전체 언어 검수 목차: review/index.html (언어별 페이지 링크 + 폰 첫 장 미리보기)"""
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOCS = [("ko-KR", "한국어"), ("en-US", "English"), ("ja-JP", "日本語"), ("zh-CN", "中文"), ("es-ES", "Español"),
        ("fr-FR", "Français"), ("de-DE", "Deutsch"), ("pt-BR", "Português"), ("ru-RU", "Русский"), ("id-ID", "Indonesia")]
cards = []
for loc, name in LOCS:
    fin = ROOT / "final" / "locales" / loc
    ph = len([f for f in os.listdir(fin / "phone") if f.endswith(".png") and "google" not in f]) if (fin / "phone").exists() else 0
    tb = len([f for f in os.listdir(fin / "tablet") if f.endswith(".png")]) if (fin / "tablet").exists() else 0
    fg = (fin / "common" / "feature_graphic_1024x500.png").exists()
    thumb = os.path.relpath(fin / "phone" / "01_title.png", ROOT / "review")
    cards.append(f'<a class="c" href="{loc}/index.html"><img src="{thumb}"><b>{name}</b>'
                 f'<span>{loc} · 폰 {ph} · 아이패드 {tb} · 피처 {"✓" if fg else "✗"}</span></a>')
html = f'''<!doctype html><html lang="ko"><meta charset="utf-8"><title>Star Settlers 스토어 이미지 검수</title>
<style>body{{margin:0;background:#0d0b26;color:#eee;font-family:-apple-system,"Apple SD Gothic Neo",sans-serif}}
h1{{padding:20px 24px 0;margin:0;font-size:22px}} p{{padding:0 24px;color:#aab}}
.g{{display:grid;grid-template-columns:repeat(auto-fill,minmax(170px,1fr));gap:16px;padding:16px 24px}}
.c{{background:#151236;border:1px solid #333;border-radius:14px;padding:10px;color:#eee;text-decoration:none;display:flex;flex-direction:column;gap:4px}}
.c img{{width:100%;border-radius:8px}} .c span{{color:#8ad8ff;font-size:12px}}</style>
<h1>Star Settlers · 스토어 이미지 검수 (10개 언어)</h1><p>언어를 누르면 그 언어의 폰·아이패드·피처 그래픽 전체를 볼 수 있어요.</p>
<div class="g">{"".join(cards)}</div>'''
(ROOT / "review" / "index.html").write_text(html, encoding="utf-8")
print(ROOT / "review" / "index.html")
