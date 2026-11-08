#!/usr/bin/env python3
"""Add new l10n keys to all 10 ARB files without reformatting them.

Several workers may add keys at the same time, so the whole read-modify-write runs under an
exclusive lock (lib/l10n/.arb.lock). Text is inserted before each file's final closing brace,
so existing formatting and key order are preserved.

Input: a JSON file
  {
    "keys": {
      "r_riftTitle": {
        "description": "Rift run: mode title on the title screen",
        "placeholders": {"n": {"type": "int"}},          # optional
        "ko": "균열 런", "en": "Rift Run", "ja": "...", "zh": "...", "de": "...",
        "fr": "...", "es": "...", "pt": "...", "ru": "...", "id": "..."
      }
    }
  }
Every key needs all 10 locales. Keys that already exist are refused (pick a new name).

Usage: python3 tool/arb_add.py new_keys.json && flutter gen-l10n
"""
import fcntl
import json
import os
import sys

LOCALES = ["ko", "en", "ja", "zh", "de", "fr", "es", "pt", "ru", "id"]
ARB_DIR = os.environ.get("ARB_DIR") or os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib", "l10n")


def main(path: str) -> None:
    spec = json.load(open(path, encoding="utf-8"))["keys"]
    for key, entry in spec.items():
        missing = [loc for loc in LOCALES if not entry.get(loc)]
        if missing:
            sys.exit(f"{key}: missing locales {missing}")
    with open(os.path.join(ARB_DIR, ".arb.lock"), "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        texts = {}
        for loc in LOCALES:
            f = os.path.join(ARB_DIR, f"app_{loc}.arb")
            text = open(f, encoding="utf-8").read()
            existing = json.loads(text)
            dup = [k for k in spec if k in existing]
            if dup:
                sys.exit(f"app_{loc}.arb already has {dup}")
            texts[loc] = (f, text)
        for loc, (f, text) in texts.items():
            chunks = []
            for key, entry in spec.items():
                chunks.append(f"  {json.dumps(key)}: {json.dumps(entry[loc], ensure_ascii=False)}")
                if loc == "ko":  # template carries the metadata
                    meta = {"description": entry.get("description", "")}
                    if entry.get("placeholders"):
                        meta["placeholders"] = entry["placeholders"]
                    body = json.dumps(meta, ensure_ascii=False, indent=2).replace("\n", "\n  ")
                    chunks.append(f"  {json.dumps('@' + key)}: {body}")
            end = text.rstrip().rfind("}")
            head = text[:end].rstrip()
            new = head + ",\n" + ",\n".join(chunks) + "\n}\n"
            json.loads(new)  # must stay valid
            open(f, "w", encoding="utf-8").write(new)
        print(f"added {len(spec)} keys to {len(LOCALES)} ARB files")


if __name__ == "__main__":
    main(sys.argv[1])
