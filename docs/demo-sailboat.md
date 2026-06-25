# Démo slide-9 — voilier Focus V2 qui contourne une bouée dans LOTUSim

État : **gz-live fonctionnel, validé 2026-06-24.** Un voilier RC *Joysway Focus V2*
(classe « 1 mètre » / IOM, le bateau de la course étudiante **SWARMz**) **contourne
une bouée en co-simulation réelle xdyn + Gazebo**, piloté par un contrôleur en boucle
fermée. Le rendu se fait **dans LOTUSim / Gazebo** (le but de la slide est de
démontrer LOTUSim) ; Blender ne sert **qu'à créer le mesh** du bateau. Pour un rendu
« wow » (mer/lumières/shaders), la vraie voie est **Unity** (stack de rendu LOTUSim).

Physique du bateau : **OK mais pas parfaite** — modèle hydro/aéro *placeholder*, à
valider par les spécialistes naval (Sirhena / TVTInnovation). Cela colle à la thèse
slide 6 : *l'agent écrit la structure, l'ingénieur garde le modèle physique.*

## Rôle dans le talk

**Le voilier EST la contribution-démo** : c'est lui qui matérialise la thèse du talk
(« de l'idée à la PR, plus vite avec des agents ») — le sujet des slides **6**
(scénario : *ajouter un voilier qui contourne une bouée*), **8** (la loop sur le
voilier) et **9** (la vidéo démo). Le deck a été pivoté du *sonar* (exemple
hypothétique) vers ce voilier, le **vrai** truc qu'on a construit.

⚠️ **Ce run est un spike PRÉPARATOIRE.** Le but était de *pousser la verticale au plus
loin* pour voir jusqu'où on peut aller et avec quel effet « wow ». **La vraie vidéo sera
re-tournée de zéro**, en appliquant les enseignements ci-dessous (notamment : partir du
repo propre, viser le rendu gz/Unity, soigner le scénario bouée).

### Les 3 enseignements (à porter dans le talk)

1. **Les barrières d'entrée *software* tombent en quelques heures.** Installation,
   lancement, première implémentation, **premier bugfix** : l'agent fait entrer un dev
   dans LOTUSim sans la rampe habituelle. C'est le cœur de la démo (slide 9).
2. **Le gap *métier* reste.** La physique de l'environnement et des bateaux (hydro/aéro)
   demande l'expertise navale — c'est un mur *supplémentaire* que l'IA n'efface pas
   (elle peut assister, mais pour un dev sans connaissance en simu maritime, le gap
   reste élevé). → c'est désormais la carte **slide 10** (*« Software wall ≠ domain
   wall »*) + un beat oral.
3. **La puissance du « map » et de la loop agentique se voit sur le bugfix moteur**
   (ci-dessous). ⚠️ **À l'oral uniquement** (décision : hors slides) — speech §8/§9 +
   speaker-notes.

## Le bug moteur rencontré en route (illustration map + loop — ORAL)

> **Hors slides** (décidé 2026-06-25). Ce n'est pas la « contribution-démo » (c'est le
> voilier), mais **la meilleure illustration orale** de deux points du talk : la
> puissance du *map* (l'agent a cartographié un moteur C++ inconnu et y a levé un bug
> latent) et de la *loop* (caractérisé → corrigé → testé, en bouclant seul).

En implémentant le voilier, l'agent a **rencontré, caractérisé et corrigé un vrai bug
du moteur de co-simulation**, avec test de non-régression.

**Branche `demo/focus-v2` (fork `cmoron/LOTUSim`), 4 commits — outward-facing → PR
upstream `naval-group/LOTUSim` sous sign-off de Cyril (Lead Dev) :**

| Commit | Quoi |
|---|---|
| `30db417` | **feat** : `physics_engine_interface` supporte `<control_surfaces>` (actionneurs commandés en angle : safran, voile) en plus des `<thrusters>` — clés composites `<force model>(<angle command>)` |
| `8256296` | **fix** : corrige le **swap quaternion j/k** sur le retour d'état xdyn (`xdyn_websocket.cpp`, 2 lignes) |
| `4ce8ab1` | **feat(assets)** : modèle Focus V2 + monde de démo (visuels primitifs à ce stade) |
| `5849ab9` | **test** : extraction du (de)packing en helpers purs + gtest de non-régression round-trip |

### Le bug quaternion j/k (le find)

