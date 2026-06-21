# Demo PR prep — BlueBoat model for LOTUSim

Feasibility recon and frozen demo prompt for the talk's slide-10 video.
Date: 2026-06-21. Status: **feasible; loop-shaped prompt drafted; scope =
floats + navigates; not yet recorded.**

## Goal

Record the agentic loop building a **real, mergeable** LOTUSim contribution on
camera. The contribution (asked for by the PO, Estelle): add a **Blue Robotics
BlueBoat** vehicle, a 1.2 m catamaran autonomous surface vehicle (ASV) with twin
differential thrusters, *with its behaviour model*.

**Scope chosen: "floats + navigates".** The boat spawns, floats (buoyancy), and
**moves on the water** under thrust (ideally following a waypoint) — the
impressive payoff for the video, and the thing that gives the autonomous loop a
real oracle ("did it move?"). Honesty preserved (slide-7): the agent produces
*plausible* motion from estimated coefficients; an engineer still validates the
*accuracy* of the hydrodynamics before merge. "Moves plausibly" ≠ "validated
hydro" — say this out loud when narrating.

## Positioning — accessible, not intimidating

The wow must come from the *result* (a single agent, a simple loop, a boat that
sails on a real contribution), never from elaborate tooling. No Linear/CI/
multi-agent rig for the demo — the smallest loop that works. "Loop design" in the
strong sense (agent ↔ Linear/GitHub Actions/PR-review bots/webhooks) is real but
deliberately *out of scope* here: building it would cost authenticity and time.
Audience = external partners who will contribute; they must leave thinking "I can
do this on my PR", not "I'm outpaced". Deliberate counterpoint to the OpenClaw
extreme (slide 6: ~100 agents, $1.3M/mo, sponsored tokens) and reinforcement of
slide 8 ("one agent, five hats"). At the dry-run, when choosing how to materialize
the loop, prefer the **most legible / audience-reproducible** option over the most
technically impressive one.

## Why this makes a *better* demo than expected

The licensing reality (below) forces the agent to **author the structure** while
the **physics that matters stays the engineer's** — exactly the deck's thesis:

- The agent grounds everything publishable: package layout (mirrors `wamv`), SDF
  topology, propulsion from the real T200 thrust curve, inertia/geometry from the
  datasheet.
- The added-mass and damping coefficients **are not published anywhere** → the
  agent estimates them and flags each `# ESTIMATED — pending engineer validation`.
