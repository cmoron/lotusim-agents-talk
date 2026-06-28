#!/bin/bash
# make_sheet_range.sh <video> <start_s> <end_s> <interval_s> <cols> <out.png>
set -euo pipefail
video="$1"; start="$2"; end="$3"; interval="$4"; cols="$5"; out="$6"
work=$(mktemp -d)
i=0; t="$start"
while [ "$t" -lt "$end" ]; do
  label=$(printf '%02dh%02dm%02ds' $((t/3600)) $(((t%3600)/60)) $((t%60)))
  ffmpeg -nostdin -loglevel error -ss "$t" -i "$video" -frames:v 1 -vf "scale=384:-1" "$work/$label.png" </dev/null
  t=$((t+interval)); i=$((i+1))
done
magick montage "$work"/*.png -tile "${cols}x" -geometry +3+3 \
  -font "/System/Library/Fonts/Supplemental/Courier New.ttf" \
  -background '#111111' -bordercolor '#444' -border 1 \
  -fill '#FFD400' -pointsize 22 -gravity South -label '%t' "$out"
rm -rf "$work"
echo "made $out ($i frames, ${start}-${end}s)"
