#!/bin/bash
# Create an INSTANT voice clone from take files.
#   ./clone.sh "Josh Q2U Instant" takes/q2u-session1.wav [more.wav ...]
# Uses one of your 30 instant slots (never the single Professional slot).
# Professional clones must be created in the ElevenLabs web UI - they require
# identity verification that the API does not expose.
set -euo pipefail
NAME="${1:?usage: clone.sh \"Voice Name\" file1.wav [file2.wav ...]}"; shift
[ $# -ge 1 ] || { echo "At least one audio file required." >&2; exit 1; }

KEY=$(security find-generic-password -s elevenlabs -a 'Elevenlabs AK' -w)

# Show what will be uploaded, and its QC verdict, before spending a slot.
DIR="$(cd "$(dirname "$0")" && pwd)"
TOTAL=0
FAILED=0
echo "Files to upload:"
for f in "$@"; do
  [ -f "$f" ] || { echo "  MISSING: $f" >&2; exit 1; }
  if ! D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$f" 2>&1); then
    echo "  UNREADABLE: $f (ffprobe: $D)" >&2
    FAILED=1
    continue
  fi
  if ! [[ "$D" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "  BAD DURATION: $f (ffprobe returned '$D')" >&2
    FAILED=1
    continue
  fi
  V=$("$DIR/qc.sh" "$f" 2>/dev/null | tail -1)
  TOTAL=$(echo "$TOTAL + $D" | bc)
  printf '  %-42s %5.1f min   %s\n' "$(basename "$f")" "$(echo "$D/60"|bc -l)" "$V"
done
[ "$FAILED" -eq 0 ] || { echo "Fix or remove the file(s) above before cloning - no slot spent." >&2; exit 1; }
printf 'Total: %.1f minutes\n\n' "$(echo "$TOTAL/60"|bc -l)"

USED=$(curl -s https://api.elevenlabs.io/v1/user/subscription -H "xi-api-key: $KEY" \
       | python3.14 -c '
import json, sys
d = json.load(sys.stdin)
if "voice_slots_used" in d and "voice_limit" in d:
    print(f"{d['voice_slots_used']}/{d['voice_limit']}")
else:
    print("subscription check failed: " + json.dumps(d)[:300], file=sys.stderr)
    sys.exit(1)
') || { echo "Could not check ElevenLabs subscription/slot usage - aborting before spending a slot." >&2; exit 1; }
echo "Instant slots in use: $USED"
read -r -p "Create instant clone \"$NAME\"? [y/N] " ok
[ "$ok" = "y" ] || { echo "Aborted."; exit 0; }

ARGS=(); for f in "$@"; do ARGS+=(-F "files=@$f"); done
RESP=$(curl -s -X POST https://api.elevenlabs.io/v1/voices/add \
  -H "xi-api-key: $KEY" -F "name=$NAME" "${ARGS[@]}")

echo "$RESP" | python3.14 -c '
import json,sys
d=json.load(sys.stdin)
if "voice_id" in d:
    print("created voice_id:", d["voice_id"])
    print("render with:  VOICE_ID=%s ./render.sh script.txt" % d["voice_id"])
else:
    print("FAILED:", json.dumps(d)[:400])
'