- The **GPL→EPL licensing trap** (the only ready-made mesh is GPL-3.0,
  incompatible with LOTUSim's EPL-2.0) is a clean **governance / responsibility**
  talking point for the talk.

## Feasibility verdict: ✅ feasible

| Resource | Available? | Verdict |
|---|---|---|
| Ready-made Gazebo model (ArduPilot `SITL_Models/.../blueboat`: `.dae` + `.stl` + `model.sdf`, perfect LOTUSim-shaped) | Yes (HTTP 200) | ❌ **GPL-3.0 → incompatible with EPL-2.0.** Do not vendor or copy. |
| Official Blue Robotics CAD (`BLUEBOAT_120_BR-101447_RevA_PUB.zip`, ~460 MB) | Yes (HTTP 200) | ⚠️ **No redistribution license.** Dimensional reference only, never committed. |
| Official datasheet (specs + T200 curve) | Yes (PDF 3 MB, 200) | ✅ Public facts, usable. |
| A license-clean ready-made mesh | — | ❌ **Does not exist** — every BlueBoat sim mesh derives from the GPL ArduPilot one. |

**Consequence:** we author an **original simplified mesh** (published dimensions
are non-copyrightable facts; the mesh file is ours → clean under EPL-2.0).

### Verified source URLs

- Datasheet (specs): https://bluerobotics.com/wp-content/uploads/2023/03/BLUEBOAT-DATASHEET-v1.1-JAN-2025.pdf
- Product page: https://bluerobotics.com/store/boat/blueboat/blueboat/
- BR open-source policy: https://bluerobotics.com/open-source/
- BR CAD (reference only, no redistribution): https://cad.bluerobotics.com/BLUEBOAT_120_BR-101447_RevA_PUB.zip
- ArduPilot model (GPL-3.0, **reference only, do not copy**): https://github.com/ArduPilot/SITL_Models/tree/master/Gazebo/models/blueboat

## Grounded vs. estimated

**Grounded (datasheet):** LOA 1.20 m · beam 0.93 m · dry mass 14.5 kg · payload
15 kg · max speed 3 m/s · twin M200 motors (T200 curve as proxy: 51.5 N fwd /
40.2 N rev @ 16 V; note M200 is nozzle-less, so slightly lower in reality) · hull
spacing ~0.59 m · water density 1025 kg/m³.

**Estimated, must be flagged engineer-to-validate:** 6×6 added-mass matrix,
linear + quadratic damping coefficients, exact CG / draft / trim. No published
BlueBoat values exist; estimate from geometry + strip-theory, calibrated against
the one known anchor (3 m/s top speed). For "navigates" scope these only need to
be **good enough to float and move plausibly** — not validated.

## Mesh decision

**Agent models a low-poly catamaran live via the Blender MCP**
([`ahujasid/blender-mcp`](https://github.com/ahujasid/blender-mcp)): the agent
drives a live Blender session over MCP (`bpy` API) to model fuselaged twin hulls +
thruster pods from the published dimensions, then exports the mesh. Original work →
license-clean under EPL-2.0; far better on screen than raw boxes.

- **Use Blender 4.5 LTS** — Blender 5.0 removed the native COLLADA `.dae` exporter
  (LOTUSim's format). Alternative: export GLB/glTF (supported by modern gz-sim).
- Connection: the Blender addon listens on `localhost:9876`; the MCP server
  (`uvx blender-mcp`, launched by Claude Code) connects to it. On a single box
  (all in WSL2, or native Linux/macOS) this is just localhost, no networking
  config. Cross-VM (Blender on Windows, Claude in WSL2 NAT mode) is the painful
  case — avoided by keeping everything inside WSL2.
- Trade-off: adds a live moving part (Blender window + MCP connection) to the
  recording — include it in the dry-run.

## Recording environment

LOTUSim is a **Linux-only stack** (Ubuntu + ROS2 Humble + Gazebo, installed via
`apt` in `launch/install_dep.sh`; entrypoint sources `/opt/ros/humble`). Rendering
Gazebo needs Linux + a GPU. The demo splits in two:

- **The agentic loop building the PR** (files, mesh via Blender MCP, SDF/YAML, git,
  PR) — machine-agnostic; runs anywhere Claude Code + Blender run.
- **The payoff: the boat spawning in Gazebo** — needs Linux + ROS2 + Gazebo +
  **GPU**. This is the constraining half.

**Target: Windows 11 desktop, everything inside WSL2 (Ubuntu) + WSLg.** The
desktop GPU drives WSLg's hardware OpenGL, so Gazebo renders properly (unlike
Docker-on-macOS, which is software-GL only). One Linux box holds LOTUSim
(native apt install — *not* the Docker image, to keep WSLg rendering clean),
ROS2 Humble + Gazebo, Blender 4.5 LTS, Claude Code, and the Blender MCP (localhost,
no networking bridge). The MacBook Air M2 is used only for prep and dry-running the
file-generation half.

WSL2 setup notes:
- Install the **Windows GPU "WSL" driver** (NVIDIA/AMD/Intel) so WSLg gets
  hardware GL — verify `glxinfo | grep renderer` shows the real GPU, not
  `llvmpipe`.
- Native Ubuntu in WSL2 (not Docker) for clean WSLg rendering.
- All components inside WSL2 → Blender socket is plain `localhost:9876`.

> **Forward note — `VISION.md`/`AGENTS.md`:** LOTUSim has none in-repo yet (slide-12
> homework). Cyril, as lead dev, intends to add them. If they exist at recording
> time, the agent reads them first — which *reinforces* the demo ("an agent is only
> as good as the docs it can read"). The frozen prompt assumes they may not be
> there yet and points the agent at `CONTRIBUTING.md` + the `wamv` model instead.

## LOTUSim model anatomy (what the agent must mirror)

A vehicle lives in `assets/models/<name>/`:
- `model.config` — Gazebo metadata
- `model.sdf` — SDF 1.10: links, collision/visual geometry (`model://…` meshes),
  sensors. (`wamv`'s is tiny: base link + AIS sensor.)
- `<name>.yaml` — **xdyn behaviour model**: environmental constants, environment
  models (wind/waves/current), per-body rigid-body inertia (6×6), added-mass
  matrix (6×6), hydrodynamic forces point, propulsion (`wageningen B-series`
  propeller à la `lrauv`, differential for twin thrusters).
- `meshes/` — `.dae` / `.stl`.

Spawned via an `<include>` block in a world file (`model://blueboat`, `name`,
`pose`, `lotus_param` with `waypoint_follower` + `render_interface`), loaded by
`entity_manager` (default `model.sdf`, overridable via the `sdf_file` MASCmd param
from PR #8). Reference world: `assets/worlds/circling_ship_example.world`.

Contribution workflow (`CONTRIBUTING.md`): issue (label `new_model`) → announce →
fork → implement → test → PR referencing the issue.

## Loop design (the 2026 meta) — "design loops, not prompts"

The demo's effect comes from a *single* Claude running autonomously ~90 min and
ending with a boat that sails — i.e. a well-designed loop, not a clever one-shot
prompt. Both the Claude Code creator and the OpenClaw creator say the same thing:

- **Boris Cherny:** *"I don't prompt Claude anymore. I have loops that are running.
  […] My job is to write loops."* And the #1 lever: *"the most important thing… give
  Claude a way to verify its work. That feedback loop will 2-3x the quality."*
  ([YouTube](https://www.youtube.com/watch?v=SlGRN8jh2RI),
  [howborisusesclaudecode.com](https://howborisusesclaudecode.com/))
- **Peter Steinberger:** *"You shouldn't be prompting coding agents anymore. You
  should be designing loops that prompt your agents."* Code is the ideal domain
  *because the loop is closeable* — compile, run, test → an objective signal.
  ([addyosmani.com](https://addyosmani.com/blog/loop-engineering/),
  [steipete.me/posts/just-talk-to-it](https://steipete.me/posts/just-talk-to-it))

> **Talk opportunity:** either quote would make a strong slide-9 ("the loop in
> action") line. Deck edit is separate — not done here without Cyril's go-ahead.

Distilled ingredients to bake into the demo (whether as a full harness or a
loop-shaped kickoff — decided at dry-run):
1. **Spec in a file, not the chat** — goal + constraints + acceptance criteria the
   agent re-reads (Cherny's Goal/Constraints/Acceptance triple).
2. **One machine-checkable verification command** the agent loops against (the
   2-3x lever; Steinberger's closed loop).
3. **Stop condition judged by something other than the builder** (a critic/`/goal`
   evaluator) — prevents premature "done".
4. **Real behavior proof** — run the actual artifact (spawn the boat, check it
   moved), not a lint.
5. **Self-review pass before done** — re-read spec, diff against plan, list unmet
   criteria.
6. **Externalize state + atomic commits** — resumable, so you can hit escape
   mid-demo and resume (Steinberger: file changes are atomic).
7. **Durable corrections** — slips get written to CLAUDE.md/a skill, not the chat.
8. **Auto mode + budget guardrails** — uninterrupted, but a max turns/wall-clock so
   it terminates instead of thrashing.

## Closed verification loop (what makes "it sails" achievable autonomously)

The oracle is **displacement in the sim**. One iteration the agent runs headlessly:

```
build → validate SDF (gz sdf -k) → spawn headless → apply thrust
      → read start/end pose → assert moved (dist > threshold) → artifact (trajectory plot)
```

The exit code + measured displacement *are* the feedback: SDF invalid → fix
structure; `Failed to load system plugin` in the log → fix plugin filename;
`dist ≈ 0` → it sank (no buoyancy) or didn't move (no thrust/hydro) → iterate.

For "floats + moves" the boat needs the gz plugin trio:
- **Buoyancy** (world-level; acts on **collision** geometry, not visuals — the hull
  must have a real collision shape or it sinks),
- **Hydrodynamics** (Fossen drag/added-mass; without it a thrust pulse accelerates
  forever — non-physical),
- **Thruster** (turns a `cmd_thrust` Double into propeller force).

`waypoint_follower` is the natural in-sim thrust source (it already exists in the
repo) → letting it drive a waypoint and asserting displacement is the cleanest
closed loop.

**Two fragility flags:**
- **Gazebo version / command prefix.** ROS2 Humble's default is **Fortress**
  (`ign`, `ignition.msgs.*`), but LOTUSim's SDF is **1.10** → likely **Garden+**
  (`gz`, `gz.msgs.*`). Confirm at setup: `which gz ign` / check the world's
  existing plugins. Don't hardcode the prefix in the harness before confirming.
- **`--headless-rendering` (EGL/OGRE2) is the weak link under WSL2.** Never gate
  pass/fail on rendering. The robust verification artifact is the **numeric
  displacement + a trajectory plot** (no GPU dependency); a rendered screenshot is
  a nice-to-have, captured separately for the video.

## Frozen demo prompt

Paste this to kick off the loop on camera:

> **Goal.** Contribute a new vehicle model to LOTUSim (open-source ROS2 + Gazebo
> maritime simulator, EPL-2.0): the Blue Robotics **BlueBoat**, a 1.2 m catamaran
> autonomous surface vehicle with twin differential thrusters. Success = the
> BlueBoat **spawns, floats, and moves on the water under thrust** in a LOTUSim
> world, delivered as a clean PR.
>
> **First, map the repo — don't guess.** Read `CONTRIBUTING.md`; study how an
> existing surface vehicle is modelled (`assets/models/wamv/`: `model.config`,
> `model.sdf`, `wamv.yaml`) and how a vehicle is spawned and commanded
> (`assets/worlds/circling_ship_example.world`). Detect the Gazebo version
> (`which gz ign`, inspect existing world plugins) before writing any sim command.
>
> **Build** a new `assets/models/blueboat/` package mirroring wamv:
> - `model.config`, and `model.sdf` with twin-hull links carrying real
>   **collision** geometry, two thruster links/joints (differential layout), an
>   AIS sensor like wamv, and the **buoyancy + hydrodynamics + thruster** plugins
>   so it floats and moves
> - `blueboat.yaml` — xdyn behaviour: environment, inertia, added mass, hydro
>   forces, twin-propeller propulsion
> - an **original low-poly mesh** modelled via the Blender MCP from the published
>   dimensions
>
> Register it in a world so it spawns, wired to `waypoint_follower`.
>
> **Acceptance criteria — verify, don't assume:**
> 1. `gz sdf -k` (or `ign sdf -k`) validates the model and the world.
> 2. Launched headless, the server loads with no `Failed to load system plugin`.
> 3. Under thrust (via `waypoint_follower` or a `cmd_thrust`), the boat's
>    start→end displacement is **> 0.5 m** — it floats and moves, not sinks or
>    sits still. Capture a trajectory plot as proof.
>
> Loop: build → validate → spawn headless → apply thrust → read start/end pose →
> assert moved → fix, until all three pass. Then **self-review**: re-read this
> spec and list any criterion not yet met before declaring done.
>
> **Hard constraints:**
> - **Licensing:** EPL-2.0. Do **NOT** copy meshes, SDF, or coefficients from
>   ArduPilot SITL_Models (GPL-3.0) or Blue Robotics CAD (no redistribution
>   license). Author everything from published dimensions.
> - **Honesty:** geometry, mass, and the T200/M200 thrust curve come from the
>   datasheet. Added-mass and damping are **not published** — estimate them, tune
>   only enough to float and move plausibly, and mark each
>   `# ESTIMATED — pending engineer validation`. Do not claim validated hydro.
> - Open a PR referencing a new issue, with a clear scope and a **"real behavior
>   proof"** section (the headless run + trajectory plot).
>
> **Published reference data** (do not fetch GPL sources): LOA 1.20 m · beam
> 0.93 m · dry mass 14.5 kg · payload 15 kg · max speed 3 m/s · twin M200 (T200
> curve 51.5 N fwd / 40.2 N rev @ 16 V) · hull spacing ~0.59 m · water density
> 1025 kg/m³.

## Pre-demo checklist / open items

- [x] Recording environment chosen: **Windows 11 desktop, WSL2 (Ubuntu) + WSLg**
      (GPU render). M2 for prep only.
- [ ] Set up the Windows desktop: WSL2 Ubuntu + GPU driver, build LOTUSim
      (`install_dep.sh`), confirm a world spawns + renders in Gazebo via WSLg.
- [ ] Confirm Gazebo version / command prefix (`which gz ign`) — Fortress (`ign`)
      vs Garden+ (`gz`); LOTUSim's SDF 1.10 suggests `gz`. Don't hardcode before
      confirming.
- [ ] Install Blender 4.5 LTS + `blender-mcp` in WSL2; wire the MCP server into
      Claude Code; confirm the addon connects on `localhost:9876`.
- [ ] Decide loop materialization at dry-run: full harness (SPEC.md + verify
      script: build→spawn headless→assert moved→plot) vs loop-shaped kickoff alone.
- [ ] Dry-run the prompt once off-camera: confirm the loop produces a clean PR and
      the boat **floats + moves** (displacement > 0.5 m); tune if it drifts.
- [ ] Confirm whether the PR is opened against `naval-group/LOTUSim` for real
      (Cyril is lead dev) or kept on a fork for the recording.
- [ ] Speaker note: surface the GPL→EPL licensing beat (governance) and the
      estimated-coefficients beat (slide-7 honesty) when narrating the video.
- [ ] Narration beat — **accessibility counterpoint**: explicitly frame the demo
      as "one agent, a simple loop, what *one of us* can do on a real PR" against
      the OpenClaw extreme (100 agents, $1.3M/mo, sponsored tokens). Goal: the
      audience leaves empowered ("I can do this"), not outpaced.
