# Speaking script — *From idea to LOTUSim contribution, faster with AI agents*

> LOTUSim Technical Conference · Naval Group · 02/07/2026 · ~15–16 min
> This is a **word-for-word script**, written to be read out loud. Short sentences. Simple words. Easy to pronounce.
> **[Square brackets] = delivery cues, not spoken.** A slash `/` marks a good place to breathe.
> Aim for a calm, steady pace — about 120 words a minute. Slower is better than faster.
> **12 slides** (the Linux kernel and OpenClaw share one slide). Slide numbers below match the deck.

**Golden rules for the day**
- One idea per breath. Stop at every period.
- When you point at the screen, *stop talking* for one second. Let them look.
- If you lose your line, look at the slide title and start the next sentence. The slides carry the story.
- It is fine to pause. Silence feels long to you, not to them.

---

## 1 · Cover *(0:45)*

Good morning, everyone. / My name is Cyril Moron. / I am a lead developer at Naval Group.

In the next fifteen minutes, I want to show you one thing: / how AI agents bring down the entry barrier of our simulator — / a simulator built on ROS, Gazebo, and Xdyn. /

And, just as important, / what the project has to do in return. /

LOTUSim is open source now. / I want it to become a project / people are proud to contribute to. /

So: one method, one demo, / and some homework — including mine.

---

## 2 · The wall *(1:00)*

[Slow down. This is the hook. Let them recognise the feeling.]

If you have ever tried to contribute to a robotics simulator, / you know this wall. /

It has three sides. /

First, the technical surface. / Modern C++, CMake, ROS, Gazebo plugins, Xdyn. / Every brick has its own habits. The learning curve is real. /

Second, the physical coupling. / A sensor is not just a class. / It is a physical model, a ROS message, a Gazebo plugin, and a launch scenario — all at once. /

Third, and this is the worst one: / the implicit conventions. / The rules that are never written down. / [Pause.] Remember this third one. It comes back at the end. /

So what happens? / Many good ideas die / between "I want to contribute" / and "my pull request is ready".

---

## 3 · Two kinds of "agent" *(0:45)*

[Quick. Under a minute. This is just to avoid confusion.]

One quick word, because in this room the word "agent" means two things. /

In LOTUSim, an agent is a simulated platform. / An aerial drone, a surface ship, an underwater vehicle. /

In this talk, an agent is something else. / It is a large language model that is given tools. / It reads the repository, it edits files, / it runs the build, the tests, and git, / it sees the result, and it tries again. /

[Verbatim — say it clearly:] The second kind of agent / helps you build the first.

---

## 4 · Why now *(1:15)*

Why now? / Why not eighteen months ago? /

Three things changed, at the end of 2025. /

One: the models became good at calling tools. / With models like Opus 4.5 and GPT-5.2, / a long chain of steps finally stays on track. /

Two: long context. / The whole codebase, the docs, the conventions — / they fit in one shot. No more lossy summaries. /

Three, and this is the real one: / sustained autonomy. / What holds a task together over hours / is not a bigger prompt. / It is the loop. / Map, build, run, test, review — / repeated until it is green. /

[Point at the terminal once. Do not read it.]

And once an agent can write code, / one question follows: / how do we handle agent-assisted contributions, responsibly? /

[Optional — oral only, never on the slide. Sensitive; say it calmly, name no one. Skip it if you are not comfortable.]
We have already seen, here, / what this looks like without a frame. / Contributions, generated with agents, / with no rules around them — / and some content that should not have been public. / [Pause.] That is exactly why the question matters for us. /

Two communities have already answered it. / Let's look at them.

---

## 5 · Industry — two answers *(2:30)*

[The pivot from "the question" to "the answers". Two communities, side by side on one slide. Take your time — this is the proof. Point left, then right.]

Two communities already answered that question. / Very different communities. / The same answer underneath. /

[Point at the left column.] First, the Linux kernel. / The most conservative community in open source. / They did not panic, and they did not ban it. / They took the time to think, / and they wrote a real document, in the repository, / addressed to the agents / and to the people who run them. /

There is one line that does not move. / [Read it slowly.] "AI agents must not add Signed-off-by." / Only a human can certify the contribution. / [Verbatim:] So their answer was yes — / under one condition: / the human who signs / answers for every line. /

