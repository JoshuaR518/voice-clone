#!/bin/bash
# Rank all takes by recording quality. Usage: ./compare.sh
set -u
DIR="$(cd "$(dirname "$0")" && pwd)/takes"
shopt -s nullglob
FILES=("$DIR"/*.wav "$DIR"/*.m4a "$DIR"/*.mp3)
[ ${#FILES[@]} -eq 0 ] && { echo "No takes yet in $DIR"; exit 0; }

HPCHAIN="highpass=f=9000:poles=2,highpass=f=9000:poles=2,highpass=f=9000:poles=2,highpass=f=9000:poles=2"
printf '%-26s %6s %7s %7s %7s %5s %5s  %s\n' TAKE MIN PEAK RMS FLOOR SNR HFGAP VERDICT
printf '%.0s-' {1..96}; echo
for f in "${FILES[@]}"; do
  S=$(ffmpeg -hide_banner -i "$f" -af astats=metadata=1:reset=0 -f null - 2>&1)
  P=$(echo "$S" | grep -m1 "Peak level dB:"  | sed 's/.*: *//')
  R=$(echo "$S" | grep -m1 "RMS level dB:"   | sed 's/.*: *//')
  N=$(echo "$S" | grep -m1 "Noise floor dB:" | sed 's/.*: *//')
  H=$(ffmpeg -hide_banner -i "$f" -af "$HPCHAIN,astats=metadata=1:reset=0" -f null - 2>&1 \
       | grep -m1 "RMS level dB:" | sed 's/.*: *//')
  D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$f")
  awk -v n="$(basename "${f%.*}")" -v p="$P" -v r="$R" -v fl="$N" -v d="$D" -v h="$H" 'BEGIN{
    snr=r-fl; hg=r-h; v="ok"
    if (p > -1)         v="CLIPPED"
    else if (hg > 55)   v="NARROWBAND"
    else if (snr < 30)  v="too noisy"
    else if (p < -12)   v="too quiet"
    else if (hg > 45)   v="dull/weak HF"
    else if (snr >= 45) v="GOOD"
    printf "%-26.26s %6.1f %7.1f %7.1f %7.1f %5.0f %5.0f  %s\n", n, d/60, p, r, fl, snr, hg, v
  }'
done | sort -k6 -rn
echo
echo "Ranked by signal-to-noise. Want peak -6 to -3, SNR 45+, HFGAP under 45."
echo "HFGAP = how far energy above 9kHz sits below overall level. Over 55 means a"
echo "narrowband codec (Bluetooth) upsampled to 48k - disqualifying regardless of SNR."
