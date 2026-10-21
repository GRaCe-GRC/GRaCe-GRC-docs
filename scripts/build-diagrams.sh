#!/usr/bin/env bash
# Regenerate SVG/PNG from every Mermaid source and refresh the Mermaid
# embedded in Markdown pages (between <!-- mermaid-source: ... --> markers).
#
# Usage:  scripts/build-diagrams.sh            # all diagrams
#         scripts/build-diagrams.sh path/to.mmd  # specific files
# Needs:  Node.js (uses npx @mermaid-js/mermaid-cli) and python3
set -euo pipefail
cd "$(dirname "$0")/.."

MMDC="${MMDC:-npx -y @mermaid-js/mermaid-cli@11}"
PUPPETEER_CFG="${PUPPETEER_CFG:-}"
extra=()
[[ -n "$PUPPETEER_CFG" ]] && extra=(-p "$PUPPETEER_CFG")

if [[ $# -gt 0 ]]; then files=("$@"); else
  files=(); while IFS= read -r f; do files+=("$f"); done < <(find assets/diagrams -name '*.mmd' | sort)
fi

for f in "${files[@]}"; do
  base="${f%.mmd}"
  echo "• $f"
  $MMDC -q -i "$f" -o "$base.svg" -b white ${extra[@]+"${extra[@]}"}
  $MMDC -q -i "$f" -o "$base.png" -b white -s 2 ${extra[@]+"${extra[@]}"}
done

python3 - <<'PY'
import re, pathlib
pat = re.compile(r"(<!-- mermaid-source: (\S+) -->\n```mermaid\n)(.*?)(\n```\n<!-- /mermaid-source -->)", re.S)
for md in pathlib.Path(".").rglob("*.md"):
    if "node_modules" in md.parts: continue
    text = md.read_text()
    new = pat.sub(lambda m: m.group(1) + pathlib.Path(m.group(2)).read_text().strip() + m.group(4), text)
    if new != text:
        md.write_text(new); print(f"  synced {md}")
PY
echo "Done."
