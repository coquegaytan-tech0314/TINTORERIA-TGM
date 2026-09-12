#!/usr/bin/env bash
# Re-encrypt src/dashboard.html → index.html (StatiCrypt gate for GitHub Pages).
# NEVER commit a plaintext dashboard as index.html on main.
#
# Required:
#   STATICRYPT_PASSWORD   same production curtain password already used on Pages
#
# Optional:
#   STATICRYPT_SALT       32-char hex; defaults to .staticrypt.json salt
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SRC="src/dashboard.html"
OUT="index.html"
SALT="${STATICRYPT_SALT:-}"

if [[ ! -f "$SRC" ]]; then
  echo "missing $SRC" >&2
  exit 1
fi

if [[ -z "${STATICRYPT_PASSWORD:-}" ]]; then
  echo "Set STATICRYPT_PASSWORD to the existing Pages curtain password, then re-run." >&2
  exit 1
fi

if [[ -z "$SALT" && -f .staticrypt.json ]]; then
  SALT="$(python3 -c "import json; print(json.load(open('.staticrypt.json'))['salt'])")"
fi

if [[ -z "$SALT" ]]; then
  echo "No salt: set STATICRYPT_SALT or keep .staticrypt.json" >&2
  exit 1
fi

TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

# Match the live v24 gate copy; only the primary button color changes (TGM red).
npx --yes staticrypt "$SRC" \
  --password "$STATICRYPT_PASSWORD" \
  --salt "$SALT" \
  --short \
  --remember 30 \
  --directory "$TMPDIR" \
  --template-title "Tintoreria TGM · Acceso restringido" \
  --template-button "Entrar" \
  --template-remember "Recordar 30 días en este equipo" \
  --template-color-primary "#FF2E4D" \
  --template-color-secondary "#0c1119"

GATED="$(find "$TMPDIR" -name '*.html' | head -n 1)"
if [[ -z "$GATED" ]]; then
  echo "staticrypt produced no HTML" >&2
  exit 1
fi
mv -f "$GATED" "$OUT"

if ! grep -q 'class="staticrypt-html"' "$OUT"; then
  echo "encrypt failed: $OUT is not a StatiCrypt gate" >&2
  exit 1
fi

# Live v24 defaults Remember to on (30 days). StatiCrypt's template does not.
python3 - <<'PY'
from pathlib import Path
p = Path("index.html")
t = p.read_text(encoding="utf-8")
old = '<input id="staticrypt-remember" type="checkbox" name="remember" />'
new = '<input id="staticrypt-remember" type="checkbox" name="remember" checked />'
if old in t:
    p.write_text(t.replace(old, new, 1), encoding="utf-8")
    print("remember checkbox defaulted to checked")
elif new in t:
    print("remember checkbox already checked")
else:
    print("WARN: remember checkbox not found")
PY

echo "Wrote gated $OUT (salt $SALT). Safe to merge to main / Pages."