`XdynWebsocket::onMessage` reconstruisait le quaternion NED renvoyé par xdyn avec **Y et
Z (j et k) intervertis** : `Quaterniond(qr, qi, qk, qj)` au lieu de `(qr, qi, qj, qk)`.
L'émission packait correctement → émission et réception n'étaient **pas inverses**.
Conséquence : **un changement de cap pur (yaw) revenait en roulis** côté gz. Et comme en
co-sim xdyn réinitialise son état depuis l'état fourni à chaque pas, **le cap ne
s'accumulait jamais → tous les vaisseaux avançaient en ligne droite** (dead-reckon).
L'identité n'étant pas affectée, le bug était **invisible sur un BlueBoat allant tout
droit** — c'est le voilier (qui doit virer) qui l'a fait surgir.

**Preuves** : (1) test C++ standalone contre la vraie `gz::math` — code bugué : yaw 30°
→ roll −30° ; corrigé : round-trip exact. (2) Co-sim headless réel : cap **−199,8° en
25 s** (safran 0.35) après fix, vs +8° avant. Fix = 2 lignes.

### Le test de non-régression (la rigueur)

Plutôt qu'un fix inline opaque, le (de)packing a été extrait en **helpers purs**
`quatToXdynFields` / `quatFromXdynReply`
(`systems/physics_engine_interface/include/.../xdyn_serialization.hpp`), câblés dans
`getNewState`/`onMessage` (sortie prod **byte-identique**), avec un
`ament_cmake_gtest` `test/test_xdyn_serialization.cpp` (3 cas : round-trip identité yaw
0–175°, « le cap n'est pas perdu sur roll/pitch », cas mixte). Vérifié :
`colcon test` = **4 tests, 0 failure** ; régression co-sim préservée (−199,7° ≈ −199,8°).

> Réponse à *« un test unitaire l'aurait vu direct, non ? »* (Cyril) : **oui** — d'où le
> test. C'est exactement le garde-fou « real behavior proof » des contributions
> agent-assistées.

## Lancer la démo

```bash
~/lotusim_ws/sailboat_spike/run_course_gui.sh        # sign=-1 kp=1.0 par défaut
```

Le script : tue les `gz sim` / `xdyn-for-cs` / `ctrl_course` restants, démarre
`xdyn-for-cs` (modèle serré, port 12345, `--dt 0.05`), lance `gz sim` en GUI,
attend le handshake co-sim (`XdynWebsocket::onOpen`), puis lance le contrôleur.
Dans la GUI : **clic droit sur le voilier → Follow** pour une vue chase.

Le voilier monte vers la bouée, puis **l'enroule** (virage tribord, bouée à
l'intérieur), puis repart (pas d'arrêt terminal — il continue sur son erre).

## Architecture (rappel : co-simulation)

```
   xdyn-for-cs (serveur websocket, dynamique 6 DOF)   gz sim (rendu + orchestration)
   ws://127.0.0.1:12345  <──────────────────────────  physics_interface_plugin (client)
        ^  lit focus_v2.yaml                                  │ pose live
        │  voile = AeroPolarForceModel (vent apparent)        ▼
   ctrl_course.py ──VesselCmdArray /lotusim/vessel_cmd_array──┘  (barre + voile)
```

- **Physique = xdyn externe** (un serveur par vaisseau), PAS les plugins gz. `gz` seul
  ne suffit pas (sans xdyn : `loadVessel: Loading failed, Removing physics`).
- **Poussée/commandes** : publier sur `/lotusim/vessel_cmd_array`, clés composites
  `mainsail(sail)` + `rudder(angle)` (cf. skill `lotusim-developer`, piège n°6).
- **dt = 0.05 s** (le bateau léger 3.87 kg diverge à 0.2 s).

## Fichiers livrables (fork `~/src/LOTUSim/LOTUSim/`, **non commités**)

| Fichier | Rôle |
|---|---|
| `assets/models/focus_v2/model.sdf` | `<visual>` = mesh OBJ + `<pose>0 0 0 0 0 1.5708</pose>` (fix crabe), collision box, inertial (3.87 kg), capteur AIS |
| `assets/models/focus_v2/focus_v2.yaml` | modèle xdyn (voile/quille/safran/hydrostatique) |
| `assets/models/focus_v2/meshes/focus_v2.obj` + `.mtl` | **mesh rendu dans gz** (coque rouge, voiles blanches, espars carbone, bulbe plomb) |
| `assets/models/focus_v2/meshes/focus_v2.dae` | même mesh en COLLADA — **gardé pour Unity** (ne se rend PAS dans gz, voir gotcha) |
| `assets/worlds/focus_v2_demo.world` | mer plate, marque @ (2.3, 7.3), start @ (0,-2), `SceneBroadcaster`, plugins LOTUSim |

Harnais spike (`~/lotusim_ws/sailboat_spike/`, hors fork) :
`ctrl_course.py` (contrôleur), `run_course_gui.sh` (lanceur GUI live),
`run_course.sh` (lanceur headless + verdict ASCII), `focus_v2_demo.blend` (source mesh),
`runs/east_loop.poses.jsonl` (trace de référence).

