#!/bin/bash
# montage.sh — assemble the slide-9 demo video from the 6 OBS rushes in ../ .
#
# Edit the TABLE below, then:  bash video/montage/montage.sh  [out.mp4]
# Output defaults to ../_build/slide9_demo.mp4
#
# Each TABLE line:  FILE|IN|OUT|SPEED|BADGE|HOLD|TPAD
#   FILE  rush filename (in video/)
#   IN    start time in the rush — seconds OR mm:ss OR hh:mm:ss (paste the QuickTime time as-is)
#   OUT   end   time in the rush — seconds OR mm:ss OR hh:mm:ss (no duration math needed)
#   SPEED playback speed   (1 = real time;  100 = 100x faster — for "thinking" phases)
#   BADGE badge png in badges/ (or "-" for none)
#   HOLD  seconds the badge stays on screen (output time), or "full"
#   TPAD  freeze the last frame N extra seconds (0 = none) — for an end card
#         SINGLE FROZEN FRAME: set IN == OUT and TPAD = N → grabs exactly one frame at IN,
#         held N seconds (no risk of catching an alt-tab / a changing frame).
#
# On-screen duration of a segment = (OUT - IN) / SPEED.
# Heroes (slow / real time, SPEED=1): the Blender mesh, the quaternion fix, the green test,
# the Unity render, the sailboat rounding the buoy, the signed PR.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VID="$(cd "$HERE/.." && pwd)"
BAD="$HERE/badges"
BUILD="$VID/_build"
OUT="${1:-$BUILD/slide9_demo.mp4}"
# Per-output work dir → each named render keeps its OWN segments (no clobber between variants).
WORK="$BUILD/segs_$(basename "${OUT%.*}")"; rm -rf "$WORK"; mkdir -p "$WORK"

# seconds  <-  "SS[.ms]" | "MM:SS" | "HH:MM:SS"
t2s(){ awk -v v="$1" 'BEGIN{n=split(v,a,":");
  if(n==1)s=a[1]; else if(n==2)s=a[1]*60+a[2]; else s=a[1]*3600+a[2]*60+a[3];
  printf "%.3f", s}'; }

F1="1-prompt-map-blander-agentic-loop.mov"
F2="2-prepare-unity.mov"
F3="3-unity_manual_fix_mesh.mov"
F4="4-unity_first_run.mov"
F5="5-unity_run_fixed.mov"
F6="6-ship.mov"

# ---- EDIT HERE — times are start|end, in s or mm:ss or hh:mm:ss --------------
TABLE=$(cat <<EOF
$F1|0:01:05|0:11:00|100|01_map.png|full|0
$F1|0:11:00|0:28:00|50|02_plan.png|full|0
$F1|0:28:00|0:40:00|110|04_mesh.png|full|0
$F1|0:40:00|0:57:40|160|03_build.png|full|0
$F1|0:57:40|1:07:20|100|19_quaternion.png|full|0
$F1|1:07:20|1:13:00|100|06_test.png|full|0
$F1|1:13:00|1:38:00|130|14_loop.png|full|0
$F1|1:38:00|1:44:00|60|15_doc_human.png|full|0
$F2|0:02:00|0:16:00|130|08_unity.png|full|0
$F3|0:05:05|0:05:10|1|16_misorient.png|full|0
$F3|0:05:05|0:10:50|60|17_unity_human.png|full|0
$F4|0:00:20|0:01:10|8|13_firstrun.png|full|0
$F5|0:00:30|0:01:00|1.5|09_payoff.png|4|0
$F6|0:01:00|0:21:00|130|11_ship.png|full|0
$F6|0:21:30|0:21:46|1|12_sign.png|5|3
EOF
)
# ---------------------------------------------------------------------------