[Point at the right column.] Second, OpenClaw. / The opposite temperament. / The fastest-growing open-source project in GitHub history, / built agent-first, / about three hundred and seventy-six thousand stars. /

But the numbers are not the lesson. / The lesson is what they wrote down for the agents: / a vision file — what to build, and what to refuse — / and an agents file — how to build and test, right in the repo. / And the guardrails are human: / every pull request needs real-behavior proof, / and a human signs the merge. /

[The scale — say it as an aside, and be precise: this is Steinberger himself, not the project.] To get there, Steinberger himself / runs around a hundred agents in parallel. / About one point three million dollars of tokens, / in a single month, / funded by OpenAI. / A hundred agents — / and the human is still the bottleneck. / On purpose. /

[Verbatim — this is the seed for the end:] An agent is only as good / as the docs and the rules you give it.

---

## 6 · Scenario — the sailboat *(1:00)*

Now let's bring this home, to LOTUSim. / We want the best of both: / the kernel's contract, / and OpenClaw's discipline. /

Let's make it concrete, / with something real. / We want to add a small RC sailboat / and make it round a race buoy. /

I chose this on purpose. It is not trivial. / It touches the whole stack: / the boat physics, the engine, / the model and its mesh, a scenario, and the docs. /

And let me be honest about the physics, / because there are engineers in this room. /

[Verbatim:] The agent writes the structure: / the model skeleton, the engine glue, the scenario. / The hydro and aero model stays yours. / You plug it in, / and it is validated before the merge. /

The goal: / from zero knowledge of the repo, / to a pull request ready for review, / in one work session.

---

## 7 · The relay — five roles *(0:45)*

[Let the animation play. Point at it. Do not over-explain.]

I like to think of it as one agent / wearing five different hats. /

It maps the repo. / It plans the options. / It builds and closes the loop. / It writes the docs. / And it ships the pull request. /

[Verbatim — this calms the hype:] This is one agent, with five hats. / Not a hundred running in parallel. / The craft is in the sequence. /

This is one possible breakdown. / Adapt it to your own project.

---

## 8 · The loop, on the sailboat *(2:00)*

[This is the main "how" slide. Walk the left column, top to bottom, one short line each. Take your time.]

Let's walk the loop, on our sailboat. /

**Map.** / The agent reads the repo. / It finds the closest analog — / an existing vessel model. / It answers with file and line numbers, / in minutes, not days. /

**Plan.** / It proposes two or three strategies, with trade-offs. / And then — / I choose. / [Slow down.] This is the part that does not get delegated. / Taste, and system design, / stay with the human. /

**Build.** / It runs colcon and the simulator. / It reads the failure. / It fixes it. / It closes the loop by itself. / [Point at the terminal.] And local CI beats remote CI: / the agent sees the failure in twelve seconds, / not ten minutes. /

[Optional oral beat — the engine bug. NOT on the slide. Use it if you have the time; it lands hard. This is the proof of "map" and of the loop.]
And here is the best part. / While wiring the boat, / the agent went down into the C++ engine. / And it found a real bug. / A quaternion, read the wrong way. / A pure change of heading / came back as a roll. / It was invisible on a boat going straight; / our turning sailboat made it surface. / The agent characterised it, / fixed it, / and wrote a regression test. / [Verbatim:] That is the power of the loop: / map an unknown engine, / and close the loop on a real fix. /

**Doc.** / It writes the documentation page, / while the "why" is still fresh. /

**Ship.** / A labelled issue, a fork, a pull request. / Assisted-by — / and I sign. /

[Verbatim:] The code is yours. / Readable. / And you can defend every line.

---

## 9 · Demo — the video *(2:00)*

[This is your breather. Let the sped-up video play. Say very little.]

Enough slides. / Let me show you the real thing, / sped up. /

From a cloned repo / to a sailboat rounding a buoy, / inside LOTUSim. /

[Verbatim, before the video — this is the credibility beat:] This was recorded on LOTUSim exactly as it is today. / No AGENTS.md, no prepared context. / Keep that in mind for the homework slide. /

[Start the video. Stay quiet. Let it run. Speak only to mark the steps if you want: "map… plan… build… docs… the pull request."]

