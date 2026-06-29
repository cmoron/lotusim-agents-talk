# Speaking script — _From idea to LOTUSim contribution, faster with AI agents_

> LOTUSim Technical Conference · Naval Group · 2 July 2026 · ~15–16 min
> This is a **word-for-word script**, written to be read out loud. Short sentences. Simple words. Easy to say.
> **[Square brackets] = delivery cues, not spoken.** A slash `/` marks a good place to breathe.
> Aim for a calm, steady pace — about 120 words a minute. Slower is better than faster.
> **12 slides** (the Linux kernel and OpenClaw share one slide). Slide numbers below match the deck.

**Golden rules for the day**

- One idea per breath. Stop at every period.
- When you point at the screen, _stop talking_ for one second. Let them look.
- If you lose your line, read the slide title and start the next sentence. The slides carry the story.
- It is fine to pause. Silence feels long to you, not to them.

---

## 1 · Cover _(0:45)_

Good morning, everyone. / My name is Cyril Moron. / I am a lead developer at Naval Group. / I do not work on LOTUSim itself. / I come to it from another team, / as a contributor — / like many of you. /

In the next fifteen minutes, / I want to show you one thing: / how AI agents make it easier / to start contributing to LOTUSim. / A simulator built on ROS, Gazebo, and Xdyn. /

And the other side of it: / what the project can do in return. /

LOTUSim is open source now. / So now is the time / to make it easy to contribute to. /

So: a method, / a demo, / and some homework for the project. /

---

## 2 · The wall _(1:00)_

[Slow down. This is the hook. Let them feel it.]

If you have ever tried to contribute / to a robotics simulator, / you know this wall. /

It has three sides. /

First, the tools. / Modern C++, CMake, ROS, Gazebo plugins, Xdyn. / Every tool has its own habits. / The learning curve is real. /

Second, everything is connected. / A sensor is not just a class. / It is a physics model, / a ROS message, / a Gazebo plugin, / and a launch scenario. / All at once. /

Third, and this is the worst one: / the implicit conventions. / The rules that nobody writes down. / [Pause.] Remember this third one. / It comes back at the end. /

So what happens? / Many good ideas die / between "I want to contribute" / and "my pull request is ready". /

---

## 3 · Two kinds of "agent" _(0:45)_

[Quick. Under a minute. This is just to avoid confusion.]

One quick word. / In this room, / the word "agent" means two things. /

In LOTUSim, / an agent is a simulated platform. / A drone in the air, / a ship on the surface, / a vehicle under water. /

In this talk, / an agent is something else. / It is a large language model / that we give tools. / It reads the code, / it edits files, / it runs the build, the tests, and git, / it sees the result, / and it tries again. /

[Verbatim — say it clearly:] The second kind of agent / helps you build the first. /

---

## 4 · Why now _(1:15)_

Why now? / Why not eighteen months ago? /

Three things changed, / at the end of 2025. /

One: / the models became good at using tools. / With models like Opus 4.5 and GPT-5.2, / a long chain of steps / finally stays on track. /

Two: / long context. / The whole codebase, / the docs, / the conventions — / they all fit in one shot. / Nothing is lost in a summary. /

Three, / and this is the real one: / the agent can work on its own, / for a long time. / What holds a task together over hours / is not a bigger prompt. / It is the loop. / Map, build, run, test, review. / Again and again, / until it is green. /

[Point at the terminal once. Do not read it.]

And once an agent can write code, / one question follows: / how do we handle agent-assisted contributions, / responsibly? /

[Optional — oral only, never on the slide. Sensitive; say it calmly, name no one. Skip it if you are not comfortable.]
We have already seen, here, / what this looks like / without a frame. / Contributions, made with agents, / with no rules around them. / And some content / that should not have been public. / [Pause.] That is exactly / why the question matters for us. /

Two communities have already answered it. / Let's look at them. /

---

## 5 · Industry — two answers _(2:30)_

[The pivot from "the question" to "the answers". Two communities, side by side on one slide. Take your time — this is the proof. Point left, then right.]

Two communities already answered that question. / Very different communities. / But the same answer underneath. /

[Point at the left column.] First, the Linux kernel. / The most careful community in open source. / They did not panic, / and they did not ban it. / They took the time to think. / And they wrote a real document, / in the repository, / for the agents / and for the people who run them. /

There is one line that does not move. / [Read it slowly.] "AI agents must not add Signed-off-by." / Only a human can approve the contribution. / [Verbatim:] So their answer was yes. / Under one condition: / the human who signs / answers for every line. /

[Point at the right column.] Second, OpenClaw. / The opposite style. / The fastest-growing open-source project / in GitHub history. / Built with agents from day one. / About three hundred and seventy-six thousand stars. /