i=0
: > "$WORK/list.txt"
while IFS='|' read -r FILE IN OUT_T SPEED BADGE HOLD TPAD; do
  [ -z "${FILE:-}" ] && continue
  IN_S=$(t2s "$IN"); OUT_S=$(t2s "$OUT_T")
  LEN=$(awk -v a="$IN_S" -v b="$OUT_S" 'BEGIN{printf "%.3f", b-a}')
  i=$((i+1))
  seg=$(printf "%s/seg_%02d.mp4" "$WORK" "$i")
  # --- single FROZEN frame: IN==OUT (LEN<=0) -> grab exactly one frame at IN, hold TPAD seconds ---
  if awk -v l="$LEN" 'BEGIN{exit !(l<=0)}'; then
    if awk -v t="$TPAD" 'BEGIN{exit !((t+0)<=0)}'; then
      echo "  !! skip: $FILE $IN==$OUT_T is a still — set TPAD>0 (freeze seconds)"; i=$((i-1)); continue
    fi
    frame="$WORK/frame_$i.png"
    ffmpeg -nostdin -loglevel error -y -ss "$IN_S" -i "$VID/$FILE" -frames:v 1 "$frame" </dev/null
    if [ "$BADGE" = "-" ]; then
      ffmpeg -nostdin -loglevel error -y -loop 1 -t "$TPAD" -i "$frame" \
        -filter_complex "[0:v]pad=1920:1080:-1:-1:color=black,fps=30[v]" -map "[v]" -an \
        -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 "$seg" </dev/null
    else
      en=""; [ "$HOLD" != "full" ] && en=":enable='lt(t,${HOLD})'"
      ffmpeg -nostdin -loglevel error -y -loop 1 -t "$TPAD" -i "$frame" -i "$BAD/$BADGE" \
        -filter_complex "[0:v]pad=1920:1080:-1:-1:color=black,fps=30[bg];[bg][1:v]overlay=64:H-h-56${en}[v]" -map "[v]" -an \
        -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 "$seg" </dev/null
    fi
    printf "file '%s'\n" "$seg" >> "$WORK/list.txt"
    printf "  seg %02d  %-40s %s  FROZEN %ss  [%s]\n" "$i" "$FILE" "$IN" "$TPAD" "$BADGE"
    continue
  fi
  pad="pad=1920:1080:-1:-1:color=black,setpts=PTS/${SPEED},fps=30"
  tpadf=""; [ "${TPAD}" != "0" ] && tpadf=",tpad=stop_mode=clone:stop_duration=${TPAD}"
  if [ "$BADGE" = "-" ]; then
    fc="[0:v]${pad}${tpadf}[v]"
    ffmpeg -nostdin -loglevel error -y -ss "$IN_S" -t "$LEN" -i "$VID/$FILE" \
      -filter_complex "$fc" -map "[v]" -an \
      -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 "$seg" </dev/null
  else
    en=""; [ "$HOLD" != "full" ] && en=":enable='lt(t,${HOLD})'"
    fc="[0:v]${pad}[bg];[bg][1:v]overlay=64:H-h-56${en}${tpadf}[v]"
    ffmpeg -nostdin -loglevel error -y -ss "$IN_S" -t "$LEN" -i "$VID/$FILE" -i "$BAD/$BADGE" \
      -filter_complex "$fc" -map "[v]" -an \
      -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 "$seg" </dev/null
  fi
  d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$seg")
  printf "file '%s'\n" "$seg" >> "$WORK/list.txt"
  printf "  seg %02d  %-40s %s->%s  x%-5s -> %5.1fs  [%s]\n" "$i" "$FILE" "$IN" "$OUT_T" "$SPEED" "$d" "$BADGE"
done <<< "$TABLE"

ffmpeg -nostdin -loglevel error -y -f concat -safe 0 -i "$WORK/list.txt" -c copy "$OUT" </dev/null
tot=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")
echo "=================================================="
mm=$(awk -v t="$tot" 'BEGIN{printf "%d", int(t/60)}')
ss=$(awk -v t="$tot" 'BEGIN{printf "%02d", int(t)%60}')
printf "OUTPUT: %s\n  total = %.1fs  (%s:%s)\n" "$OUT" "$tot" "$mm" "$ss"