## Le contrôleur (closed-loop)

`ctrl_course.py` — un seul process : `gz.transport13` lit la pose live
(`/world/lotusim/dynamic_pose/info`), `rclpy` publie barre + voile. **P-control sur le
cap de ROUTE** (direction de déplacement, pas le heading — le bateau dérive et l'axe
visuel est décalé). Suit une liste de waypoints. `--sign -1` (le +1 diverge),
`--kp 1.0`. Modèle = le **serré** (`focus_v2.yaml`, damping 5/1) : le closed-loop
fournit la stabilité, donc rayon de giration serré (~3 m).

Polaire de vitesse (mesurée standalone) : **no-go = cap Ouest** (~0.18 m/s), rapide =
Sud (1.0 m/s), reste ≥0.6. Ne jamais router une jambe vers W/NW.

## Les 3 problèmes résolus cette session

1. **Mesh invisible dans gz.** Le COLLADA `.dae` exporté par Blender ne se rend PAS
   (le `ColladaLoader` de gz-common échoue **silencieusement** : l'entité spawn, a une
   pose, mais zéro pixel, aucune erreur). → **Export OBJ+MTL** (chargé par assimp).
   Test : les primitives gz se rendaient, le mesh non → c'était bien le loader COLLADA.

2. **Crabe ~90°.** Mesuré sur le pose-log : crabe médian **+101,7°** = **+90° de
   décalage de repère** (xdyn met l'axe d'avance du vaisseau sur le `+y` du link, mais
   le mesh est modélisé étrave sur `+x`) **+ ~12° de dérive réelle** (gardée). →
   `<visual><pose>0 0 0 0 0 1.5708</pose>` (yaw +90°). Vérifié : `gz topic
   /world/lotusim/pose/info` → `focus_v2_visual` orientation `z:0.707 w:0.707`.

3. **« Tourne dans le vide ».** Le voilier tourne **forcément à tribord** (babord =
   vers l'Ouest = no-go, impossible). Avec la bouée à babord, il l'évitait. **Insight :
   la bouée doit être à l'intérieur du virage tribord.** La trajectoire a un winding de
   **−333° autour de (2.29, 7.34)** (quasi un tour complet). → **marque déplacée de
   (0,12) à (2.3, 7.3)** (le centre de la boucle qu'il trace déjà). Le world prévoyait
   ce réglage (« mark geometry provisional, adjusted once sailing direction is
   measured »).

## Gotchas runtime

- **Kill gz** : `pkill -f 'gz sim'` se suicide (le pattern matche le shell) ET les
  process résistent au SIGTERM → `kill -9 <PIDs>` ciblés (capturer les PID, filtrer
  `$$`). Dans un script dédié, `pkill -f 'xdyn-for-cs'|'gz sim'|ctrl_course` est OK
  (l'argv du script ne matche pas ces motifs).
- **Lancer en background** : un co-sim lancé en foreground via un outil shell tue le
  shell (exit 144). `setsid` + `set +e` dans le script.
- **Screenshots gz one-shot peu fiables** (caméra `/gui/follow` top-down d'orientation
  indéterminée, service screenshot qui rate si la GUI charge encore, bateau rapide).
  Pour un vrai rendu : **enregistrement vidéo**.

## État git (fork `cmoron/LOTUSim`, branche `demo/focus-v2`)

- **Commité** (4 commits, cf. tableau plus haut) : patch `<control_surfaces>`, fix
  quaternion, assets Focus V2 (visuels **primitifs**), test de non-régression.
- **NON commité** (working tree, cette session) : `model.sdf` (visuel = mesh OBJ +
  `<pose>` crabe), `focus_v2_demo.world` (marque déplacée), `meshes/` (OBJ/MTL/DAE).
  → à committer dans un commit « feat(assets): authored Focus V2 mesh + gz visual ».
- `M physics/xdyn` (mode exécutable) et `PR_ANALYSIS.md` / `US.xlsx` ne sont **pas de
  nous** — laisser tels quels.
- Rien n'est poussé ; rien sur l'upstream.

## Reste à faire

- **Enregistrer le clip** de la manche (gz `/gui/record_video` ou capture écran).
- **(Option) Unity** pour le rendu wow (mer/lumières/shaders) — vraie stack LOTUSim.
- **Tuning physique** placeholder (Sirhena / TVT) ; pas d'arrêt terminal du contrôleur.
- **Committer** le mesh/visuel de cette session, puis **décider la PR upstream**
  `naval-group/LOTUSim` (outward-facing → sign-off Cyril, Lead Dev). Le fix quaternion +
  test peuvent partir en PR **séparée** (bugfix moteur autonome, indépendant du voilier).
