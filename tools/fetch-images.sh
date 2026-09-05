#!/usr/bin/env bash
# fetch-images.sh — downloads the photography for a site from a manifest file.
#
#   bash tools/fetch-images.sh <manifest> <dest-dir> [width] [height]
#
# Manifest format — one image per line, blank lines and #comments ignored:
#
#   <output-name>  <unsplash-photo-id>  [WxH]
#
# e.g.  jewel-hero   photo-1515562141207-7a88fb7ce338   1600x1100
#       jewel-01     photo-1602751584552-8ba73aad10e1
#
# Images are served from images.unsplash.com (the public image CDN) and saved
# locally, so every site in this project works fully offline once fetched.
# Re-running skips files that already exist. Photos are used under the
# Unsplash License; see assets/CREDITS.md.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$1"
DEST="$2"
DEFW="${3:-1200}"
DEFH="${4:-1200}"
UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36'

case "$MANIFEST" in /*|[A-Za-z]:*) MF="$MANIFEST" ;; *) MF="$ROOT/$MANIFEST" ;; esac
case "$DEST"     in /*|[A-Za-z]:*) OUT="$DEST"     ;; *) OUT="$ROOT/$DEST" ;; esac
mkdir -p "$OUT"

[ -f "$MF" ] || { echo "!! manifest not found: $MF"; exit 1; }

total=0; got=0; skipped=0; failed=""
while read -r name id size rest; do
  case "${name:-}" in ''|'#'*) continue ;; esac
  [ -z "${id:-}" ] && continue
  total=$((total+1))
  file="$OUT/${name}.jpg"
  if [ -s "$file" ]; then skipped=$((skipped+1)); got=$((got+1)); continue; fi

  w="$DEFW"; h="$DEFH"
  if [ -n "${size:-}" ]; then
    w="${size%x*}"; h="${size#*x}"
  fi

  url="https://images.unsplash.com/${id}?w=${w}&h=${h}&fit=crop&crop=entropy&q=76&fm=jpg&auto=format"
  if curl -sfL --max-time 90 -A "$UA" -o "$file" "$url" && [ -s "$file" ] \
     && head -c 2 "$file" | od -An -tx1 | grep -q 'ff d8'; then
    got=$((got+1))
  else
    rm -f "$file"; failed="$failed $name"
  fi
done < "$MF"

echo "  $(basename "$MF"): ${got}/${total} ok (${skipped} cached)"
[ -n "$failed" ] && echo "  MISSING:$failed"
exit 0
