# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Single-file slide deck for a talk titled *"From idea to LOTUSim contribution — faster with AI agents"*. Served by GitHub Pages from `main` at the repo root on each push — no build, no CI, no dependencies.

## Run locally

```bash
python -m http.server 8000   # then open http://localhost:8000
```

Or open `index.html` directly in a browser.

## Architecture

Everything lives in `index.html` (~1300 lines): CSS in `<style>`, slides as `<section class="slide">`, navigation logic in the trailing `<script>` IIFE.

- Slides — each `<section class="slide">` under `#deck`. The first carries `is-active`; the script toggles that class on the current slide.
- Counter — `#counter` shows `NN / total` and the script reads `slides.length`, so adding/removing a `<section>` updates the count automatically. Don't hardcode totals elsewhere.
- Navigation — keyboard (`→`/`Space`/`PageDown`, `←`/`PageUp`, `Home`/`End`, `f` for fullscreen, `t` to toggle the Naval Group white theme) and click-to-advance on the deck (anchors/buttons/inputs excluded). URL hash `#N` deep-links to slide N.
- Dynamic helpers in the IIFE:
  - `.countup` elements animate from 0 to `data-target` (with optional `data-suffix`, `data-format="comma"`) when their slide activates.
  - `.cols-2` / `.cols-3` children with class `card` get a staggered `--card-delay` CSS variable (0.15s + 0.09s × index).
  - Theme — `body.theme-ng` is toggled by the `t` key (or applied on load via `?theme=ng`).
- Key visual components (plain CSS/markup, no JS):
  - Slide 2 `.loopflow` — the sense→decide→act agent definition (Perceive → Decide → Act + feedback).
  - Slide 10 `.pipeline` — Map → Plan → Build → Doc → Ship stages, with a `.baton` relay animation (an orb runs across and each `.stage` glows as it passes; `.st-final` stays accented). This replaced the old pixel-sprite/agent relay.
  - Cover Naval Group logo — inline SVG `.ng-logo` with `.lg-primary` (wordmark) + `.lg-secondary` (accent) paths; fills switch by theme (white/blue wordmark, red accent always). Geometry came from naval-group.com's `logo.svg` sprite — keep it inline (self-contained), don't re-add a base64 PNG.
- Design tokens — CSS custom properties under `:root` (`--bg`, `--ink`, `--accent` orange `#FF5A36`, `--glow` = accent as `r,g,b` for glow shadows, fonts `--display` Instrument Serif / `--mono` JetBrains Mono). Use these instead of hardcoding colors/fonts. The `body.theme-ng` block at the end of `<style>` remaps them to the Naval Group white theme (white `--bg`, deep-navy `#061835` ink, brand blue `#164194` accent, red `#ed051d` danger, `--glow` → blue).

## Conventions

- Keep the deck a single self-contained HTML file. No bundler, no framework, no external assets beyond Google Fonts.
- Commit style: **gitmoji** (`:tada:`, `:truck:`, `:memo:`…) — not Conventional Commits. See git log for examples.
- When adding a slide, mirror the structure of a nearby `<section class="slide">` and reuse existing typography classes (`eyebrow`, `title`, `sub`, `lead`, `dim`, `hl`, `cols-2`, `card`, `stack`, …) rather than introducing new CSS.

## Fact-checking — training data is stale on these topics

The talk references events from late 2025 / early-to-mid 2026 that moved fast and on which Claude's training data is **outdated**. Before editing factual claims, **always verify on the web** (`mgrep --web --answer "..."`) — do not trust internal knowledge. Specifically:

- **Linux kernel AI-assistance policy** — adopted in 2026 (`Documentation/process/coding-assistants.rst`, `Assisted-by:` trailer). The slide source-of-truth beats any prior assumption.
- **OpenClaw / Clawbot / Clawd** — Peter Steinberger's agent, renamed several times (Clawbot → … → OpenClaw); old names in newsletter/podcast titles are expected, not bugs. Now a large *independent* open project; its creator was **hired by OpenAI** (confirmed across sources — optional to surface on slide 7). Verified stats as of **2026-06-01**: ≈**376k** stars, ≈**55k** commits, ≈**600** published security advisories (this is the figure on slides 7 & 17 — keep them consistent; an old "1,142" was wrong). "Fastest-growing open-source project in GitHub history" is Cyril's framing and is corroborated by sources. Re-verify the live stats against GitHub before each talk.
- **LOTUSim** — official repo is `github.com/LOTUSRobotics/LOTUSim` (the README is currently wrong — the slide deck wins). Naval Group hosts the **LOTUSim technical conference**; the 2026 edition is on **02/07/2026**.
- **Model versions** — latest Claude as of mid-2026 is **Opus 4.8** (`claude-opus-4-8`, released 28 May 2026). Use it in the `Assisted-by:` example on slide 15. Exception: slide 6 keeps `Claude:claude-3-opus` on purpose — that's the *literal example from the kernel doc*, not a staleness bug, so don't "upgrade" it. Slide 5's `Opus 4.5 / GPT-5.2` are also intentional: they mark the late-2025 capability break that made agentic coding viable — keep them as the historical anchor even though newer versions exist.
- **On-slide quotes** — verified 2026-06-01. Torvalds *"The documentation is for good actors."* is verbatim-accurate, **but** the fuller line is *"…and pretending anything else is pointless posturing"* and his real tone was skeptical (Phoronix: *"the AI slop issue is NOT going to be solved with documentation"*) — worth knowing for Q&A. Steinberger's *"taste and system design remain the ultimate moats"* and *"close the loop…"* are corroborated. ⚠️ Gotcha: `mgrep --web` is **circular** for on-slide quotes — it matches our own `index.html` and reports it as a "source". Use the **`WebSearch`** tool for genuine external verification of anything already written in the deck.

## Current state & open items (2026-06-01)

A full review pass landed in commit `582839f` (`:lipstick: rework deck…`), plus a follow-up for the real vector logo:
- Slide 2 — AI agent redefined as a **sense → decide → act** loop (dropped "LLM + harness" jargon; bridges to the MAS/robotics audience).
- Slide 10 — pixel-sprite relay replaced by the **Map→Plan→Build→Doc→Ship** `.pipeline`; the baton/glow relay animation was kept (pixel characters intentionally dropped — restore on request).
- Facts refreshed (see Fact-checking above); the old "1,142 advisories" contradiction removed.
- Slides 8 & 17 trimmed 6→4 cards; security/confidentiality elevated; single-row slides (8/10/17) vertically centred.
- Naval Group white theme added; dead sprite/baton/relay infra removed; cover logo is now the real inline NG vector.

**Audience:** talk given at the LOTUSim technical conference (Naval Group — defence/naval; LOTUSim is a multi-agent *simulator*, MAS, not AI agents). Many attendees are **not** AI-agent experts — keep jargon low and lean into the security/confidentiality angle. Slides are **English**; chat with Cyril in **French** (his preference).

**Preview:** open `index.html`, navigate `←/→`, toggle the Naval Group white theme with **`t`** (or `?theme=ng`).

**Open items for the slide-by-slide pass:**
- Slide 6 — Torvalds quote: decide whether to acknowledge its more-skeptical real context.
- Slide 7 — optionally add "creator since hired by OpenAI".
- Slide 16 — demo is a placeholder: **live demo vs sped-up video** still undecided.
- Slide 19 — fill the `@handle` placeholder.
