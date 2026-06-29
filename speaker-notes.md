# Speaker notes — _From idea to LOTUSim contribution, faster with AI agents_

> Talk ~15 min · LOTUSim Technical Conference · Naval Group · 2 July 2026
> Notes to keep in front of me. **Slides and notes both in English.**
> I'm not a native English speaker → these notes are a near-script. Short sentences. The **Say:** lines are meant to be spoken almost word for word.
> **12 slides** — the Linux kernel and OpenClaw share one slide (slide 5). Numbers below match the deck.

**Audience:** external partners — many are **developers** (my community), some are simulation engineers. Few are AI-agent experts.
**Tone:** concrete, honest, zero hype. We sell a **method** and name the **homework**, not a product.
**Two targets, one through-line:** the _contributor_ adopts the loop; the _project_ makes itself agent-ready. An agent is only as good as the docs it can read.

**Budget (~15-16 min):**
1 Cover 0:45 · 2 Wall 1:00 · 3 Agents 0:45 · 4 Why now 1:15 · 5 Industry (Linux + OpenClaw) 2:30 · 6 Scenario 1:00 · 7 Relay 0:45 · 8 Loop 2:00 · 9 Demo 2:30 · 10 Limits 1:15 · 11 Almost agent-ready 1:30 · 12 Close 1:00

**Arc (Acte 1 problem → Acte 2 proof → Acte 3 method → Acte 4 contract):** open on the wall, drop the "plan" line on slide 4, keep the industry proof (Linux + OpenClaw, one slide) before the LOTUSim sailboat block, finish on the two contracts.

---

## 1 · Cover _(0:45)_

- One line about me: _"I'm Cyril, lead developer at Naval Group — but I come to LOTUSim as a contributor, from another team, like you. Not part of its team."_
- **Say:** _"In the next fifteen minutes: how AI agents bring down the entry barrier of a ROS / Gazebo / Xdyn simulator — and what the project can do in return."_
- Announce: _"A method, a demo, and some homework — for the project."_

## 2 · The wall _(1:00)_ — open here, this is the hook

- Opening beat. The wall is a _shared pain_: name it, let the room nod (insiders and newcomers alike).
- **Say:** _"If you've ever contributed to a robotics simulator, you know this wall."_
- Three axes:
  - technical surface (C++, CMake, ROS, Gazebo, Xdyn),
  - physical coupling (one sensor = model + ROS message + plugin + scenario),
  - **implicit conventions, never written down.** ← remember this, it pays off on slide 11.
- **Say:** _"Many good ideas die between 'I want to contribute' and 'my PR is ready'."_

## 3 · Two kinds of "agent" _(0:45)_ — keep it short

- Quick disambiguation, important in this room. Under a minute.
- In **LOTUSim**: an agent is a simulated platform, _an aerial drone, a surface ship, an underwater vehicle._ (our own README wording)
- In **this talk**: an agent is _a large language model given tools_: it reads the repo, edits files, runs build / tests / git, sees the result, and tries again.
- **Say (verbatim):** _"The second kind of agent helps you build the first."_

## 4 · Why now _(1:15)_

- Why now and not 18 months ago? Three shifts, late 2025:
  - models reliable at **tool-calling**,
  - **long context**, the whole codebase fits,
  - **the agentic loop**: map → build → run → test → review, until green.
- **Say:** _"What holds a task together over hours is not a bigger prompt. It's the loop."_
- Point at the terminal once, don't read it. (It now reads _"propose 2 ways to add an RC sailboat to LOTUSim"_ — the same case we walk through later.)
- **Bridge to the industry block (verbatim):** _"Once an agent can write code, a question follows: how do we handle agent-assisted contributions, responsibly?"_ → gives slide 5 a purpose (the two answers, not examples).
- **Oral, place the local case HERE (do NOT put on slide):** mention the ~13 PRs / ~300k lines that landed on LOTUSim and were **not** merged — agent-assisted contributions with no frame, and some content that shouldn't have been public. Don't name anyone; the room will understand at half-word. _"We've already seen, here, what this looks like without a frame."_ → that's exactly why the question matters for us, and it sets up Linux (the rules) + OpenClaw (the practice).

## 5 · Industry — two answers _(2:30)_ — the question got answered, two communities on ONE slide

- The slide is **two columns**: the Linux kernel (left), OpenClaw (right). Point left, then right. Walk it, don't rush.
- **Left — the Linux kernel.** Name it explicitly: _"The most conservative community in open source took the time to think, and answered."_
  - Key fact: the doc is **addressed to the agents and to the people who run them** (`coding-assistants.rst`).
  - The rule that does not move: **"AI agents MUST NOT add Signed-off-by"** — only a human certifies the DCO.
  - **Say (verbatim, safe):** _"Their answer was yes — under one condition: the human who signs answers for every line."_
  - ⚠️ Do NOT say "open source said yes to AI" flat — Torvalds himself said docs don't fix slop. Accountability does. If pushed, see Q&A.
