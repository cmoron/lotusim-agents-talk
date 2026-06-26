# Prompt du record — voilier Focus V2 (slide 9)

Le prompt de démarrage du record agentique de demain, et nos **notes de production**
(hors-prompt). Adapté du *frozen prompt* BlueBoat (`docs/demo-blueboat.md`) à la
consigne 2026-06-27 : **voix d'un dev rodé aux agents mais néophyte LOTUSim**, on doit
**voir toutes les phases** (map → plan → loop → doc → ship), et l'agent **découvre seul**
la bonne répartition (le savoir interne n'est PAS dans le prompt — c'est le rôle du *map*).

Mesh : **produit par l'agent via Blender MCP** (pas de mesh officiel fourni). Le prompt
est en anglais (cohérent avec le deck + l'écosystème ; bascule en FR si tu préfères).

---

## Le prompt (à coller au démarrage, on caméra)

> **Goal.** I want to contribute a feature to **LOTUSim** (open-source ROS2 + Gazebo +
> xdyn maritime simulator, EPL-2.0): a small **RC sailboat — the Focus V2 — that rounds
> a race buoy**. End to end: the mesh, the physics model, the scenario, and the
> closed-loop helmsman. Success = from this freshly cloned workspace to **the sailboat
> rounding the mark**, delivered as clean PRs.
>
> I know agentic workflows well, but I'm **new to LOTUSim** — so don't take my word for
> the structure, **map it**.
>
> **1. Map first (don't guess).** Everything is cloned locally — the LOTUSim **core**,
> the **LOTUSim-generic-scenario** project, and the wiki. Work out: how a vehicle/model is
> defined and **where models live**; the closest existing analog to a small surface
> craft; how a vessel is driven **under physics** (who sends actuator commands, on what
> topic); and **where behaviours/scenarios live vs. where models live**. Report what you
> find (file:line), then tell me your plan.
>
> **2. Plan.** Propose 2 approaches with trade-offs and the placement you'd recommend per
> the project's own conventions. I'll pick one.
>
> **3. Build, in a loop.** Author an **original mesh in Blender** (you have the MCP) for
> the Focus V2 — hull, sails, rig, keel/bulb. Implement the model and the scenario, run
> it **with physics**, read the failures, fix, and repeat until the boat sails and rounds
> the mark. Respect what the map taught you (frame conventions, how commands are actually
> sent under co-simulation).
>
> **4. Document & ship.** Write the docs while the "why" is fresh. Open clean PRs — **one
> per target** — each with a clear scope and a **"real behavior proof"** (a headless run /
> trajectory showing it rounds the mark).
>
> **Honesty on physics:** the hydro/aero coefficients won't be tank-validated — estimate
> them, tune only enough to sail plausibly, and mark each
> `# ESTIMATED — pending naval-engineer validation`. Don't claim validated hydro.
> **Licensing:** EPL-2.0 — author everything from published dimensions, vendor nothing
> GPL or manufacturer-CAD.

---

## Notes de production (HORS-prompt — notre filet de dry-run)

Ce que le **map** doit faire émerger seul (si l'agent n'y arrive pas en dry-run, on
ajuste le prompt — pas le repo : la slide 9 promet « no prepared context ») :

**Répartition attendue (les 3 destinations, cf. `docs/demo-sailboat.md`)**
- **Modèle → core** `assets/models/focus_v2/` (`model.config`, `model.sdf` collision +
  `<visual>` + AIS, `focus_v2.yaml` xdyn, `meshes/`) + `assets/worlds/focus_v2_demo.world`
  (modèle : `circling_ship_example.world`).
- **Contrôleur + scénario → `LOTUSim-generic-scenario`** : package `src/agents/focus_v2/`
  (pattern `src/external_packages/lrauv_propeller/lrauv_propeller.py`) + config
  `src/simulation_run/config/focus_v2_course.json` (façon `defenseScenario.json`).
- Si le moteur ne commande pas d'actionneurs **à angle** (voile/safran) → patch
  `<control_surfaces>` dans `systems/physics_engine_interface` (à côté des `<thrusters>`).

**Pièges que le map/loop doit gérer (cf. skill `lotusim-developer`)**
- avant du mesh sur **+y** (sinon « crabe » 90°) ; normales STL vers l'extérieur ;
- le bloc `commands:` du yaml est **ignoré** en co-sim → consignes sur
  `/<world>/vessel_cmd_array`, clés `mainsail(sail)` + `rudder(angle)` ;
- `lotusim run` **ne lance pas** xdyn (serveur `xdyn-for-cs` séparé) ;
- le voilier **vire à tribord** (bâbord = no-go vers l'Ouest) → bouée **à l'intérieur** du
  virage ; `--sign -1`, P-control sur le **cap de route** (pas le heading).

**Mesh (Blender MCP)** : coque rouge, voiles blanches, espars carbone, bulbe plomb ;
export **OBJ** (rendu gz) + **STL** fermée normales-out (hydrostatique xdyn) ; pour Unity,
**FBX** baké (le `.dae` Blender 4.5 importe vide). Gotcha WSLg : fenêtre Blender
non-maximisée (`-p`).

**Guidage live (au Plan — PAS dans le prompt)** : tout étant cloné localement, le *map*
*peut* trouver `generic-scenario` seul. S'il reste sur le core, on l'oriente par une simple
relance au moment du Plan (« regarde aussi le projet generic-scenario, et comment ses agents
pilotent un vaisseau ») — interaction live, **sans** re-prompt ni fichier de contexte ajouté
au repo (cohérence slide 9 « no prepared context »).

**Dry-run off-camera (à faire avant le record)** : confirmer que le prompt produit (a) la
bonne arborescence (modèle in-core, harnais in-generic-scenario), (b) un run qui contourne
la bouée, (c) des PR propres. Ajuster le prompt si le map rate generic-scenario ou une
convention.

**Idée à explorer (hors record)** : un **MCP Unity** pour Claude Code (pendant du MCP
Blender) — piloter l'Éditeur/le rendu depuis l'agent. Vérifier les projets `unity-mcp`
existants.
