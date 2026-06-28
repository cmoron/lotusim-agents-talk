#!/bin/bash
# make_sheet.sh <video> <interval_s> <cols> <out.png>
# Contact sheet with timestamp labels, using fast input-seek (no full decode).
set -euo pipefail
video="$1"; interval="$2"; cols="$3"; out="$4"
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$video")
dur=${dur%.*}
work=$(mktemp -d)
i=0; t=0
while [ "$t" -lt "$dur" ]; do
  label=$(printf '%02dh%02dm%02ds' $((t/3600)) $(((t%3600)/60)) $((t%60)))
  ffmpeg -nostdin -loglevel error -ss "$t" -i "$video" -frames:v 1 -vf "scale=384:-1" "$work/$label.png" </dev/null
  t=$((t+interval)); i=$((i+1))
done
magick montage "$work"/*.png -tile "${cols}x" -geometry +3+3 \
  -font "/System/Library/Fonts/Supplemental/Courier New.ttf" \
  -background '#111111' -bordercolor '#444' -border 1 \
  -fill '#FFD400' -pointsize 22 -gravity South -label '%t' "$out"
rm -rf "$work"
echo "made $out ($i frames, dur=${dur}s)"
