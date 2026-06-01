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
  - Theme — `body.theme-ng` is toggled by the `t` key (or applied on load via `?theme=ng`). Everything else is plain CSS/markup (e.g. the slide-2 `.loopflow` sense→decide→act diagram, the slide-10 `.pipeline`).
- Design tokens — CSS custom properties under `:root` (`--bg`, `--ink`, `--accent` orange `#FF5A36`, fonts `--display` Instrument Serif / `--mono` JetBrains Mono). Use these instead of hardcoding colors/fonts. A `body.theme-ng` block at the end of `<style>` remaps the tokens to the Naval Group white theme (white `--bg`, deep-navy `#061835` ink, brand blue `#164194` accent, red `#ed051d` danger).

## Conventions

- Keep the deck a single self-contained HTML file. No bundler, no framework, no external assets beyond Google Fonts.
- Commit style: **gitmoji** (`:tada:`, `:truck:`, `:memo:`…) — not Conventional Commits. See git log for examples.
- When adding a slide, mirror the structure of a nearby `<section class="slide">` and reuse existing typography classes (`eyebrow`, `title`, `sub`, `lead`, `dim`, `hl`, `cols-2`, `card`, `stack`, …) rather than introducing new CSS.

## Fact-checking — training data is stale on these topics

The talk references events from late 2025 / early-to-mid 2026 that moved fast and on which Claude's training data is **outdated**. Before editing factual claims, **always verify on the web** (`mgrep --web --answer "..."`) — do not trust internal knowledge. Specifically:

- **Linux kernel AI-assistance policy** — adopted in 2026 (`Documentation/process/coding-assistants.rst`, `Assisted-by:` trailer). The slide source-of-truth beats any prior assumption.
- **OpenClaw / Clawbot / Clawd** — Peter Steinberger's agent has been renamed several times (Clawbot → … → OpenClaw). Newsletter and podcast titles may use the old name; that mismatch is expected, not a bug. Stats (stars, commits, advisories) should be verified directly against GitHub when possible.
- **LOTUSim** — official repo is `github.com/LOTUSRobotics/LOTUSim` (the README is currently wrong — the slide deck wins). Naval Group hosts the **LOTUSim technical conference**; the 2026 edition is on **02/07/2026**.
- **Model versions** — latest Claude as of mid-2026 is **Opus 4.8** (`claude-opus-4-8`, released 28 May 2026). Use it in the `Assisted-by:` example on slide 15. Exception: slide 6 keeps `Claude:claude-3-opus` on purpose — that's the *literal example from the kernel doc*, not a staleness bug, so don't "upgrade" it. Slide 5's `Opus 4.5 / GPT-5.2` are also intentional: they mark the late-2025 capability break that made agentic coding viable — keep them as the historical anchor even though newer versions exist.
