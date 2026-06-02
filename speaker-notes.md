# Speaker notes — *From idea to LOTUSim contribution, faster with AI agents*

> Talk ~15 min · LOTUSim Technical Conference · Naval Group · 02/07/2026
> Personal notes to keep in front of me during the talk. **Slides and notes both in English.**
> ⚠️ Draft — to refine / tighten / time.

**Audience:** mostly external partners who will contribute to the **open-source** part of LOTUSim; many are **not** AI-agent experts.
**Tone:** concrete, honest, zero hype. Low jargon. We're selling a method, not a product.
**Through-line:** the entry barrier of a robotics simulator can drop by an order of magnitude — without sacrificing quality.

Budget ~15 min: intro 1' · context (3-7) 4' · method (8-14) 6' · demo 2' · limits/close 2'.

---

## 1 · Cover
- Introduce myself in one line: Cyril, lead dev of LOTUSim.
- The promise of the talk: *"how well-orchestrated AI agents bring down the entry barrier of a ROS / Gazebo / Xdyn simulator."*
- Announce the format: 15 min, one method + one demo.

## 2 · Two kinds of "agents"
- Quick disambiguation, important for this room (MAS / robotics).
- In **LOTUSim**: an agent = a simulated platform (drone, ship, submarine).
- In **this talk**: an agent = *a large language model given tools* — it reads the repo, edits files, runs build/tests/git, sees the result, repeats.
- Punchline: **"the second kind of agent helps you build the first."**

## 3 · The wall
- Contributing to a robotics simulator is a wall, along 3 axes:
  - technical surface (C++, CMake, ROS, Gazebo, SDF/URDF, Xdyn),
  - physical coupling (one sensor = model + ROS message + plugin + scenario),
  - implicit conventions never written down in the README.
- Message: *"many good ideas die between 'I want to contribute' and 'my PR is ready'."*

## 4 · Why now
- Why *now* and not 18 months ago? 3 shifts in late 2025:
  - models finally reliable at tool-calling (Opus 4.5, GPT-5.2),
  - long contexts (the whole codebase + docs in one go),
  - **autonomy held by the agentic loop**: *map → build → run → test → review*, looping until green.
- Stress: what sustains a task over time is the loop, not a bigger prompt.

## 5 · The Linux kernel made the call  *(signal #1: legitimacy)*
- Even the Linux kernel — the most conservative community there is — **made the call** and published its first official AI policy (`coding-assistants.rst`).
- No ban, no evangelism. **AI = just a tool**, **full** human responsibility, `Signed-off-by` stays human.
- New `Assisted-by:` trailer (shows which agent / model / tools). Example taken verbatim from the kernel doc.

## 6 · OpenClaw  *(signal #2: scale — KEY SLIDE, ~1.5 min)*
- OpenClaw: the **fastest-growing** open-source project in GitHub history.
- Size: **376k stars**, **56k commits** in 6 months.
- Working mode: **~100 agents in parallel** that code **and review each other**, hunt for vulnerabilities, dedupe issues.
- The cost, to spell out clearly: Steinberger **alone** burned **~$1.3M of tokens in one month (April 2026)** — funded by **OpenAI** as research.
- Human guardrails: *real-behavior proof* on every PR, 28+ maintainers signing off.
- The flip side, which we own: **~600 security advisories** in 6 months → *the hidden cost of speed* (back to it on slide 16).

## 7 · What the pioneers learned
- 4 **portable** principles, independent of tool/vendor:
  - **Close the loop** — the agent compiles, runs, tests its own work.
  - **Prompt > pull request** — the quality of the request predicts the quality of the result.
  - **Architecture > code review** — the human debate moves up a level.
  - **The human signs** — no "dark factory", someone is responsible.

## 8 · Scenario — sonar sensor
- Concrete case we'll walk through: **adding a sonar sensor to an underwater platform**.
- Deliberately non-trivial: touches **the whole stack** (physics / systems / interfaces / launch / docs).
- Goal: from zero knowledge of the repo → a **PR ready to review**, in one session. *No magic, just method.*