But the numbers are not the lesson. / The lesson is what they wrote down / for the agents. / A vision file: / what to build, / and what to refuse. / And an agents file: / how to build and test, / right in the repo. / And the humans stay in control. / Every pull request needs proof / that the code really works. / And a human signs the merge. /

[The scale — say it as an aside, and be precise: this is Steinberger himself, not the project.] To get there, / Steinberger himself / runs about a hundred agents in parallel. / Around one point three million dollars of tokens, / in a single month, / paid by OpenAI. / A hundred agents. / And the human is still the bottleneck. / On purpose. /

[Verbatim — this is the seed for the end:] An agent is only as good / as the docs and the rules / you give it. /

---

## 6 · Scenario — the sailboat _(1:00)_

Now, back to LOTUSim. / We can take both: / the kernel's contract, / and OpenClaw's discipline. /

Let's make it concrete, / with something real. / We want to add a small RC sailboat, / and make it round a race buoy. /

I chose this on purpose. / It is not easy. / It touches the whole stack: / the boat physics, / the engine, / the model and its mesh, / a scenario, / and the docs. /

And let me be honest about the physics. / Because there are engineers in this room. /

[Verbatim:] The agent writes the structure. / The model skeleton, / the engine glue, / the scenario. / It even gives you a model that runs. / But a model that runs / is not a model true to the real boat. / The hydro and aero model stays yours. / You plug it in, / and it is checked before the merge. /

The goal: / from zero knowledge of the repo, / to a pull request ready for review, / in one work session. /

---

## 7 · The relay — five roles _(0:45)_

[Let the animation play. Point at it. Do not over-explain.]

Five roles, / one sequence. / Sometimes a single agent / wears every hat. / Sometimes you start several. / A few of them / just to map the repo. /

It maps the repo. / It plans the options. / It builds, / and closes the loop. / It writes the docs. / And it ships the pull request. /

[Verbatim — this calms the hype:] Several agents, / sometimes in parallel. / But the count is not the point. / The point is the roles, / the sequence, / and the human who signs. /

This is one way to split the work. / Change it to fit your own project. /

---

## 8 · The loop, on the sailboat _(2:00)_

[This is the main "how" slide. Walk the left column, top to bottom, one short line each. Take your time.]

Let's walk the loop, / on our sailboat. /

**Map.** / The agent reads the repo. / It finds the closest example: / an existing vessel model. / It answers with file and line numbers. / In minutes, / not days. /

**Plan.** / It proposes two or three options, / with trade-offs. / And then — / I choose. / [Slow down.] This is the part / that I do not delegate. / Taste, / and system design, / stay with the human. /

**Build.** / It runs colcon and the simulator. / It reads the error. / It fixes it. / It closes the loop by itself. / [Point at the terminal.] And local CI beats remote CI: / the agent sees the error in seconds, / not minutes. /

[Optional oral beat — the engine bug. NOT on the slide. Use it if you have the time; it lands hard. This is the proof of "map" and of the loop.]
And there is more. / While wiring the boat, / the agent went down / into the C++ engine. / And it found a real bug. / A quaternion, read the wrong way. / A simple change of heading / came back as a roll. / You could not see it / on a boat going straight. / Our turning sailboat / made it show up. / The agent understood the bug, / fixed it, / and wrote a test for it. / [Verbatim:] That is the power of the loop: / map an unknown engine, / and close the loop / on a real fix. /

**Doc.** / It writes the documentation page, / while the "why" is still fresh. /

**Ship.** / A labelled issue, / a fork, / a pull request. / Assisted-by — / and I sign. /

[Verbatim:] The code is yours. / Readable. / And you can defend every line. /

---

## 9 · Demo — the video _(2:30)_

[This is your breather. Let the video play — mostly sped up, back to real time on the key moments. Say very little.]

Enough slides. / Let me show you the demo, / sped up. /

From a cloned repo, / to a sailboat rounding a buoy, / inside LOTUSim. /

[Verbatim, before the video — this is the credibility beat:] This was recorded on LOTUSim / exactly as it is today. / No agents file, / no prepared context. / Keep that in mind / for the homework slide. /

[Start the video. Stay quiet. Let it run. Speak only to mark the steps if you want: "map… plan… build… docs… the pull request."]

[When it ends:] So — / the code is not throwaway code. / It is readable, / it is tested, / it is documented, / and it follows the repo's conventions. /

[If the video does not play: stay calm. Say "this was a recorded session," and describe the five steps in one sentence each — map, plan, build, doc, ship. Then move on.]

---

## 10 · Limits — what I am _not_ selling _(1:15)_

