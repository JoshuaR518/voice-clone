# Recording sessions — marketing VO register

Target: **2 hours total** of QC-passing audio for the Professional clone.
Preferred shape: **6 sessions × 20–25 min** across a week. One-day sprint alternative:
4 × 30 min with 30+ minute breaks.

The model learns **delivery**, not just timbre. Everything here is in the register you
actually want out: clear, energetic, persuasive. Read it the way you'd want it played back.

---

## Before every session — 60 seconds

1. `~/Downloads/voice-clone/devices.sh` — confirm the Q2U's index (it moves).
2. Mic **4–6 inches**, slightly **off-axis** (talk past it, not into it), pop filter between.
3. Mic Mode **Standard** — never Voice Isolation.
4. Kill HVAC, fridge, fans.
5. Test take, 15 seconds: `record.sh <idx> warmup 15` — check it reports `>> Usable for cloning.`

**Do not start the real take until the warm-up passes QC.** Five wasted seconds beats
25 wasted minutes.

---

## Session template (20–25 min)

| Minutes | What |
|---|---|
| 0–2 | Warm-up take, discard. Gets your voice and the levels settled. |
| 2–8 | **Your own Cijara copy** — highest-value material |
| 8–13 | **Energetic pitch** register |
| 13–18 | **Calm explainer** register |
| 18–21 | **CTAs and numbers** |
| 21–25 | Free speech — talk about the business unscripted |

Take a real breath between blocks. Do **not** record the breaks — long silences hurt.

---

## Where the material comes from

**Roughly 60% should be your own copy.** Real vocabulary, real product names, real cadence —
nothing synthetic matches it. Pull from:

- Cijara website and service descriptions
- Past video scripts or ad copy
- Proposals and client-facing decks
- Email templates you send often

**The other 40%** is the register practice below. Reread passages across sessions — repetition
with natural variation is *useful* training data, not waste.

---

## Register 1 — Energetic pitch

High energy, forward momentum, shorter sentences. This is your opening-30-seconds voice.

> Here's the problem. You're spending hours every week on work that should take minutes.
> Files in the wrong folders. Documents you can't find. Systems that don't talk to each other.
> And every hour lost there is an hour not spent on the work that actually grows the business.
> That's what we fix. Not with another tool you have to learn — with systems that just work,
> quietly, in the background, so you stop thinking about them entirely.

> Most teams don't have a technology problem. They have a *time* problem, and technology is
> where the time is going. We come in, we look at how you actually work, and we take the
> friction out. No jargon. No six-month rollout. Just faster, starting now.

---

## Register 2 — Calm explainer

Steadier, slightly lower, unhurried. This is your "let me walk you through it" voice.

> Let's talk about how this actually works. The first step is a conversation — we look at your
> current setup, what's working, and where things slow down. That usually takes about an hour.
> From there, we map out what a better version looks like, and we're specific about it: what
> changes, what it costs, and how long it takes. You'll know exactly what you're getting
> before anything begins.

> The thing people are usually surprised by is how much of this is already possible with tools
> they own. Often we're not adding anything new at all. We're connecting what's already there
> so it stops requiring you to hold it together manually. That's usually where the biggest
> gains come from, and it's usually the least expensive place to start.

---

## Register 3 — Direct address and CTA

Short, punchy, imperative. Land the ends of sentences cleanly — don't trail off.

> Ready to get started? Book a call. Fifteen minutes, no obligation.
> Let's talk about what's slowing you down.
> Send us a message and we'll get back to you the same day.
> Visit the site. Take a look. See if it fits.
> If you're tired of doing this the hard way — let's fix it.
> Get in touch today.

Read this block **three times**: once conversational, once with more push, once slower
and warmer. The model benefits from the range.

---

## Register 4 — Numbers, names, and specifics

**Do not skip this.** Clones handle numbers, URLs, and email addresses badly when never
trained on them — and marketing copy is full of them.

> Plans start at forty-nine dollars a month. The standard package is two hundred and fifty.
> We've worked with over sixty businesses since twenty twenty-one.
> Response time averages under four hours. Setup takes three to five business days.
> That's a thirty percent reduction in time spent on admin — sometimes closer to fifty.
> You can reach us at cijaragroup at gmail dot com.
> Find us online at cijara group dot com.
> Call us Monday through Friday, nine to five.
> The offer runs through March thirty-first.

Read numbers **the way you'd say them aloud**, not as digits.

---

## Register 5 — Unscripted

Five minutes at the end of each session, no script. Talk about what you do, a client
problem you solved, why you started the business. Natural speech has hesitations and rhythm
that read scripts never produce, and it's some of the most valuable material in the set.

Keep it clean — no long pauses, no thinking out loud in silence. If you lose the thread,
stop the take and start a new one.

---

## Rules that matter more than the words

- **Same mic position every session.** This is what the boom arm is for.
- **Same energy.** A tired session teaches the model a tired voice. Stop if you're flagging.
- **Same room, ideally same time of day.**
- **One speaker.** No one else audible, no TV, no music.
- **No long silences.** Stop the take instead.
- **Run `qc.sh` after every take.** Discard failures immediately — don't "fix it later."

---

## Tracking progress

```bash
~/Downloads/voice-clone/compare.sh
```

Every session's take should show peak −6 to −3, SNR ≥45, HFGAP ≤30.
Sum the MIN column — you're aiming for **120 minutes** of passing audio.

When you hit it, upload only the passing takes and create the Professional clone in the
ElevenLabs web UI (it requires identity verification the API doesn't expose).

---

## Session checklist

- [ ] Session 1 — 20–25 min
- [ ] Session 2 — 20–25 min
- [ ] Session 3 — 20–25 min
- [ ] Session 4 — 20–25 min
- [ ] Session 5 — 20–25 min
- [ ] Session 6 — 20–25 min
- [ ] `compare.sh` total ≥ 120 min passing
- [ ] Upload + verification
- [ ] PVC trained
- [ ] Three-way A/B vs both instant clones
