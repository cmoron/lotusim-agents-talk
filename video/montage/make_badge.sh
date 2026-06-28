#!/bin/bash
# make_badge.sh <MAIN> <SUB> <ACCENT_HEX> <out.png>
# Lower-third badge: dark translucent pill + accent tab + main label + sub label.
set -euo pipefail
MAIN="$1"; SUB="$2"; ACCENT="$3"; OUT="$4"
BOLD="/System/Library/Fonts/Supplemental/Courier New Bold.ttf"
REG="/System/Library/Fonts/Supplemental/Courier New.ttf"
magick -size 860x176 xc:none \
  -fill '#0B1A33E6' -draw 'roundrectangle 0,0,859,175,24,24' \
  -fill "$ACCENT" -draw 'roundrectangle 22,22,34,154,5,5' \
  -gravity NorthWest \
  -font "$BOLD" -fill '#FFFFFF' -pointsize 68 -annotate +60+30 "$MAIN" \
  -font "$REG"  -fill '#AAC2E4' -pointsize 30 -annotate +62+120 "$SUB" \
  "$OUT"
echo "made $OUT"
