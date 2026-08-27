#!/bin/bash
# Record a take at ElevenLabs Professional Voice Clone spec: 48kHz, 24-bit, mono WAV.
# Usage: ./record.sh <device_index> <label> [max_seconds]
#   ./record.sh 0 lav-test 15
#   ./record.sh 1 session1 1800
# Press q to stop early.
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
IDX="${1:?device index required - run ./devices.sh to list}"
LABEL="${2:?label required, e.g. session1}"
SECS="${3:-1800}"
OUT="$DIR/takes/${LABEL}_$(date +%Y%m%d-%H%M%S).wav"

echo "Recording device [$IDX] -> $(basename "$OUT")"
echo "Max ${SECS}s. Press q then Enter to stop early."
echo
ffmpeg -hide_banner -loglevel warning -stats \
  -f avfoundation -i ":$IDX" \
  -ar 48000 -ac 1 -c:a pcm_s24le \
  -t "$SECS" "$OUT"

if [ -f "$OUT" ]; then
  echo
  echo "Saved: $OUT"
  "$DIR/qc.sh" "$OUT"
else
  echo "No file written - check microphone permission for your terminal."
fi
