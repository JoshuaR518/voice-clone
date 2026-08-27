#!/bin/bash
# Quality-check a take before uploading it to ElevenLabs.
# Usage: ./qc.sh takes/session1_20260824-2130.wav
set -u
F="${1:?wav file required}"
[ -f "$F" ] || { echo "No such file: $F"; exit 1; }

FMT=$(ffprobe -v error -select_streams a:0 -show_entries stream=sample_fmt  -of default=nw=1:nk=1 "$F")
RATE=$(ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of default=nw=1:nk=1 "$F")
CH=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels     -of default=nw=1:nk=1 "$F")
DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$F")

STATS=$(ffmpeg -hide_banner -i "$F" -af astats=metadata=1:reset=0 -f null - 2>&1)
PEAK=$(echo "$STATS" | grep -m1 "Peak level dB:"  | sed 's/.*: *//')
RMS=$(echo "$STATS"  | grep -m1 "RMS level dB:"   | sed 's/.*: *//')
FLOOR=$(echo "$STATS"| grep -m1 "Noise floor dB:" | sed 's/.*: *//')

# High-frequency energy: detects Bluetooth/narrowband codecs upsampled to 48k
HPCHAIN="highpass=f=9000:poles=2,highpass=f=9000:poles=2,highpass=f=9000:poles=2,highpass=f=9000:poles=2"
HF=$(ffmpeg -hide_banner -i "$F" -af "$HPCHAIN,astats=metadata=1:reset=0" -f null - 2>&1 \
      | grep -m1 "RMS level dB:" | sed 's/.*: *//')

SIL=$(ffmpeg -hide_banner -i "$F" -af silencedetect=n=-40dB:d=2.5 -f null - 2>&1 \
      | grep -c silence_start)

printf '\n--- QC: %s ---\n' "$(basename "$F")"
printf 'format     : %s Hz, %s ch, %s\n' "$RATE" "$CH" "$FMT"
printf 'duration   : %.1f min\n' "$(echo "$DUR/60" | bc -l)"
printf 'peak       : %.1f dBFS\n' "$PEAK"
printf 'rms        : %.1f dBFS\n' "$RMS"
printf 'noise floor: %.1f dBFS\n' "$FLOOR"
printf 'hf energy  : %.1f dBFS (>9kHz)\n' "$HF"
printf 'long gaps  : %s (>2.5s silences)\n' "$SIL"
echo
awk -v peak="$PEAK" -v rms="$RMS" -v floor="$FLOOR" -v sil="$SIL" -v rate="$RATE" -v fmt="$FMT" -v hf="$HF" '
function isnum(x) { return x ~ /^-?[0-9]+(\.[0-9]+)?$/ }
BEGIN{
  ok=1

  if (!isnum(peak) || !isnum(rms) || !isnum(floor) || !isnum(hf)) {
    printf "FAIL  peak/rms/noise-floor unmeasurable (peak=%s rms=%s floor=%s hf=%s dB) - file is likely silent or corrupt\n", peak, rms, floor, hf
    ok=0
  } else {
    if (peak > -1.0)       { printf "FAIL  peak %.1f dBFS - clipping likely, lower gain\n", peak; ok=0 }
    else if (peak > -3.0)  { printf "WARN  peak %.1f dBFS is hot - aim for -6 to -3\n", peak }
    else if (peak < -12.0) { printf "WARN  peak %.1f dBFS is low - raise gain or move closer\n", peak }
    else                   { printf "PASS  peak %.1f dBFS\n", peak }

    snr = rms - floor
    if (snr < 30)      { printf "FAIL  signal-to-noise %.0f dB - too noisy, quieter room needed\n", snr; ok=0 }
    else if (snr < 45) { printf "WARN  signal-to-noise %.0f dB - usable, could be cleaner\n", snr }
    else               { printf "PASS  signal-to-noise %.0f dB\n", snr }

    hfgap = rms - hf
    if (hfgap > 55)      { printf "FAIL  no real energy above 9kHz (%.0f dB down) - narrowband codec upsampled, not true 48kHz\n", hfgap; ok=0 }
    else if (hfgap > 45) { printf "WARN  weak high frequencies (%.0f dB down) - may sound dull\n", hfgap }
    else                 { printf "PASS  full bandwidth (%.0f dB down above 9kHz)\n", hfgap }

    if (floor > -50) printf "WARN  noise floor %.1f dBFS is high - check HVAC, fridge, fans\n", floor
  }

  if (sil > 0) printf "WARN  %d silence(s) over 2.5s - trim before upload\n", sil
  else print "PASS  no long silences"

  if (rate != 48000 && rate != 44100) { print "FAIL  sample rate " rate " - need 44100 or 48000"; ok=0 }
  else print "PASS  sample rate " rate

  if (fmt != "s32" && fmt != "s24" && fmt != "s16") print "WARN  unexpected sample format " fmt

  print ""
  print ok ? ">> Usable for cloning." : ">> Re-record this take."
}'
