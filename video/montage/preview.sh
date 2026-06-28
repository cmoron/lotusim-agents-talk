#!/bin/bash
# preview.sh — render ONE clip and open it, to test a cut/speed/badge in ~3s
# (no need to re-render the whole 4-min montage).
#
#   bash video/montage/preview.sh FILE IN OUT SPEED [BADGE] [HOLD]
#
# examples (IN/OUT accept seconds OR mm:ss OR hh:mm:ss — paste the QuickTime time):
#   bash video/montage/preview.sh 3-unity_manual_fix_mesh.mov 5:16 5:24 1 16_misorient.png
#   bash video/montage/preview.sh 5-unity_run_fixed.mov 36 60 1.5 09_payoff.png 4
#   bash video/montage/preview.sh 1-prompt-map-blander-agentic-loop.mov 31:00 31:10 1 04_mesh.png
#
# FILE  rush filename (in video/)   IN start time   OUT end time  (s | mm:ss | hh:mm:ss)
# SPEED 1 = real time, 100 = 100x   BADGE  png in badges/ (omit for none)
# HOLD  seconds the badge stays (default: whole clip)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VID="$(cd "$HERE/.." && pwd)"
BAD="$HERE/badges"
mkdir -p "$VID/_build"
OUT="$VID/_build/_preview.mp4"
t2s(){ awk -v v="$1" 'BEGIN{n=split(v,a,":");
  if(n==1)s=a[1]; else if(n==2)s=a[1]*60+a[2]; else s=a[1]*3600+a[2]*60+a[3];
  printf "%.3f", s}'; }
FILE="$1"; IN=$(t2s "$2"); LEN=$(awk -v a="$(t2s "$2")" -v b="$(t2s "$3")" 'BEGIN{printf "%.3f", b-a}'); SPEED="$4"; BADGE="${5:--}"; HOLD="${6:-full}"

# single FROZEN frame when IN == OUT (grabs one exact frame, held 3s for the preview)
if awk -v l="$LEN" 'BEGIN{exit !(l<=0)}'; then
  frame="$VID/_build/_preview_frame.png"
  ffmpeg -nostdin -loglevel error -y -ss "$IN" -i "$VID/$FILE" -frames:v 1 "$frame" </dev/null
  if [ "$BADGE" = "-" ]; then
    ffmpeg -nostdin -loglevel error -y -loop 1 -t 3 -i "$frame" \
      -filter_complex "[0:v]pad=1920:1080:-1:-1:color=black,fps=30[v]" -map "[v]" -an \
      -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 "$OUT" </dev/null
  else
    ffmpeg -nostdin -loglevel error -y -loop 1 -t 3 -i "$frame" -i "$BAD/$BADGE" \
      -filter_complex "[0:v]pad=1920:1080:-1:-1:color=black,fps=30[bg];[bg][1:v]overlay=64:H-h-56[v]" -map "[v]" -an \
      -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 "$OUT" </dev/null
  fi
  printf "preview (single frame, held 3s): %s\n" "$OUT"; open "$OUT"; exit 0
fi

pad="pad=1920:1080:-1:-1:color=black,setpts=PTS/${SPEED},fps=30"
if [ "$BADGE" = "-" ]; then
  ffmpeg -nostdin -loglevel error -y -ss "$IN" -t "$LEN" -i "$VID/$FILE" \
    -filter_complex "[0:v]${pad}[v]" -map "[v]" -an \
    -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 "$OUT" </dev/null
else
  en=""; [ "$HOLD" != "full" ] && en=":enable='lt(t,${HOLD})'"
  ffmpeg -nostdin -loglevel error -y -ss "$IN" -t "$LEN" -i "$VID/$FILE" -i "$BAD/$BADGE" \
    -filter_complex "[0:v]${pad}[bg];[bg][1:v]overlay=64:H-h-56${en}[v]" -map "[v]" -an \
    -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 "$OUT" </dev/null
fi
printf "preview: %s  (%.1fs)\n" "$OUT" "$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")"
open "$OUT"
