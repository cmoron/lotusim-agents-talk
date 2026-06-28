#!/bin/bash
# montage.sh — assemble the slide-9 demo video from the 6 OBS rushes in ../ .
#
# Edit the TABLE below, then:  bash video/montage/montage.sh  [out.mp4]
# Output defaults to ../_build/slide9_demo.mp4
#
# Each TABLE line:  FILE|IN|LEN|SPEED|BADGE|HOLD|TPAD
#   FILE  rush filename (in video/)
#   IN    source in-point (seconds)
#   LEN   source length to read (seconds)
#   SPEED playback speed   (1 = real time;  100 = 100x faster — for "thinking" phases)
#   BADGE badge png in badges/ (or "-" for none)
#   HOLD  seconds the badge stays on screen (output time), or "full"
#   TPAD  freeze the last frame N extra seconds (0 = none) — for an end card
#
# Heroes (slow / real time, SPEED=1): the Blender mesh, a diff, the green test,
# the Unity render, the sailboat rounding the buoy, the signed PR.
# Everything else is sped up hard. Tweak IN/LEN to nudge the hero in/out points.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VID="$(cd "$HERE/.." && pwd)"
BAD="$HERE/badges"
BUILD="$VID/_build"
OUT="${1:-$BUILD/slide9_demo.mp4}"
# Per-output work dir → each named render keeps its OWN segments (no clobber between variants).
WORK="$BUILD/segs_$(basename "${OUT%.*}")"; rm -rf "$WORK"; mkdir -p "$WORK"

F1="1-prompt-map-blander-agentic-loop.mov"
F2="2-prepare-unity.mov"
F3="3-unity_manual_fix_mesh.mov"
F4="4-unity_first_run.mov"
F5="5-unity_run_fixed.mov"
F6="6-ship.mov"

# ---- EDIT HERE -------------------------------------------------------------
# v3: SAME extracts as v1 (content was OK) — only speed / duration / labels changed,
# plus the false "diff" beat dropped and the seg13 badge split (mis-oriented->straightened).
TABLE=$(cat <<EOF
$F1|240|840|100|01_map.png|full|0
$F1|1080|540|100|02_plan.png|full|0
$F1|1620|240|110|03_build.png|full|0
$F1|1860|10|1|04_mesh.png|full|0
$F1|1870|1970|160|03_build.png|full|0
$F1|3840|8|1|06_test.png|full|0
$F1|3848|1792|130|14_loop.png|full|0
$F1|5640|480|80|15_doc_human.png|full|0
$F2|120|840|130|08_unity.png|full|0
$F3|60|270|90|08_unity.png|full|0
$F3|330|5|1|16_misorient.png|full|0
$F3|335|3|1|17_unity_human.png|full|0
$F3|338|2|1|18_straight.png|full|0
$F3|360|420|130|08_unity.png|full|0
$F4|20|24|8|13_firstrun.png|full|0
$F5|6|26|13|-|full|0
$F5|36|24|1.5|09_payoff.png|4|0
$F6|60|1200|130|11_ship.png|full|0
$F6|1290|16|1|12_sign.png|5|3
EOF
)
# ---------------------------------------------------------------------------

i=0
: > "$WORK/list.txt"
while IFS='|' read -r FILE IN LEN SPEED BADGE HOLD TPAD; do
  [ -z "${FILE:-}" ] && continue
  i=$((i+1))
  seg=$(printf "%s/seg_%02d.mp4" "$WORK" "$i")
  pad="pad=1920:1080:-1:-1:color=black,setpts=PTS/${SPEED},fps=30"
  tpadf=""; [ "${TPAD}" != "0" ] && tpadf=",tpad=stop_mode=clone:stop_duration=${TPAD}"
  if [ "$BADGE" = "-" ]; then
    fc="[0:v]${pad}${tpadf}[v]"
    ffmpeg -nostdin -loglevel error -y -ss "$IN" -t "$LEN" -i "$VID/$FILE" \
      -filter_complex "$fc" -map "[v]" -an \
      -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 "$seg" </dev/null
  else
    en=""; [ "$HOLD" != "full" ] && en=":enable='lt(t,${HOLD})'"
    fc="[0:v]${pad}[bg];[bg][1:v]overlay=64:H-h-56${en}${tpadf}[v]"
    ffmpeg -nostdin -loglevel error -y -ss "$IN" -t "$LEN" -i "$VID/$FILE" -i "$BAD/$BADGE" \
      -filter_complex "$fc" -map "[v]" -an \
      -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 "$seg" </dev/null
  fi
  d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$seg")
  printf "file '%s'\n" "$seg" >> "$WORK/list.txt"
  printf "  seg %02d  %-40s in=%-5s len=%-5s x%-4s -> %5.1fs  [%s]\n" "$i" "$FILE" "$IN" "$LEN" "$SPEED" "$d" "$BADGE"
done <<< "$TABLE"

ffmpeg -nostdin -loglevel error -y -f concat -safe 0 -i "$WORK/list.txt" -c copy "$OUT" </dev/null
tot=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")
echo "=================================================="
mm=$(awk -v t="$tot" 'BEGIN{printf "%d", int(t/60)}')
ss=$(awk -v t="$tot" 'BEGIN{printf "%02d", int(t)%60}')
printf "OUTPUT: %s\n  total = %.1fs  (%s:%s)\n" "$OUT" "$tot" "$mm" "$ss"
