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

## Current state & open items (2026-06-07)

**Major restructure (2026-06-07, multi-agent review + brainstorm): deck went 18 → 13 slides.** Thesis changed from a *survey* ("the industry legitimised AI agents") to a **concrete two-sided answer**: how to accelerate LOTUSim with agents = (1) the **contributor** adopts the agentic loop + responsibility (`Assisted-by`, the human signs), and (2) the **project/governance** makes LOTUSim *agent-ready* by writing the implicit down. Driving line: ***"an agent is only as good as the docs it can read."*** The 13 slides (HTML `<!-- N. -->` comments match):

1 Cover · 2 **The wall** (hook — implicit conventions, sets up the payoff) · 3 Two kinds of "agent" (mini, ~45s) · 4 Why now (closes on **the question**: *how do we handle agent-assisted contributions?* → bridges into Linux/OpenClaw as *answers*) · 5 Linux kernel · 6 OpenClaw · 7 Scenario (sonar) · 8 Pipeline relay · 9 The loop in action · 10 Demo · 11 Limits · 12 LOTUSim's homework · 13 Close.

**Narrative arc (Arc A, chosen 2026-06-07 after a 2nd brainstorm; audience = mix incl. newcomers):** open on the **wall** (shared pain), then mini-definition, then *Why now* closing on **the question** ("how do we handle agent-assisted contributions, responsibly?") so the industry block reads as *answers*, not examples. Industry proof (Linux+OpenClaw) stays **before** the LOTUSim sonar block. **Arc A IS the TEDx-agent's recommended arc** (Problem → Proof → Method → Contract). The *alternative* (industry **after** the demo, bridging into the homework) came from the orchestrator's synthesis + the audience-proxy/grill-me agents — it was **not** chosen. One clean general→LOTUSim pivot after slide 6. **Oral (not on slide):** at slide 4, drop the local cautionary case — the ~13 PRs / ~300k lines that hit LOTUSim and weren't merged (no frame; some content that shouldn't have been public) — un-named; motivates the question.

Key changes this pass:
- **Slides 5 & 6 reframed around the real artifacts** (verified by fetching the repos): kernel `coding-assistants.rst` is *addressed to agents and their users*; the safe takeaway is *"yes, under one condition: the human who signs answers for every line"* (the doc literally says **"AI agents MUST NOT add Signed-off-by"**). Slide 5 names **"the Linux kernel"** explicitly (not just "kernel"). OpenClaw leads with *what they wrote down* as clean filename-led bullets: `VISION.md` (what to build / what to refuse) + `AGENTS.md` (how to build & test in-repo). Right-column numbers = **376k stars + 56,098 commits** (the 35 KB AGENTS.md figure was tried and dropped — low value). ⚠️ **`~100 agents` + `$1.3M` are attributed to Steinberger PERSONALLY, not "the project"** (don't conflate — earlier draft did).
- **Em-dashes swept** from all visible slide text (Cyril's note: too many "—", not human). Replaced by commas/colons/periods. Kept only in CSS/JS comments, the `<title>`, and citation attributions (`— P. Steinberger`).
- **Old "Distilled principles" slide cut** (folded into 5/6 + the loop).
- **5 stage slides (MAP/PLAN/BUILD/DOC/SHIP) collapsed into ONE** slide 9 *"The loop, on the sonar"* — Cyril felt he had little to say per stage, and the **video demo is the detailed how**. Keeps two human accents: *taste* at Plan, *close-the-loop* at Build.
- **Slide 7 (sonar) honesty fix:** the agent writes the *structure* (plugin/message/zero-stub); the **acoustic model stays the engineer's**, validated before merge. (Don't claim AI replaces acousticians — they don't code anyway; their knowledge is an input, or mocked by the contributor.)
- **Slide 8 relay** kept (Cyril's sprites — untouched), footer now *"one agent, five hats — not a hundred in parallel"* (anti-FOMO; he wants to detension the parallel-agent-army hype).
- **Slide 10 demo:** the invented **≈3h timeline was removed** (Cyril: "sorti du chapeau", bothered him). Now a placeholder for a **sped-up video** (he'll record it), no fabricated numbers.
- **Slide 11 limits:** confidentiality card → *"Govern what the agent touches"* — carries an **allusion to the ~300k-line ungoverned AI PRs** that hit LOTUSim (closed unmerged; some data shouldn't have been public). Deliberately *not* named on slide; everyone gets it at half-word.
- **Slide 12 NEW "LOTUSim's homework"** (replaces old "What it changes"): a *today vs agent-ready* gap (README 1 KB / docs in a wiki / nothing for agents → AGENTS.md, in-repo VISION, docs-as-code, AI policy, guardrails). The **governance contract**, carried by Cyril as lead dev.
- **Slide 13 close:** two-column CTA — *If you contribute* / *What the project will do (my commitment)* + signature.
- Dead CSS removed (`.bignum`, `.reveal-num`, `.endgrid` — the features that used them are gone).
- Verified rendering via Playwright (13 slides, no JS errors). Speaker notes rewritten as an ESL near-script with per-slide **Say:** verbatim lines + timing budget.

Earlier baseline (commit `582839f` + logo follow-up): Naval Group white theme (`t` / `?theme=ng`), real inline NG vector cover logo.

**LOTUSim repo doc reality (inspected 2026-06-07, doc only):** `README.md` ~1 KB, decent human `CONTRIBUTING.md` (issue→label→fork→PR→review + governance committee, biannual roadmap), but **no `AGENTS.md`/`CLAUDE.md`/`VISION.md` in-repo, docs in a GitHub wiki, `docs/` holds only images, testing guide "available soon".** This gap *is* the slide-12 message.

**Audience:** talk given at the LOTUSim technical conference (Naval Group — defence/naval; LOTUSim is a multi-agent *simulator*, MAS, not AI agents). **Most attendees are external partners who will contribute to the open-sourced LOTUSim** — keep jargon low; do **not** scare them into thinking they must self-host local models (the event is about the open-source part). Slides are **English**; chat with Cyril in **French** (his preference).

**Preview:** open `index.html`, navigate `←/→`, toggle the Naval Group white theme with **`t`** (or `?theme=ng`).

**Open items:**
- **Slide 8 relay** — Cyril may still want to *add* a loop illustration on top of the sprites ("on itérera dessus pour illustrer la loop") — the relay itself stays.
- **Slide 10 demo** — sped-up **video to be recorded** by Cyril; the slide is a placeholder until then.
- **Slide 12 homework = a real commitment** — as lead dev, Cyril intends to actually add `AGENTS.md` / in-repo `VISION` / an AI-contribution policy to LOTUSim. Track as project work, not just a slide.
- **Scenario-generation use case** (business/*métier* agents, not dev agents) is deliberately out of scope — one oral nod on the Close + a Q&A answer in speaker-notes; not a slide.
- Not yet committed — propose a gitmoji commit when Cyril is happy.