[When it ends:] So — / the code is not disposable. / It is readable, it is tested, / it is documented, / and it follows the repo's conventions. /

[If the video does not play: stay calm. Say "this was a recorded session," and describe the five steps in one sentence each — map, plan, build, doc, ship. Then move on.]

---

## 10 · Limits — what I am *not* selling *(1:15)*

[Four honest points. Go fast. One line each. Honesty builds trust here.]

Now, what I am *not* selling you. / Four honest limits. /

One: govern what the agent touches. / Open-source LOTUSim is public, so sharing it with an agent is fine. / The real risk is different: / without clear rules, / an agent can pull in something / that should not land in a public repo. /

Two: hallucinations. / Sometimes it invents a Gazebo API that does not exist. / The build and the tests are the safety net. /

Three: supervision is not optional. / You supervise the agent like a junior developer. / There is no "dark factory" here. /

Four: the software wall is not the domain wall. / AI drops the software wall in hours — / install, launch, a first feature, even a first bugfix. / But the domain wall stays. / The environment and the vessel physics / need real naval expertise. / Without it, / the agent just gets you to that wall faster.

---

## 11 · LOTUSim's homework *(1:30)*

[This is the second half of the answer. I own this part — say it plainly.]

So far I talked about you, the contributor. / But this is not only on you. / The project has homework too. / And today, it is not done. /

On the left: LOTUSim today. / The README is one paragraph. / The docs live in a wiki, not in the repo. / There is nothing addressed to the agents. /

On the right: the homework. / An agents file — how to map, build, and test. / A vision file, in the repo — the roadmap, and what we will not merge. / Docs as code. / A test suite with local CI. / And a clear AI-contribution policy. /

[Verbatim — this ties back to slide two:] The wall I started with — / those implicit conventions — / is exactly what these files write down. / Lower the wall for humans, / and you lower it for the agents too. /

This is how LOTUSim becomes a reference — / not just another repo.

---

## 12 · Close *(1:00)*

[Land it calmly. This is your commitment in front of the room.]

So let me close. / An open simulator. / An augmented practice. /

If you contribute: / clone the repo, / ask an agent to map it, / pick an issue, / and come back with a pull request. / Assisted-by — / and you sign. /

And the project's side — / here is what I will push for, / and contribute myself: / an agents file, a vision in the repo, / and a clear AI policy. / I will bring that work to the table. /

I want LOTUSim to be an example / of how an open project welcomes agents — / cleanly, / and with the human in charge. /

[One forward nod for the obvious question:] And yes — / agents can also generate simulation scenarios. / That is a different kind of agent, / and a different talk. / Happy to discuss it after. /

[Pause. Smile.] Thank you. / I am happy to take your questions.

---

## Appendix — words to watch (French speaker)

A few words in this talk are easy to trip on. Practise these out loud a few times.

| Word | Say it like | Note |
|---|---|---|
| **agent** | *AY-jent* | soft "j", not "ah-zhon" |
| **launch** | *lawnch* | rhymes with "haunch" |
| **buoy** | *BOO-ee* | (US) — or *BOY* (UK); pick one and stay with it |
| **quaternion** | *kwuh-TUR-nee-on* | only if you tell the bug story |
| **conventions** | *kon-VEN-shuns* | |
| **threshold** | *THRESH-hold* | the "th" is soft, tongue behind teeth |
| **though / through / thought** | *thoh / throo / thawt* | three different words — slow down |
| **bottleneck** | *BOTT-l-nek* | |
| **guardrails** | *GARD-rails* | |
| **repository / repo** | *ri-POZ-i-tory / REE-po* | "repo" is fine and shorter |
| **hallucinations** | *huh-loo-si-NAY-shuns* | |
| **disposable** | *dis-POH-zuh-bl* | |
| **conservative** | *kon-SER-vuh-tiv* | |

**Two contractions you'll use a lot:** "it is" → *it's*, "do not" → *don't*. Both are fine and sound natural. If a contraction trips you, just say the full words — no problem.

**Timing check:** if you finish slide 5 (the two industry answers) at around the 7-minute mark, you are on pace. If you are ahead, slow down on the loop (slide 8) and the demo (slide 9) — those are the heart of the talk. The engine-bug aside on slide 8 is the first thing to cut if you are running long.
