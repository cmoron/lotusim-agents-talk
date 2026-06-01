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
  - Slide 2 — two `.card`s contrasting the two senses of "agent" (LOTUSim platform vs the talk's tool-using LLM), plus a centred takeaway line. (An earlier `.loopflow` Perceive→Decide→Act box was dropped 2026-06-02 as too-early; its CSS was removed.)
  - Slide 9 `.relay` — five pixel-sprite **agents** (Cartographer/Architect/Companion/Writer/Reviewer + verbs maps/plans/builds/writes/ships) that light up in cascade as a `.baton` orb arcs across (`batonRelay` 6s; `agentLight`/`agentLightFinal` — the Reviewer stays lit at the end). Sprites are generated from `data-sprite` bitmaps by `spriteToSVG()` in the IIFE (inline `<svg>` of run-length `<rect>`s). **This is Cyril's original design, restored 2026-06-02** — he's attached to it ("j'y tiens"); a clean text-pipeline rewrite (582839f) and an avatars+loop-ring variant were **both rejected. Don't replace it.** Glows use `var(--glow)` so they're theme-aware (added 2026-06-02 — the original hardcoded orange, which clashed with the NG blue theme).
  - Cover Naval Group logo — inline SVG `.ng-logo` with `.lg-primary` (wordmark) + `.lg-secondary` (accent) paths; fills switch by theme (white/blue wordmark, red accent always). Geometry came from naval-group.com's `logo.svg` sprite — keep it inline (self-contained), don't re-add a base64 PNG.
- Design tokens — CSS custom properties under `:root` (`--bg`, `--ink`, `--accent` orange `#FF5A36`, `--glow` = accent as `r,g,b` for glow shadows, fonts `--display` Instrument Serif / `--mono` JetBrains Mono). Use these instead of hardcoding colors/fonts. The `body.theme-ng` block at the end of `<style>` remaps them to the Naval Group white theme (white `--bg`, deep-navy `#061835` ink, brand blue `#164194` accent, red `#ed051d` danger, `--glow` → blue).

## Conventions

- Keep the deck a single self-contained HTML file. No bundler, no framework, no external assets beyond Google Fonts.
- Commit style: **gitmoji** (`:tada:`, `:truck:`, `:memo:`…) — not Conventional Commits. See git log for examples.
- When adding a slide, mirror the structure of a nearby `<section class="slide">` and reuse existing typography classes (`eyebrow`, `title`, `sub`, `lead`, `dim`, `hl`, `cols-2`, `card`, `stack`, …) rather than introducing new CSS.

## Fact-checking — training data is stale on these topics

The talk references events from late 2025 / early-to-mid 2026 that moved fast and on which Claude's training data is **outdated**. Before editing factual claims, **always verify on the web** (`mgrep --web --answer "..."`) — do not trust internal knowledge. Specifically:

- **Linux kernel AI-assistance policy** — adopted in 2026 (`Documentation/process/coding-assistants.rst`, `Assisted-by:` trailer). The slide source-of-truth beats any prior assumption.
- **OpenClaw / Clawbot / Clawd** — Peter Steinberger's agent, renamed several times (Clawbot → … → OpenClaw); old names in newsletter/podcast titles are expected, not bugs. Now a large *independent* open project; its creator was **hired by OpenAI** (Feb 2026 — surfaced on slide 6). Live stats (GitHub API, **2026-06-02**): **376,069** stars, **56,098** commits on the default branch (our "55k+/56k" is right; a web claim of ~11k was stale/wrong), 78,543 forks, ≈**600** published security advisories (figure on slides 6 & 16 — keep consistent; an old "1,142" was wrong). **Workflow (replaces the old "5–10 agents + human supervision"):** ≈**100 agents in parallel** (Codex / GPT-5.5) that code, **review each other's PRs**, hunt security bugs, dedupe issues — Steinberger *alone* burned ≈**$1.3M of tokens in a single month (April 2026)**: 603B tokens, 7.6M requests, "fast-mode" pricing (≈$300k without), **funded by OpenAI as research**. Human guardrails per `CONTRIBUTING.md`: every external PR needs a **"real behavior proof"** section, 20-open-PR-per-author limit, review bots (Codex) comment, **28+ human maintainers** sign off & merge; AI assistance explicitly welcome if disclosed. Sources: the-decoder.com, tomshardware.com, github.com/openclaw/openclaw. "Fastest-growing open-source project in GitHub history" is Cyril's framing, corroborated. Re-verify live stats before each talk.
- **LOTUSim** — official repo is `github.com/naval-group/LOTUSim` (confirmed by Cyril, Lead Developer, 2026-06-01; an earlier `LOTUSRobotics/LOTUSim` note was a hallucination). Naval Group hosts the **LOTUSim technical conference**; the 2026 edition is on **02/07/2026**.
- **Model versions** — latest Claude as of mid-2026 is **Opus 4.8** (`claude-opus-4-8`, released 28 May 2026). Use it in the `Assisted-by:` example on slide 14. Exception: slide 5 keeps `Claude:claude-3-opus` on purpose — that's the *literal example from the kernel doc*, not a staleness bug, so don't "upgrade" it. Slide 4's `Opus 4.5 / GPT-5.2` are also intentional: they mark the late-2025 capability break that made agentic coding viable — keep them as the historical anchor even though newer versions exist.
- **On-slide quotes** — verified 2026-06-01. The Torvalds *"The documentation is for good actors."* quote was **removed from slide 5** (2026-06-02): source fragile + his real tone was skeptical (Phoronix: *"the AI slop issue is NOT going to be solved with documentation"*). It was replaced by a non-attributed takeaway (*"the most conservative community in open source wrote the rules — rather than ban it"*). Steinberger's *"taste and system design remain the ultimate moats"* and *"close the loop…"* are corroborated. ⚠️ Gotcha: `mgrep --web` is **circular** for on-slide quotes — it matches our own `index.html` and reports it as a "source". Use the **`WebSearch`** tool for genuine external verification of anything already written in the deck.

## Current state & open items (2026-06-02)

The deck is now **18 slides** (the old "first PR" hook was removed 2026-06-02; HTML `<!-- N. -->` comments + the slide-N references in this file were renumbered to match). Slide-by-slide review pass #2 (2026-06-02, not yet committed at time of writing):
- **Slide 2** — agent defined as *"a large language model given tools: reads the repo, edits files, runs commands…"*; the Perceive→Decide→Act box was dropped (too early); closes on a centred takeaway *"the second kind of agent helps you build the first"*.
- **Slide 4** (Why now) — title → "AI agents crossed the useful threshold"; METR reference replaced by the agentic-loop wording (*map → build → run → test → review*).
- **Slide 5** (Linux kernel) — Torvalds quote removed (see Fact-checking); encart annotated as verbatim from `coding-assistants.rst`.
- **Slide 6** (OpenClaw) — reworked to current reality: 56,098 commits shown big (project size), ≈100 agents + ≈$1.3M (April 2026, Steinberger alone) in the text, human guardrails (real-behavior proof, 28+ maintainers). **Cyril still wants to review this one closely.**
- **Slide 9** (agent relay) — **restored Cyril's original pixel-sprite agent relay** (5 SVG agents lighting up in cascade as a baton passes) from git history (`05d4fbb`), after the clean-pipeline rewrite and an avatars+loop-ring variant were both rejected. Made the glows theme-aware. **Keep this design.**
- **Slide 10** (Map) — "local RAG" → context7/MCP.
- **Slide 12** (Build) — fixed so the **agent** (not the human) runs colcon/sim and closes the loop.
- **Slide 16** (limits) — security card reframed: open-source is public, caution only for internal/classified work (don't scare external OSS contributors).
- **Slide 17** (what changes) — bullets re-aligned into label|description columns; governance-committee point replaced by "for maintainers" + committee claim dropped.
- **Slide 18** (close) — signature "Cyril Moron · Lead Developer, Naval Group" + repo `github.com/naval-group/LOTUSim`.
- Dead CSS removed (`.loopflow`, `.timer-row`/`fillSlow`/`fillFast`, `blockquote`) along with the features that used them.

Earlier baseline (commit `582839f` + logo follow-up): Naval Group white theme (`t` / `?theme=ng`), real inline NG vector cover logo, slides 7 & 16 trimmed to 4 cards.

**Audience:** talk given at the LOTUSim technical conference (Naval Group — defence/naval; LOTUSim is a multi-agent *simulator*, MAS, not AI agents). **Most attendees are external partners who will contribute to the open-sourced LOTUSim** — keep jargon low; do **not** scare them into thinking they must self-host local models (the event is about the open-source part). Slides are **English**; chat with Cyril in **French** (his preference).

**Preview:** open `index.html`, navigate `←/→`, toggle the Naval Group white theme with **`t`** (or `?theme=ng`).

**Open items:**
- **Slide 9** — Cyril may later want to *add* a loop illustration on top of the restored relay ("on itérera dessus pour illustrer la loop") — but the relay itself stays.
- **Slide 15** — demo is a placeholder: **live demo vs sped-up video** still undecided (Cyril will do a video if he has time).
- Not yet committed — propose a gitmoji commit when the pass is done.
