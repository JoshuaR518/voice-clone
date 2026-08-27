#!/bin/bash
# Render text to speech in your cloned voice.
#   ./render.sh script.txt                  -> script.mp3
#   ./render.sh script.txt out.mp3
#   echo "hello" | ./render.sh - out.mp3
# Env overrides:
#   VOICE_ID=<id>   which voice (default: current clone)
#   MODEL=<id>      eleven_multilingual_v2 (English) | eleven_v3 (Thai + 74 langs)
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
IN="${1:?usage: render.sh <textfile|-> [out.mp3]}"
VOICE_ID="${VOICE_ID:-saTqRyCkmr2vTMOCaOu9}"
MODEL="${MODEL:-eleven_multilingual_v2}"

if [ "$IN" = "-" ]; then
  TEXT=$(cat); OUT="${2:?output file required when reading stdin}"
else
  [ -f "$IN" ] || { echo "No such file: $IN" >&2; exit 1; }
  TEXT=$(cat "$IN"); OUT="${2:-${IN%.*}.mp3}"
fi

KEY=$(security find-generic-password -s elevenlabs -a 'Elevenlabs AK' -w) || {
  echo "Could not read API key from Keychain." >&2; exit 1; }

CHARS=${#TEXT}
echo "voice : $VOICE_ID"
echo "model : $MODEL"
echo "chars : $CHARS"

BODY=$(python3.14 -c 'import json,sys; print(json.dumps({"text":sys.argv[1],"model_id":sys.argv[2]}))' "$TEXT" "$MODEL")

set +e
CODE=$(printf '%s' "$BODY" | curl -s -X POST \
  "https://api.elevenlabs.io/v1/text-to-speech/$VOICE_ID?output_format=mp3_44100_128" \
  -H "xi-api-key: $KEY" -H "Content-Type: application/json" \
  --data-binary @- -o "$OUT" -w '%{http_code}')
CURL_EXIT=$?
set -e

if [ "$CURL_EXIT" -ne 0 ]; then
  echo "FAILED: curl error $CURL_EXIT (network/connection failure) - could not reach ElevenLabs" >&2
  rm -f "$OUT"
  exit 1
fi

if [ "$CODE" != "200" ]; then
  echo "FAILED (http $CODE):" >&2
  [ -f "$OUT" ] && { head -c 400 "$OUT" >&2; echo >&2; }
  rm -f "$OUT"
  exit 1
fi
DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$OUT")
printf 'wrote : %s  (%.1f s, %s)\n' "$OUT" "$DUR" "$(du -h "$OUT" | cut -f1)"