[Four honest points. Go fast. One line each. Honesty builds trust here.]

Now, / what I am _not_ selling you. / Four honest limits. /

One: / govern what the agent touches. / Open-source LOTUSim is public, / so sharing it with an agent is fine. / The real risk is different. / Without clear rules, / an agent can bring in something / that should not land in a public repo. /

Two: / it hallucinates. / Sometimes it invents a Gazebo API / that does not exist. / The build and the tests / are the safety net. /

Three: / supervision is not optional. / You watch the agent / like a junior developer. / There is no "dark factory" here. /

Four: / the software wall / is not the domain wall. / AI drops the software wall in hours. / Install, launch, / a first feature, / even a first bugfix. / It even gives you a boat model / that runs in Xdyn. / Stable enough / to measure a speed polar. / But a model that runs / is not a model true to the real boat. / And no AI agent / will run the towing-tank tests for you. / The true hydro and aero / come from the tank and from CFD. / The work of our hydro experts, / at Sirehna. / Without that, / the agent just gets you to that wall faster. /

---

## 11 · LOTUSim is almost agent-ready _(1:30)_

[Second half of the answer. Stay positive — we work for LOTUSim, not against it. The demo already proved the left side.]

So far I talked about you, / the contributor. / But this is not only on you. / The project has homework too. / And LOTUSim is already very close. /

On the left: / what already works. / You just saw it in the demo. / From a cloned repo, / with no special setup, / the agent mapped the project on its own / and produced a working pull request. / There are already enough docs / to get started. /

On the right: / what completes it. / And a lot of it / is already on the way. / A vision file / is being finalized by the project team. / An AI-contribution policy / will be published soon. / And a LOTUSim developer skill, / that we built during our first pull request, / is ready to share. /

Two things are still missing. / An agents file. / And docs as code, / with a test suite and local CI. /

[Verbatim — this ties back to slide two:] The wall I started with — / those implicit conventions — / is exactly what these files write down. / Lower the wall for humans, / and you lower it for the agents too. /

So: LOTUSim is not fully agent-ready yet. / But it is already very usable. / And the rest / is mostly under way. /

---

## 12 · Close _(1:00)_

[Land it calmly. This is your commitment in front of the room.]

So let me close. / An open simulator. / An augmented practice. /

If you contribute: / clone the repo, / ask an agent to map it, / pick an issue, / and come back with a pull request. / Assisted-by — / and you sign. /

And on the project's side, / here is what I will push for, / and contribute myself: / an agents file, / the vision in the repo, / a clear AI policy, / and the developer skill / we already built. / I will do that work. /

I want LOTUSim to be an example / of how an open project welcomes agents. / Cleanly. / And with the human in charge. /

[One forward nod for the obvious question:] And yes — / agents can also generate simulation scenarios. / That is a different kind of agent, / and a different talk. / Happy to discuss it after. /

[Pause. Smile.] Thank you. / I am happy to take your questions. /

---

## Appendix — words to watch (French speaker)

A few words in this talk are easy to trip on. Practise these out loud a few times.

| Word                           | Say it like              | Note                                               |
| ------------------------------ | ------------------------ | -------------------------------------------------- |
| **agent**                      | _AY-jent_                | soft "j", not "ah-zhon"                            |
| **launch**                     | _lawnch_                 | rhymes with "haunch"                               |
| **buoy**                       | _BOO-ee_                 | (US) — or _BOY_ (UK); pick one and stay with it    |
| **quaternion**                 | _kwuh-TUR-nee-on_        | only if you tell the bug story                     |
| **conventions**                | _kon-VEN-shuns_          |                                                    |
| **threshold**                  | _THRESH-hold_            | the "th" is soft, tongue behind teeth              |
| **though / through / thought** | _thoh / throo / thawt_   | three different words — slow down                  |
| **bottleneck**                 | _BOTT-l-nek_             |                                                    |
| **repository / repo**          | _ri-POZ-i-tory / REE-po_ | "repo" is fine and shorter                         |
| **hallucinates**               | _huh-LOO-si-nates_       |                                                    |
| **careful**                    | _KAIR-ful_               | (used for the kernel — easier than "conservative") |

**Two short forms you'll use a lot:** "it is" → _it's_, "do not" → _don't_. Both are fine and sound natural. If a short form trips you, just say the full words — no problem.

**Timing check:** if you finish slide 5 (the two industry answers) at around the 7-minute mark, you are on pace. If you are ahead, slow down on the loop (slide 8) and the demo (slide 9) — those are the heart of the talk. The engine-bug aside on slide 8 is the first thing to cut if you are running long; on slide 10, the "speed polar in Xdyn" sentence is the next to trim.
