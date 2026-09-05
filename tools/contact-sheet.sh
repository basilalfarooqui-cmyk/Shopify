#!/usr/bin/env bash
# contact-sheet.sh — builds a browsable contact sheet of an image folder so the
# photography can be eyeballed at a glance before it goes into a page.
#
#   bash tools/contact-sheet.sh <img-dir> [columns]
#   then open  http://localhost:4321/<img-dir>/_sheet.html
#
# (start the server first:  powershell -ExecutionPolicy Bypass -File tools\serve.ps1)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
case "$1" in /*|[A-Za-z]:*) DIR="$1" ;; *) DIR="$ROOT/$1" ;; esac
COLS="${2:-7}"

{
  echo '<!doctype html><meta charset=utf-8><title>contact sheet</title>'
  echo '<style>body{background:#101012;color:#eee;font:12px ui-sans-serif,system-ui;margin:0;padding:8px}'
  echo ".g{display:grid;grid-template-columns:repeat($COLS,1fr);gap:4px}"
  echo 'figure{margin:0}img{width:100%;aspect-ratio:1;object-fit:cover;display:block;background:#222}'
  echo 'figcaption{font:11px ui-monospace,monospace;color:#6cf;padding:2px 0}</style><div class=g>'
  for f in "$DIR"/*.jpg "$DIR"/*.png "$DIR"/*.webp; do
    [ -e "$f" ] || continue
    b=$(basename "$f")
    printf '<figure><img src="%s" loading="eager"><figcaption>%s</figcaption></figure>\n' "$b" "${b%.*}"
  done
  echo '</div>'
} > "$DIR/_sheet.html"
echo "sheet: $DIR/_sheet.html  ($(ls "$DIR" | grep -cE '\.(jpg|png|webp)$') images)"
