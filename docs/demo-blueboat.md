# Demo PR prep — BlueBoat model for LOTUSim

Feasibility recon and frozen demo prompt for the talk's slide-10 video.
Date: 2026-06-20. Status: **feasible, prompt frozen, not yet recorded.**

## Goal

Record the agentic loop building a **real, mergeable** LOTUSim contribution on
camera. The contribution (asked for by the PO, Estelle): add a **Blue Robotics
BlueBoat** vehicle, a 1.2 m catamaran autonomous surface vehicle (ASV) with twin
differential thrusters, *with its behaviour model*.

**Scope chosen: "spawn + structure".** The model is complete and correct (mesh,
SDF, xdyn behaviour YAML) and spawns in a world. Fine hydrodynamic tuning is left
to an engineer to validate before merge — this is the slide-7 honesty principle,
made concrete.

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
the one known anchor (3 m/s top speed).

## Mesh decision

**Agent generates a simple primitive mesh live** (boxes approximating the twin
hulls + thruster pods), from published dimensions. Zero pre-staging, fully
self-contained, license-clean, honest. Visually basic — acceptable for "spawn +
structure". (`wamv` itself pairs a detailed visual `.dae` with a plain `cube.stl`
for hydrostatics, so a primitive collision/visual is in keeping with the repo.)

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

## Frozen demo prompt

Paste this to kick off the loop on camera:

> **You are contributing to LOTUSim**, an open-source ROS2 + Gazebo maritime
> multi-agent simulator (EPL-2.0). Add a new vehicle model for the Blue Robotics
> **BlueBoat**: a 1.2 m catamaran autonomous surface vehicle with twin
> differential thrusters.
>
> First, study the repo's own conventions and `CONTRIBUTING.md`. Look at how an
> existing surface vehicle is modelled — `assets/models/wamv/` (`model.config`,
> `model.sdf`, `wamv.yaml`) — and how a vehicle is spawned and commanded in
> `assets/worlds/circling_ship_example.world`.
>
> Deliver a new `assets/models/blueboat/` package mirroring that structure:
> - `model.config` — Gazebo metadata
> - `model.sdf` — twin-hull links, two thruster links/joints (differential
>   layout), an AIS sensor like wamv
> - `blueboat.yaml` — xdyn behaviour model: environment, rigid-body inertia, added
>   mass, hydrodynamic forces, twin-propeller propulsion
> - a **simple, original primitive mesh** (e.g. boxes approximating the twin hulls)
>   you generate from the published BlueBoat dimensions
>
> Then register the BlueBoat in a world file so it spawns.
>
> **Hard constraints:**
> - **Licensing:** repo is EPL-2.0. Do **NOT** copy meshes, SDF, or coefficients
>   from ArduPilot SITL_Models (GPL-3.0) or from Blue Robotics CAD (no
>   redistribution license). Author the mesh yourself from published dimensions
>   only.
> - **Ground what's published, flag what's not.** Geometry, mass, and the T200/M200
>   thrust curve come from the official datasheet. The **added-mass and damping
>   coefficients are not published** — estimate them and mark each one
>   `# ESTIMATED — pending engineer validation`.
> - **Scope:** the model must spawn and float correctly. Fine hydrodynamic tuning
>   is out of scope (left to an engineer).
> - Open a PR referencing a new issue, with a clear scope description and a
>   **"real behavior proof"** section.
>
> **Published reference data** (do not fetch GPL sources): LOA 1.20 m · beam
> 0.93 m · dry mass 14.5 kg · payload 15 kg · max speed 3 m/s · twin M200 (T200
> curve 51.5 N fwd / 40.2 N rev @ 16 V) · hull spacing ~0.59 m · water density
> 1025 kg/m³.

## Pre-demo checklist / open items

- [ ] Decide recording environment (local LOTUSim build that can spawn + render a
      world — needed to capture the "it spawns" moment).
- [ ] Dry-run the prompt once off-camera to confirm the loop produces a clean PR
      and the boat spawns; tune the prompt if it drifts.
- [ ] Confirm whether the PR is opened against `naval-group/LOTUSim` for real
      (Cyril is lead dev) or kept on a fork for the recording.
- [ ] Speaker note: surface the GPL→EPL licensing beat (governance) and the
      estimated-coefficients beat (slide-7 honesty) when narrating the video.