## 9 · Five stages, five agent roles
- My method: 5 stages, 5 **specialized** agent roles (Map · Plan · Build · Doc · Ship).
- Point to the animation: one agent passes the baton to the next — *specialization = quality*.
- Make clear: *"one possible decomposition, not a doctrine — adapt it to your project."*

## 10 · Map
- Stage 1: understand the codebase in **minutes**, not days.
- The agent walks the tree, follows the `#include`s, locates the Gazebo plugins, answers *"where is AUV → ROS topic wired?"* with file:line.
- Tools: Claude Code, up-to-date Gazebo/ROS docs via context7/MCP.

## 11 · Plan  *(where "taste" lives most)*
- Stage 2: the architect **doesn't code**, it **proposes** 2-3 strategies with trade-offs, risks, debt.
- Example on screen: option A (analytical) / B (ray-cast) / C (third-party plugin).
- My human edge: **choosing** — fast, well. *That's the part that doesn't get delegated.*

## 12 · Build  *(close the loop)*
- Stage 3: what changes isn't typing speed, it's **the cycle**.
- **The agent** (not me) runs `colcon build` + the sim, reads the failure, fixes it. I steer **by exception**.
- **Local CI > remote CI**: the agent sees the failure in 12 s, not in 10 min.

## 13 · Doc
- Stage 4: document **while we still know why** (documenting "later" = never).
- Docs-as-code: same repo, same PR, same review; the agent picks up the decisions from Plan, generates a notebook example.
- Docs become a **deliverable of the session**, not debt.

## 14 · Ship  *(the human signs)*
- Stage 5: explicit LOTUSim process — *labeled issue → fork → PR → review*. The agents execute it to the letter, **I sign**.
- **Transparent** commit about the AI assistance: `Assisted-by:` + `Signed-off-by:` (format borrowed from the kernel).

## 15 · Demo
- From cloned repo to PR **in one session, ≈3 h** (real timings, estimated: 25 Map / 20 Plan / 70 Build / 25 Doc / 20 Ship).
- [LIVE or sped-up video — to decide.]
- Message: **the code is not throwaway** — readable, tested, documented, follows the repo's conventions.

## 16 · What I'm not selling you  *(honesty)*
- **Mind what's confidential** — open-source is public, sharing it with an agent is OK; caution kicks in the day the work touches **internal/classified** material → match the guard to the data. *(Don't scare anyone: no one here has to host local models to contribute to the open-source.)*
- Hallucinations (made-up Gazebo APIs) → build + tests = mandatory safety net.
- Supervision **not optional** (no "dark factory").
- **Not a substitute**: without a C++/ROS/physics foundation, the agent just lets you hit the wall faster.

## 17 · What it changes for LOTUSim
- The entry barrier drops by **an order of magnitude**.
- Contributor: *"weeks before my first contribution"* → *"a useful PR from the very first session"*.
- Project: more, better-prepared PRs → less friction in review.
- Community: profiles who wouldn't have made it over the wall (researchers, integrators, partners).
- Maintainers: the debate rises to architecture, not line-by-line.

## 18 · Close
- *"An open simulator. An augmented practice."*
- Call to action: **clone the repo · ask an agent a question · pick an issue · come back with your first PR.**
- Thanks — questions?

---

## Prep Q&A (keep in mind, not on slide)
- **Torvalds / kernel**: the quote was removed from the deck; his actual tone was more skeptical ("the AI slop issue is NOT going to be solved with documentation"). If someone cites the doc at me, own it: the doc is *"for good actors"*, it doesn't solve everything.
- **OpenClaw security**: ~600 advisories = an argument *for* close-the-loop + review, not against the approach. Speed without guardrails = security debt.
- **Defense confidentiality**: if pushed, clearly distinguish *contributing to the open-source* (OK) vs *working on internal material* (self-hosted models, context separation).
- **"Will AI replace devs?"**: no — *taste & system design remain the ultimate moats* (Steinberger). The human chooses and signs.
- **Repo**: github.com/naval-group/LOTUSim.