- **Right — OpenClaw.** _"The opposite temperament: the fastest-growing open-source project in GitHub history, built agent-first."_
  - The real point FIRST: _"It runs on what they wrote down for the agents: a VISION file (what to build, what to refuse) and an AGENTS file (how to build and test in the repo)."_
  - Human guardrails: _"every PR needs real-behavior proof, and a human signs the merge."_
  - The scale, as an aside and **attributed to Steinberger personally** (NOT the project, don't conflate): _"Steinberger himself runs around a hundred agents in parallel, about 1.3 million dollars of tokens in one month, funded by OpenAI."_
  - If asked about the $1.3M: that's "fast-mode" pricing; without it, closer to $300k. Still OpenAI-funded research.
  - Context (off-slide): Steinberger was acqui-hired by OpenAI (Feb 2026); OpenClaw now lives in a foundation OpenAI supports. See Q&A if challenged on neutrality.
- **Close the slide — the through-line for both:** _"A hundred agents, and the human is still the bottleneck, on purpose."_
- **Say (verbatim, seed for slide 11):** _"An agent is only as good as the docs and the rules you give it."_
- **Bridge to LOTUSim (verbatim):** _"Let me show you the same discipline on a real LOTUSim feature."_
- **Stats refresh J-1:** the slide shows `376k ★` as a tag; re-sample stars and recount maintainers before 2 July (training data is stale on OpenClaw — verify on the web, see CLAUDE.md).

## 6 · Scenario — the sailboat _(1:00)_

- The concrete case (the real thing we built, not a hypothetical): **add a small RC sailboat that rounds a race buoy.** Touches the whole stack: physics, the engine, the model + mesh, a scenario, the docs.
- **Be honest about the physics (important for the engineers in the room):**
- **Say (verbatim):** _"The agent writes the structure: the model skeleton, the engine glue, the scenario. It even gives you a model that runs — but a model that runs isn't a model true to the real boat. The hydro/aero model stays yours — you plug it in, and it's validated before merge."_
- Goal: from zero knowledge of the repo to a PR ready to review, in one session.
- (The deck used to use a hypothetical _sonar sensor_ here; we pivoted to the sailboat — the feature actually built for the demo. If anyone saw an older deck, that's why.)

## 7 · Relay — five roles _(0:45)_

- Point at the animation, let it play. Don't over-explain.
- **Say (verbatim, anti-FOMO):** _"Several agents, sometimes in parallel — a few just to map the repo. But it's not the count that matters: it's the roles, the sequence, and the human who signs."_
- (Honest to our own demo: we did pop several agents, parallel even for the map. The slide footer matches this — don't claim "one agent".)
- _"One possible breakdown — adapt it to your project."_ Then move on quickly.

## 8 · The loop, on the sailboat _(2:00)_ — main "how" slide

- Walk the left column top to bottom, one short line each: Map · Plan · Build · Doc · Ship.
- Land the **two human moments** clearly:
  - at **Plan**: _"It proposes two or three options. I choose. That's the part that doesn't get delegated — taste and system design."_
  - at **Build**: _"The agent runs colcon and the sim, reads the failure, fixes it. It closes the loop itself. Local CI beats remote CI — seconds, not minutes."_
- Point at the terminal during Build (it's the proof).
- **The engine-bug beat — ORAL ONLY, not on the slide** (decision 2026-06-25). This is the strongest illustration of _map_ + _the loop_; use it if you have time, it lands hard. **First thing to cut if you're running long.**
  - **Say:** _"And there's more. While wiring the boat, the agent went down into the C++ engine and found a real bug — a quaternion read the wrong way. A pure change of heading came back as a roll. Invisible on a boat going straight; our turning sailboat made it surface. It characterised it, fixed it, and wrote a regression test."_
  - **The point:** _"That's the power of the loop — map an unknown engine, and close the loop on a real fix."_ (Map = it cartographed code it had never seen; Loop = found → fixed → tested, on its own, the human signs.)
  - Full detail for Q&A below. Don't over-tell it on stage — one breath, then move on.
- The on-slide quote uses "moats" — rare word; gloss it if faces go blank: _"moats — the things a machine can't easily replace."_
- **Say (verbatim):** _"The code is yours — readable, and you can defend every line."_

## 9 · Demo — video _(2:30)_

- This is my breather. Let the video play (mostly sped up, back to real time on the key moments); say little. The video = the full session, ending on the sailboat rounding the buoy in LOTUSim.
- Before: _"From a cloned repo to a sailboat rounding a buoy — let me show you the demo, sped up."_
- **Say (verbatim, before the video — this is the credibility beat):** _"This was recorded on LOTUSim exactly as it is today. No AGENTS.md, no prepared context. Keep that in mind for the homework slide."_
- After: _"The code isn't disposable. It's readable, tested, documented, and it follows the repo's conventions."_
- ⚠️ No invented numbers. The video is the evidence. (If the video isn't ready: say "a recorded session" and describe the five steps in one sentence each.)
- ⚠️ PREP CHECK: filming is **done** — the full session was recorded (several takes). Remaining: **edit to ~2–3 min** (most of it sped up, back to 1× on the key moments — the map finding the analog, the engine-bug fix, the boat rounding the buoy, the PR), then **embed it into slide 9** (replace the empty player frame) before the talk. The contribution itself is **shipped**: 6 signed PRs are live on the `cmoron-lab` forks (Assisted-by + I sign) — usable if anyone asks "was this real?". See `docs/demo-sailboat.md`.

## 10 · Limits — what I'm not selling _(1:15)_

- Four honest cards. Go fast, one line each.
- **Govern what the agent touches:** open-source LOTUSim is public — fine. The real risk: _"without clear rules, an agent can pull in something that shouldn't land in a public repo."_ (everyone will understand the reference — leave it there, don't elaborate)
- **Hallucinations:** _"it sometimes invents a Gazebo API that doesn't exist — build and tests are the safety net."_
- **Supervision is not optional** — supervise it like a junior dev. No "dark factory".
- **Software wall ≠ domain wall** (the lesson the sailboat taught us). **Two levels — be precise, it's what wins the engineers:** (1) the agent + **Xdyn standalone** go far — a valid, _stable_, plausible model, it can even measure a **speed polar** in Xdyn alone (no Gazebo, no Unity); that's the software wall. (2) the domain wall = making the coefficients (added mass, damping, sail polars) **true to the real Focus V2**: no agent runs the **towing-tank** campaign — that's the tank, CFD, and our hydrodynamicists at **Sirehna** (who also wrote Xdyn).
  - **Say:** _"AI drops the software wall in hours — install, launch, a first feature, even a model that runs in Xdyn. But a model that runs isn't a model true to the real boat. And no AI agent runs the towing-tank tests for you — the true hydro and aero come from the tank and CFD, the craft of our hydrodynamicists at Sirehna. Without that, the agent just gets you to that wall faster."_
  - Ties straight back to the slide-6 honesty beat (the physics model stays the engineer's).

## 11 · LOTUSim is almost agent-ready _(1:30)_ — the governance message, stay POSITIVE (we work for LOTUSim)

- ⚠️ Reframed 2026-06-28: NOT "today it's broken → here's the homework". It's _"already very usable, proven by the demo, and the rest is mostly under way."_ Go easy on the project.
- **Left = what already works** (the demo proved it): from a cloned repo, **no special setup**, the agent **mapped the project on its own** and produced a **working PR**; there are **already enough docs to get started**.
- **Right = what completes it**, with status pills (most are in motion):
  - **VISION.md** — _being finalized by the project team_ (governance).
  - **AI-contribution policy** — _publishing soon_.
  - **lotusim-developer skill** — _ready to share_ (we built it during the first-PR exercise).
  - **AGENTS.md** — _to add_ (genuinely missing).
  - **Docs-as-code + test suite + local CI** — _to add_.
- **Say:** _"This isn't only on you. The project has homework too — and LOTUSim is already very close. On the left, what already works, you just saw it in the demo. On the right, what completes it — and a lot of it is already on the way."_
- **Say (verbatim, ties back to slide 2):** _"The wall I started with — the implicit conventions — is exactly what these files write down. Lower it for humans, and you lower it for agents too."_
- **Close:** _"Not fully agent-ready yet. But already very usable. And the rest is mostly under way."_
- (SECURITY.md is no longer a slide item — keep it for Q&A only if the OpenClaw-CVE question comes up.)

## 12 · Close _(1:00)_

- **Say (verbatim):** _"An open simulator. An augmented practice."_
- Two columns: _"If you contribute"_ (clone, ask an agent, pick an issue, PR with Assisted-by — you sign) / _"What the project will do"_ (an AGENTS file, the VISION in the repo, a clear AI policy, **and the developer skill we already built** — **what I'll push for and contribute myself**, as a Naval Group developer; I'm not the LOTUSim maintainer, so frame it as a contribution + a call, not a unilateral roadmap).
- One forward nod for the obvious question: _"And yes — agents can also generate simulation scenarios. That's business-typed agents, a different talk. Happy to discuss it after."_
- _"Thank you. Questions?"_

---

## Prep Q&A — the hard ones (keep in mind, not on slide)

- **"Tell me more about that engine bug."** → It was a quaternion serialization bug in the co-simulation bridge: the state coming back from Xdyn had two axes swapped (j/k), so a pure yaw came back as roll. Vessels going straight masked it; the turning sailboat surfaced it. The agent mapped the C++ it had never seen, characterised the bug, fixed it (two lines), and wrote a **regression test** — _that's_ the loop and the "real-behavior proof". The fix is a separate, self-contained engine PR; **I sign it** — as the contributor, I answer for every line. (This is oral; it's not on a slide on purpose.)
- **"How do you know the agent's code is any good?"** → Best proof: on this very feature it found and fixed a real bug _in our own engine_, with a test. Plus: build + tests are the net, and the human signs every line.
- **"En reprenant generic-scenario, un humain n'allait-il pas aussi vite ?"** → Trois temps. **(1) Le map EST le gain** : « reprendre generic-scenario » suppose de _savoir_ qu'il existe et d'en maîtriser l'archi (le pattern `lrauv_propeller`, le format `vessel_cmd_array`, la répartition core/scenario, le piège co-sim). Pour un contributeur entrant — l'audience — c'est le mur ; l'agent l'a cartographié en minutes. **(2) Pas une copie** : `lrauv_propeller` = thruster en boucle ouverte ; le voilier a exigé des **control surfaces à angle** (que le _moteur_ ne gérait pas → patch `<control_surfaces>`), une **boucle fermée** sur le cap de route, et en route le fix du **bug quaternion** du moteur — rien de ça n'était dans generic-scenario. **(3) Retournement** : si un connaisseur de generic-scenario va vite, c'est la _preuve_ que la structure est bonne — exactement la slide 11 : une bonne structure abaisse le mur pour les humains _et_ les agents. _« An agent is only as good as the docs it can read. »_
- **"Cost / licence / can it even run behind the Naval Group proxy?"** → Honest: depends on your setup; the workflow is tool-agnostic. For open-source LOTUSim there's no requirement to self-host. Don't oversell.
- **"Classified / sensitive data?"** → Clear line: contributing to the **open-source** part = fine. Internal/classified work = match the safeguard to the data (context separation, self-hosted models). This is exactly why the project needs written rules on what agents may touch.
- **"Sovereignty — depending on a US model vendor, for defence?"** → Legitimate. The _method_ (the loop, Assisted-by, the human signs, doc-as-code) is portable across vendors and works with self-hosted models. Name it openly.
- **"Won't this flood maintainers with AI PRs?"** → That's the failure mode without governance. The guardrails are the answer: one PR = one topic, real-behavior proof, Assisted-by, a human signs the merge. Recipe from the kernel and OpenClaw, sized for LOTUSim.
- **"The ~300k-line AI PRs that caused a mess here?"** → Don't name it. _"Exactly the kind of thing that happens without clear rules for agents — which is why the homework matters."_
- **"Who's responsible if the agent's PR breaks prod?"** → The human who signed. DCO. No ambiguity.
- **"Reproducibility — same prompt, different result?"** → True; that's why the loop ends on build + tests, not on the prompt. We review the result, not the run.
- **"Is 'the human signs' a fiction if they don't understand the code?"** → The agent **accelerates** understanding, it doesn't replace it. You read everything, you sign what you can defend.
- **"Will AI replace engineers?"** → No. _Taste and system design remain the moats_ (Steinberger). And the domain physics still needs a naval engineer — the agent gets you to that wall faster, it doesn't climb it for you. The human chooses and signs.
- **"So the agent can't do the physics at all?"** → It does more than people think: it writes a valid, _stable_ Xdyn model and can measure a **speed polar in Xdyn standalone** — no Gazebo, no Unity. What it can't do: **no agent runs the towing-tank tests** that make the coefficients **true to the real vessel** — that's the tank, CFD, and our hydrodynamicists at **Sirehna** (who also develop Xdyn). Two levels: a model that _runs_ vs a model that's _true_.
- **"Was the demo on a prepped repo?"** → No. _"The repo exactly as it is today — no AGENTS.md, no prepared context. With the homework done, the same session gets faster and safer. That's the point."_
- **"OpenClaw belongs to OpenAI now — is it a neutral example?"** → Acqui-hire, Feb 2026; the project lives in a foundation OpenAI supports. The governance artifacts (VISION.md, AGENTS.md, real-behavior proof) are public, verifiable, and predate the deal. The lesson stands.
- **"OpenClaw's security record? (150+ CVEs in months)"** → Yes, and that's the cautionary half of the lesson: governance must precede scale, not chase it. It's exactly why SECURITY.md is on our homework list before the agents arrive.
- **"Does the agent set up my ROS/Gazebo environment too?"** → No. The agent writes and verifies code; the environment is yours to install. A reproducible dev setup (container) is part of making the repo agent-ready — fair candidate for the homework list.
- **Repo:** github.com/naval-group/LOTUSim.
