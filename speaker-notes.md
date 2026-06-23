# Speaker notes — *From idea to LOTUSim contribution, faster with AI agents*

> Talk ~15 min · LOTUSim Technical Conference · Naval Group · 2 July 2026
> Notes to keep in front of me. **Slides and notes both in English.**
> I'm not a native English speaker → these notes are a near-script. Short sentences. The **Say:** lines are meant to be spoken almost word for word.

**Audience:** external partners — many are **developers** (my community), some are simulation engineers. Few are AI-agent experts.
**Tone:** concrete, honest, zero hype. We sell a **method** and name the **homework**, not a product.
**Two targets, one through-line:** the *contributor* adopts the loop; the *project* makes itself agent-ready. An agent is only as good as the docs it can read.

**Budget (~15-16 min):**
1 Cover 0:45 · 2 Wall 1:00 · 3 Agents 0:45 · 4 Why now 1:15 · 5 Linux 1:15 · 6 OpenClaw 1:30 · 7 Scenario 1:00 · 8 Relay 0:45 · 9 Loop 2:00 · 10 Demo 2:00 · 11 Limits 1:15 · 12 Homework 1:30 · 13 Close 1:00

**Arc (Acte 1 problem → Acte 2 proof → Acte 3 method → Acte 4 contract):** open on the wall, drop the "plan" line on slide 4, keep the industry proof (Linux+OpenClaw) before the LOTUSim sonar block, finish on the two contracts.

---

## 1 · Cover  *(0:45)*
- One line about me: *"I'm Cyril, lead developer of LOTUSim."*
- **Say:** *"In the next fifteen minutes: how AI agents bring down the entry barrier of a ROS / Gazebo / Xdyn simulator — and what the project has to do in return."*
- Announce: *"One method, one demo, and some homework — including mine."*

## 2 · The wall  *(1:00)* — open here, this is the hook
- Opening beat. The wall is a *shared pain*: name it, let the room nod (insiders and newcomers alike).
- **Say:** *"If you've ever contributed to a robotics simulator, you know this wall."*
- Three axes:
  - technical surface (C++, CMake, ROS, Gazebo, Xdyn),
  - physical coupling (one sensor = model + ROS message + plugin + scenario),
  - **implicit conventions, never written down.** ← remember this, it pays off on slide 12.
- **Say:** *"Many good ideas die between 'I want to contribute' and 'my PR is ready'."*

## 3 · Two kinds of "agent"  *(0:45)* — keep it short
- Quick disambiguation, important in this room. Under a minute.
- In **LOTUSim**: an agent is a simulated platform, *an aerial drone, a surface ship, an underwater vehicle.* (our own README wording)
- In **this talk**: an agent is *a large language model given tools*: it reads the repo, edits files, runs build / tests / git, sees the result, and tries again.
- **Say (verbatim):** *"The second kind of agent helps you build the first."*

## 4 · Why now  *(1:15)*
- Why now and not 18 months ago? Three shifts, late 2025:
  - models reliable at **tool-calling**,
  - **long context**, the whole codebase fits,
  - **the agentic loop**: map → build → run → test → review, until green.
