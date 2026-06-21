# Dry-run #1 — BlueBoat — friction log

Date: 2026-06-21. Mode: instrumented (Claude drives live with full prep context).
Goal of this pass: shake out breakpoints, feed them back into the `lotusim-developer`
skill and/or the frozen prompt before a faithful fresh-context rehearsal.

Each entry: **what bit**, **why**, **fix/workaround**, **→ skill?** (does it belong in
the skill / frozen prompt, or was it a one-off).

---

## Friction points

### F1 — zsh eats unquoted globs in `grep --include=*.cpp` (Bash tool runs zsh)
**What bit:** `grep -r --include=*.cpp ...` → `zsh: no matches found: --include=*.cpp`.
**Why:** the Bash tool shell is zsh; `*.cpp` is glob-expanded before grep sees it.
**Fix:** use `rg` (own globbing) or quote: `--include='*.cpp'`. Minor, but recurring.
**→ skill?** Yes — one line in the existing shell-gotcha note (piège #4 family).

### F2 — waypoint_follower is NOT a thrust source (it's a separate, kinematic mode) ⭐
**What bit:** the frozen prompt + skill say "register a waypoint_follower so the boat
gets thrust; the waypoint_follower drives the vessel → assert displacement". Wrong.
**Why / evidence:**
- No world combines `<physics_engine_interface>` and `<waypoint_follower>`:
  `xdyn_multithread_test.world` = xdyn physics, NO waypoint; `circling_ship_example.world`
  = waypoint, NO physics (`<gravity>0 0 0`, kinematic).
- `systems/waypoint_follower/src/waypoint_follower.cpp` emits only *status* messages
  (`WaypointFollowerStatus`); it has no thruster/command output path.
- So waypoint = kinematic pose control; xdyn = dynamic. They're alternative motion
  sources, not composable as "waypoint → thrust".
**How a surface vessel actually moves under xdyn (validated):** the xdyn `commands:`
block in `<name>.yml` (constant/scheduled rpm per named actuator), exactly like
`dtmb-xdyn.yml` (rpm 30 rad/s both props) run in `xdyn_multithread_test.world`. Thrust
is **open-loop** from the yaml. (A closed-loop controller publishing to the physics
interface's "vessel command array" subscription may exist — `physics_interface_plugin`
*subscribes* to commands — but nothing in-repo publishes them for waypoint following.)
**Decision for the dry run:** drive motion **open-loop via the yaml `commands:` block**
(bulletproof, validated). "Moves in a straight line under constant thrust" is honest
and satisfies displacement > 0.5 m. Circling/waypoint is a separate, kinematic demo.
**→ skill + frozen prompt?** YES, important correction. Reword the verify loop and the
"register a waypoint" step.

### F3 — xdyn propulsion: section + model string differ across examples
**What bit:** where do thrusters go and what `model:` string?
**Observed:** `dtmb-xdyn.yml` → `model: propeller+rudder` under **`external forces:`**
(twin PSPropRudd/SBPropRudd) + a `commands:` block (rpm 30, P/D 0.79). `lrauv.yml` →
`model: wageningen B-series` (a single propeller, no rudder) under **`controlled
forces:`**, commands commented out. For a differential twin ASV (no rudder) the honest
model is twin `wageningen B-series`. Unconfirmed which section works with `commands:`.
**RESOLVED:** twin `wageningen B-series` under **`external forces:`** + a top-level
`commands:` block **parses fine** (xdyn started, listened, ran). BUT see F10: in
co-sim the yaml `commands:` block is ignored; thrust is commanded via a ROS2 topic.

### F4 — Blender splash screen blocks the first viewport screenshot (WSLg/MCP)
**What bit:** first `get_viewport_screenshot` after launch returned the Blender splash
overlay, not the model. **Fix:** `bpy.context.preferences.view.show_splash=False` +
`save_userpref()` (done, persists for future launches). **→ skill?** one line in the
Blender-MCP gotcha note.

### F5 — `compdef:153: _comps: assignment to invalid subscript range` on sourcing
**What bit:** noisy zsh completion errors when sourcing setup_env.sh (ROS argcomplete).
Cosmetic, env still sources. **→ skill?** optional note; harmless.

### F6 — `gz sdf -k` cannot resolve `model://` includes ⭐
**What bit:** `gz sdf -k <world>` → `Error ... Unable to find uri[model://blueboat]
... Did you call sdf::setFindCallback()?`. The standalone validator has no resource
callback, so it ALWAYS errors on a world that `<include>`s a model. The model.sdf
itself validates ("Valid."). **Lesson:** validate the *model* with `gz sdf -k`; do NOT
gate the *world* on it — validate the world by actually spawning it. **→ skill?** yes,
run-and-verify.

### F7 — STL needs consistent outward normals for xdyn hydrostatics
**What bit:** xdyn warned `4 facets seem oriented inwards (body) while 20 outwards`.
Blender vertex edits (the bow taper) flipped some normals. **Fix:** in Blender, Edit
mode > `normals_make_consistent(inside=False)` before STL export. **→ skill?** yes,
mesh-generation note.

### F8 — never `set -u` before sourcing the ROS env
**What bit:** a verify script with `set -uo pipefail` died silently (exit 1, no output)
because ROS `setup.bash`/workspace setup references unbound vars under `set -u`. **Fix:**
source first, or drop `set -u`. **→ skill?** yes, shell gotcha (extends piège #4).

### F9 — LOTUSim worlds omit the SceneBroadcaster ⭐
**What bit:** `gz topic -l` listed no pose topics; the boat was invisible to the oracle
(and to the gz GUI). **Why:** LOTUSim worlds render in Unity (render_plugin) and don't
include `gz-sim-scene-broadcaster-system`, which is what publishes
`/world/<world>/{pose,dynamic_pose}/info` AND lets the gz GUI draw entities. **Fix:** add
`<plugin filename="gz-sim-scene-broadcaster-system" name="gz::sim::systems::SceneBroadcaster"/>`
to any world you want to render/measure in gz directly. **→ skill?** yes — pairs with the
"give the model a <visual>" note (both are needed for a self-contained gz render).

### F10 — co-sim THRUST comes from a ROS2 topic, NOT the yaml `commands:` ⭐⭐ (the big one)
**What bit:** with the yaml `commands:` block set to rpm 300, the boat barely moved
(0.009 m); xdyn warned "Wageningen ... Maybe n is too small?" = ~zero prop speed.
**Why:** `xdyn-for-cs` (co-sim) **ignores** the yaml `commands:` block. Thrust is
supplied by the gz client: `physics_interface_plugin` subscribes to
**`/<world>/vessel_cmd_array`** (`lotusim_msgs/msg/VesselCmdArray`); each `VesselCmd`
carries `vessel_name` + a `cmd_string` (JSON) that is forwarded verbatim to xdyn as
`data["commands"]` (see `xdyn_websocket.cpp`). With no publisher, the plugin's default
is `<thruster>(rpm)=2.0` → almost no thrust. **The waypoint_follower is NOT this
publisher** (F2 confirmed: it only emits status). **Fix / the real thrust source:**
publish a `VesselCmdArray` with `cmd_string = {"PSthruster(rpm)": 250, "SBthruster(rpm)":
250}` (a ~10-line rclpy node, `/tmp/pub_thrust.py`). **Result: 16.3 m in 16 s, ~1 m/s,
straight line.** **→ skill + frozen prompt?** YES — this is the single most important
correction. "Move a vessel under physics" = publish thruster commands on
`vessel_cmd_array`, not a yaml block, not a waypoint.

### F11 — xdyn co-sim command JSON schema
**What bit:** the exact `cmd_string`. **Answer (from `xdyn_websocket.hpp` docstring):**
keys are `"<thrusterName>(<param>)"`, params `rpm` / `P/D` / `beta`, e.g.
`{"PSthruster(rpm)": 250.0, "PSthruster(P/D)": 1.0}`. Thruster names must match the
world's `<thrusters>` AND the yaml actuator names. **→ skill?** yes, reference snippet.

### F12 — gz GUI `/gui/screenshot` service returns true but the PNG is elusive
**What bit:** service replied `data: true` but no file at the requested path; the
Screenshot plugin's save-path handling is unclear. GUI render itself is fine (no mesh
errors; `<visual>` loads). **Workaround for the video:** live screen-record, not a
scripted capture. **→ skill?** minor note; not blocking.
**UPDATE:** resolved — the `/gui/screenshot` request `data` must be a **directory**
(it writes a timestamped PNG inside), not a file path. With a dir it works.

### F13 — LOTUSim mesh convention: fore-aft along +y ⭐
**What bit:** the boat looked like it was "crabbing" — moving +y while pointing +x.
**Diagnosis (not physics):** course (travel) = 95 deg ( +y ), pose heading (yaw) = 3.6
deg ( +x ) -> 91 deg crab. The boat moves correctly toward its xdyn bow; only the
RENDER is 90 deg off. **Root cause:** LOTUSim authors vessel meshes **fore-aft on the
+y axis** (measured `fremm.dae`: x=24 m, y=142 m, z=49 m -> long axis = y). Our mesh
had the bow on +x. **Fix:** rotate the `<visual>` by +90 deg yaw
(`<pose>0 0 0 0 0 1.5708</pose>`) so the rendered hull aligns with the heading; the STL
(xdyn hydro, body-x = forward) and the yaml are untouched (physics was always fine).
Cleaner alternative for the PR: author the mesh fore-aft on +y from the start and set
`position of body frame relative to mesh` accordingly. **→ skill?** YES — house mesh
convention, saves the next contributor the same 90 deg hunt.

---

## ✅ Outcome of dry-run #1 — FLOATS + MOVES + RENDERS

- **Floats:** z (draft) stable at 0.062 m, ~1 mm sawtooth over the whole run. Hydrostatics
  from the closed-hull STL work; the boat neither sinks nor pops.
- **Moves:** 16.3 m in 16 s (~1 m/s avg, plausible vs the 3 m/s datasheet max), near
  straight line. Forward shows as gz **+y** (NED North -> ENU +y conversion). Proof:
  `/tmp/blueboat_verify/trajectory.png`.
- **Renders:** gz GUI loads the `<visual>` .dae with no mesh errors.
- **Pipeline exercised end to end:** Blender-MCP mesh -> SDF/yaml -> xdyn co-sim -> ROS2
  thrust -> displacement oracle -> trajectory plot.

---

## Candidate skill / frozen-prompt edits (proposed at the end, reviewed before write)

**lotusim-developer skill:**
- `run-and-verify.md`: **rewrite the thrust/verify section** — motion under physics is
  driven by publishing `VesselCmdArray` on `/<world>/vessel_cmd_array` (F10/F11), NOT the
  yaml `commands:` block and NOT the waypoint_follower; include the rclpy snippet and the
  `cmd_string` JSON schema. Add: world needs `gz-sim-scene-broadcaster-system` for a gz
  render + pose oracle (F9); the displacement oracle reads
  `/world/<world>/dynamic_pose/info`; `gz sdf -k` can't validate worlds with includes (F6).
- `model-world-anatomy.md`: correct the "waypoint_follower = thrust" framing (F2);
  waypoint is a separate KINEMATIC mode (no world composes it with physics). Add the
  SceneBroadcaster requirement next to the `<visual>` note.
- mesh note: STL outward-normals recalc (F7); Blender splash disable (F4).
- shell note (piège #4 family): don't `set -u` before sourcing (F8); quote `grep
  --include` globs (F1).

**frozen prompt (`docs/demo-blueboat.md`):**
- Replace the "register a waypoint_follower so it gets thrust" step and acceptance
  criterion #3 with: add a SceneBroadcaster, publish a constant-thrust `VesselCmdArray`,
  assert displacement on `/world/<world>/dynamic_pose/info` > 0.5 m, capture a trajectory
  plot. Note that the deliverable now includes a tiny thrust-commander node.
- The "Closed verification loop" section's `waypoint_follower drives the vessel` line is
  wrong → replace with the vessel_cmd_array path.
