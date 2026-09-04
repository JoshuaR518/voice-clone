# Baseline — what the previous mics measured

Numbers from `./compare.sh` over the seven takes in `takes/`, all recorded 2026-08-24
reading `TEST-SCRIPT.md`. Keep this file as the thing a new microphone has to beat.

```
TAKE                                  MIN    PEAK     RMS   FLOOR   SNR HFGAP  VERDICT
--------------------------------------------------------------------------------------
airpods-30pct_20260824-225051         1.5    -0.9   -26.1   -66.0    40    38  CLIPPED
macbook-take2_20260824-231109         1.2   -12.8   -37.3   -68.5    31    23  too quiet
logitech-webcam_20260824-222651       1.5    -0.9   -23.5   -53.4    30    52  CLIPPED
iphone-continuity_20260824-230429     1.2   -13.1   -39.8   -68.4    29    23  too noisy
iphone-close_20260824-231744          1.1   -18.1   -39.1   -68.1    29    23  too noisy
macbook-builtin_20260824-220930       1.4    -3.0   -27.1   -52.4    25    27  too noisy
airpods-test_20260824-223006          1.5    -0.3   -24.6    -inf   n/a    38  CLIPPED
```

**Nothing here passes.** Not one take clears the bar in `qc.sh` (peak -6 to -3,
SNR 45+, HFGAP under 45), so any new mic only has to be *usable*, not best-in-class.

What each failure actually was:

- **AirPods** (both takes) — gain runs away and clips, and the noise floor reads
  `-inf` because the AirPod gate drops to digital silence between phrases. That gate
  is why SNR is unmeasurable rather than excellent: there is no room tone left to
  measure. HFGAP 38 says the codec is wideband, so it isn't the classic Bluetooth
  narrowband failure — it's the processing.
- **Logitech webcam** — clipped *and* HFGAP 52, the worst bandwidth of the set.
  Nothing above 9 kHz. Disqualifying on its own.
- **MacBook built-in** — SNR 25 with a -52 dBFS floor. The room and the laptop are
  audible under everything.
- **iPhone** (Continuity and held close) — the cleanest tone of the group
  (HFGAP 23, floor -68) but recorded far too quiet: peak -13 to -18 dBFS drags SNR
  down to 29. This is the only failure mode that is purely a gain problem.

## Testing a new mic against this

Recording has to happen on the Mac — `record.sh` uses `avfoundation`, and this
repo's tooling can only measure files after the fact.

```sh
./devices.sh                        # indices move every time, check first
./record.sh <idx> <mic-label> 60    # read TEST-SCRIPT.md, same pace/distance as before
./compare.sh                        # new take lands in the table above
```

Use a label that names the mic (`q2u`, `q2u-4in`, `q2u-popfilter`) so the ranked
table stays readable. Same room, same distance, Mic Mode **Standard** — the point is
that the microphone is the only thing that changed.

If the first take comes back `too quiet` or `CLIPPED`, that's a gain setting, not a
verdict on the mic: adjust and take it again before drawing conclusions.