- **Say:** *"What holds a task together over hours is not a bigger prompt. It's the loop."*
- Point at the terminal once, don't read it.
- **Bridge to the industry block (verbatim):** *"Once an agent can write code, a question follows: how do we handle agent-assisted contributions, responsibly?"* → gives slides 5-6 a purpose (they're *answers*, not examples).
- **Oral, place the local case HERE (do NOT put on slide):** mention the ~13 PRs / ~300k lines that landed on LOTUSim and were **not** merged — agent-assisted contributions with no frame, and some content that shouldn't have been public. Don't name anyone; the room will understand at half-word. *"We've already seen, here, what this looks like without a frame."* → that's exactly why the question matters for us, and it sets up Linux (the rules) + OpenClaw (the practice).

## 5 · The Linux kernel  *(1:15)* — the question got answered
- Name it explicitly (not just "the kernel"): *"The Linux kernel, the most conservative community in open source, took the time to think, and answered."*
- Key fact: the doc is **addressed to the agents and to the people who run them** (`coding-assistants.rst`).
- The rule that does not move: **"AI agents MUST NOT add Signed-off-by"** — only a human certifies the DCO.
- **Say (verbatim, safe):** *"Their answer was yes — under one condition: the human who signs answers for every line."*
- If the on-screen example looks old (`claude-3-opus`): it's the doc's own verbatim example. *"The format is what matters, not the model version."*
- ⚠️ Do NOT say "open source said yes to AI" flat — Torvalds himself said docs don't fix slop. Accountability does. If pushed, see Q&A.

## 6 · OpenClaw  *(1:30)* — built on agents, wrote it all down
- The other data point: **the fastest-growing open-source project in GitHub history**, built agent-first.
- The real point FIRST: *"It runs on what they wrote down for the agents: a VISION file (what to build, what to refuse) and an AGENTS file (how to build and test in the repo)."*
- Human guardrails: *"every PR needs real-behavior proof, and one of about twenty-five human maintainers signs the merge."* (26 named in CONTRIBUTING.md as of 2026-06-09 — recount before the talk.)
- The scale, as an aside and **attributed to Steinberger personally** (NOT the project, don't conflate): *"Steinberger himself runs around a hundred agents in parallel, about 1.3 million dollars of tokens in one month, funded by OpenAI."*
- If asked about the $1.3M: that's "fast-mode" pricing; without it, closer to $300k. Still OpenAI-funded research.
- Context (off-slide): Steinberger was acqui-hired by OpenAI (Feb 2026); OpenClaw now lives in a foundation OpenAI supports. See Q&A if challenged on neutrality.
- **Say (verbatim, seed for slide 12):** *"An agent is only as good as the docs and the rules you give it."*
- Conclusion: *"A hundred agents, and the human is still the bottleneck, on purpose."*
- **Bridge to LOTUSim (verbatim):** *"These are not abstract examples. Let me show you the same discipline on a real LOTUSim feature."*

## 7 · Scenario — sonar sensor  *(1:00)*
- The concrete case: **add a sonar sensor to an underwater platform.** Touches the whole stack.
- **Be honest about the physics (important for the engineers in the room):**
- **Say (verbatim):** *"The agent writes the skeleton, the ROS message, and a zero-stub so the sim compiles. The acoustic model stays yours — you plug it in, and it's validated before merge."*
- Goal: from zero knowledge of the repo to a PR ready to review, in one session.

## 8 · Relay — five roles  *(0:45)*
- Point at the animation, let it play. Don't over-explain.
- **Say (verbatim, anti-FOMO):** *"This is one agent wearing five hats — not a hundred running in parallel. The craft is in the sequence."*
- *"One possible breakdown — adapt it to your project."* Then move on quickly.

## 9 · The loop, on the sonar  *(2:00)* — main "how" slide
- Walk the left column top to bottom, one short line each: Map · Plan · Build · Doc · Ship.
- Land the **two human moments** clearly:
  - at **Plan**: *"It proposes two or three options. I choose. That's the part that doesn't get delegated — taste and system design."*
  - at **Build**: *"The agent runs colcon and the sim, reads the failure, fixes it. It closes the loop itself. Local CI beats remote CI — twelve seconds, not ten minutes."*
- Point at the terminal during Build (it's the proof).
- The on-slide quote uses "moats" — rare word; gloss it if faces go blank: *"moats — the things a machine can't easily replace."*
- **Say (verbatim):** *"The code is yours — readable, and you can defend every line."*

## 10 · Demo — video  *(2:00)*
- This is my breather. Let the **sped-up video** play; say little.
- Before: *"From a cloned repo to a pull request — let me show you the real thing, sped up."*
- **Say (verbatim, before the video — this is the credibility beat):** *"This was recorded on LOTUSim exactly as it is today. No AGENTS.md, no prepared context. Keep that in mind for the homework slide."*
- After: *"The code isn't disposable. It's readable, tested, documented, and it follows the repo's conventions."*
- ⚠️ No invented numbers. The video is the evidence. (If the video isn't ready: say "a recorded session" and describe the five steps in one sentence each.)
- ⚠️ PREP CHECK: record the video on the **unmodified** repo (that's now claimed on the slide), by 27 June at the latest; then remove the brackets from the slide footer.

## 11 · Limits — what I'm not selling  *(1:15)*
- Four honest cards. Go fast, one line each.
- **Govern what the agent touches:** open-source LOTUSim is public — fine. The real risk: *"without clear rules, an agent can pull in something that shouldn't land in a public repo."* (everyone will understand the reference — leave it there, don't elaborate)
- **Hallucinations:** *"it sometimes invents a Gazebo API that doesn't exist — build and tests are the safety net."*
- **Supervision is not optional** — supervise it like a junior dev. No "dark factory".
- **Not a substitute** — without a real C++/ROS/physics foundation, the agent just lets you hit the wall faster.

## 12 · LOTUSim's homework  *(1:30)* — the governance message, I own this
- This is the second target. Say it plainly: *"This isn't only on you. The project has homework too — and today it isn't done."*
- Left = today (README is one paragraph; docs in a wiki; nothing for the agents). Right = the homework (AGENTS.md, in-repo VISION, docs-as-code, test suite + local CI, SECURITY.md, an AI-contribution policy).
- On SECURITY.md, one line, no dwelling: *"And a clear way to report vulnerabilities — set up before the volume arrives, not after. That's the one lesson OpenClaw learned the hard way."*
- **Say (verbatim, ties back to slide 3):** *"The wall I started with — the implicit conventions — is exactly what these files write down. Lower it for humans, and you lower it for agents too."*

## 13 · Close  *(1:00)*
- **Say (verbatim):** *"An open simulator. An augmented practice."*
- Two columns: *"If you contribute"* (clone, ask an agent, pick an issue, PR with Assisted-by — you sign) / *"What the project will do"* (AGENTS.md, in-repo VISION, an AI policy — **my commitment, as lead dev**).
- One forward nod for the obvious question: *"And yes — agents can also generate simulation scenarios. That's business-typed agents, a different talk. Happy to discuss it after."*
- *"Thank you. Questions?"*

---

## Prep Q&A — the hard ones (keep in mind, not on slide)
- **"Cost / licence / can it even run behind the Naval Group proxy?"** → Honest: depends on your setup; the workflow is tool-agnostic. For open-source LOTUSim there's no requirement to self-host. Don't oversell.
- **"Classified / sensitive data?"** → Clear line: contributing to the **open-source** part = fine. Internal/classified work = match the safeguard to the data (context separation, self-hosted models). This is exactly why the project needs written rules on what agents may touch.
- **"Sovereignty — depending on a US model vendor, for defence?"** → Legitimate. The *method* (the loop, Assisted-by, the human signs, doc-as-code) is portable across vendors and works with self-hosted models. Name it openly.
- **"Won't this flood maintainers with AI PRs?"** → That's the failure mode without governance. The guardrails are the answer: one PR = one topic, real-behavior proof, Assisted-by, a human signs the merge. Recipe from the kernel and OpenClaw, sized for LOTUSim.
- **"The ~300k-line AI PRs that caused a mess here?"** → Don't name it. *"Exactly the kind of thing that happens without clear rules for agents — which is why the homework matters."*
- **"Who's responsible if the agent's PR breaks prod?"** → The human who signed. DCO. No ambiguity.
- **"Reproducibility — same prompt, different result?"** → True; that's why the loop ends on build + tests, not on the prompt. We review the result, not the run.
- **"Is 'the human signs' a fiction if they don't understand the code?"** → The agent **accelerates** understanding, it doesn't replace it. You read everything, you sign what you can defend.
- **"Will AI replace engineers?"** → No. *Taste and system design remain the moats* (Steinberger). The human chooses and signs.
- **"Was the demo on a prepped repo?"** → No. *"The repo exactly as it is today — no AGENTS.md, no prepared context. With the homework done, the same session gets faster and safer. That's the point."*
- **"OpenClaw belongs to OpenAI now — is it a neutral example?"** → Acqui-hire, Feb 2026; the project lives in a foundation OpenAI supports. The governance artifacts (VISION.md, AGENTS.md, real-behavior proof) are public, verifiable, and predate the deal. The lesson stands.
- **"OpenClaw's security record? (150+ CVEs in months)"** → Yes, and that's the cautionary half of the lesson: governance must precede scale, not chase it. It's exactly why SECURITY.md is on our homework list before the agents arrive.
- **"Does the agent set up my ROS/Gazebo environment too?"** → No. The agent writes and verifies code; the environment is yours to install. A reproducible dev setup (container) is part of making the repo agent-ready — fair candidate for the homework list.
- **Repo:** github.com/naval-group/LOTUSim.
