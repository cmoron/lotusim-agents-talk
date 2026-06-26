# Revue de contribution LOTUSim — « a-t-on fait dans les règles ? » (2026-06-26)

Vérification, sources à l'appui, de notre travail sur LOTUSim (modèle voilier Focus V2,
`render_interface`, `<control_surfaces>`, fix quaternion) **avant** d'en tirer une issue/PR.
Question motrice de Cyril : *les conventions d'orientation diffèrent entre Gazebo et Unity,
et les devs sont en prod sur Unity — ne pas régresser leur workflow standard pour faire
marcher Gazebo.* Réponse courte : **le fix d'orientation est un bug upstream, neutre vis-à-vis
de la convention, et ne régresse pas Unity.** Détail ci-dessous.

## 1. Le bug d'orientation (quaternion j/k) — VERDICT : sûr, c'est un bug upstream

**Le bug.** `systems/physics_engine_interface/src/xdyn_websocket.cpp`, `onMessage()` :
le quaternion renvoyé par xdyn était reconstruit en mettant les champs **nommés** `qj`/`qk`
dans les **mauvais slots positionnels** :

```cpp
auto ned_quad = gz::math::Quaterniond(
    reply["qr"]…, reply["qi"]…,
    reply["qk"]…,   // ❌ champ qk → slot j (Y)
    reply["qj"]…);  // ❌ champ qj → slot k (Z)
```

`getNewState` **envoyait** `(qr,qi,qj,qk)` mais `onMessage` **relisait** `(qr,qi,qk,qj)` :
envoi et réception non inverses → un yaw (autour de Z NED) revenait en roll → l'orientation
ne pouvait jamais s'accumuler entre pas de co-sim → le vaisseau avançait en ligne droite.
**Invisible à l'orientation identité** (d'où sa survie : les runs en ligne droite ne
l'exposent pas). Fix = restaurer `Quaterniond(qr, qi, qj, qk)` (commit `8256296`).

**C'est un bug de leur base, pas le nôtre.** `git blame` du parent de notre fix : la ligne
fautive vient du commit **`07107d7` « Release November 2025. » de Juliette Grosset**
(naval-group). Nos 3 commits (`30db417` control_surfaces, `8256296` fix, `5849ab9` test)
sont posés au-dessus.

**Pourquoi ça NE régresse PAS Unity** — pipeline tracé de bout en bout :

```
xdyn (qr,qi,qj,qk, repère NED)
  └─► onMessage()            ←★ LE BUG / NOTRE FIX (lecture de l'état physique)
        └─► quatNedToEnu()                      ← conversion NED→ENU, SÉPARÉE, intacte
              └─► pose de l'entité gz
                    └─► render_plugin → stream la pose gz VERBATIM
                    │      (ros_interface.cpp l.69-72 : pose.Rot().W/X/Y/Z(), aucune transform)
                    └─► Unity CoordinateSystemUtils.GzPoseToUnityPose()
                           (common.cs : position (x,z,y) ; rotation (-x,-z,-y,w) = Z→-Y FIXE)
```

- Le fix corrige l'**état physique partagé** lu depuis xdyn, **en amont** de tout rendu.
- La « différence d'orientation gz vs Unity » est **réelle et documentée** (le `Z→-Y` du
  `common.cs` Unity, cf. wiki *Core-Development*), mais elle vit **entièrement côté Unity,
  en aval**, et le fix ne la touche pas. La conversion NED→ENU est elle aussi séparée.
- Le bug corrompait donc gz **ET** Unity à l'identique (un vaisseau qui ne tourne pas, quel
  que soit le moteur de rendu). Le corriger rend **les deux** corrects.
- **Aucun hack gz-spécifique.** PR-safe. Test de non-régression déjà présent (`5849ab9`,
  round-trip 30° yaw), ce que leur culture CI exige.

## 2. Cross-check wiki — fait dans les règles

| Règle (wiki) | Notre travail |
|---|---|
| Quaternion `qr,qi,qj,qk` (*Xdyn-User-Guide*) | le fix le restaure exactement ✅ |
| NED + body Z-down + `rotations convention: [psi, theta', phi'']` | yaml conforme (l.14) ✅ |
| `position of body frame relative to mesh` (obligatoire) | présent (l.30) ✅ |
| Inertie + added mass au CoG, repère body | présents (l.63-78) ✅ |
| Surfaces de contrôle via `hydrodynamic polar` | mainsail + rudder (l.96-123) ✅ |
| `render_interface` / `renderer_type_name` | configuré comme documenté ✅ |
| model.sdf : collision (+ visual optionnel) + lotus_param | collision + visual (démo gz) ✅ |
| Transform gz↔Unity `Z→-Y` (*Core-Development*) | compris correct, inchangé ✅ |

Les « tu as peut-être oublié » du wiki (body-frame-relative-to-mesh, inertie complète) :
on **ne les a pas oubliés**.

## 3. État PR de chaque pièce (et risque « régression Unity »)

- **(A) Fix quaternion j/k** — bug upstream, code physique partagé, neutre. **SÛR pour issue+PR.**
  Contribution la plus forte ; test inclus.
- **(B) Support `<control_surfaces>`** (`30db417`) — additif (nouveau bloc *à côté* de
  `<thrusters>`), mais il **refactore le code partagé de construction des commandes**.
  ⚠️ Avant PR : **vérifier que le chemin « thrusters seuls » est inchangé** (un modèle
  propulseur-only doit toujours seeder `rpm=2.0 / P-D=0.79 / beta=0.0`).
- **(C) Fix double-`Start` Unity** (`LotusimConnector.cs`) — ⚠️ **le point sensible** : il est
  dans le **code de prod Unity** et on **n'a pas pu le valider end-to-end** (mur HDRP/Vulkan).
  Retire une souscription parasite en namespace vide. **Ne pas PR avant validation dans un vrai
  run Unity de prod.** Hors-sujet pour la démo (on ne livre pas Unity).
- **(D) Modèle focus_v2 + worlds** — assets additifs. Le `<visual>` ajouté pour la démo gz
  **ne régresse pas Unity** (Unity rend via son prefab, ignore le visual gz). Sûr.

## 4. Le walkthrough : `LOTUSim-generic-scenario` le couvre

Le *Getting-Started* du wiki est léger, mais le repo **`naval-group/LOTUSim-generic-scenario`**
couvre l'essentiel du walkthrough end-to-end :
- **installeur automatisé** `install_core_and_generic_scenario.sh` (détecte Ubuntu→ROS,
  clone le core dans `~/lotusim_ws`, configure `.bashrc`, `lotusim install`, build) ;
- **run config-driven** : `scenario_launch.sh --config defenseScenario.json`, spawn d'agents
  (formats de pose initiale documentés), **contrôle propulseurs via topic ROS** ;
- **doc archi** `doc/DIAGRAMS.md` (package tree, class/sequence diagrams, nodes/topics/actions) ;
- un **Player Unity Linux prébuildé** (`lotusim_unity_executables/lotusim_scenario_linux/` :
  `lotusim_scenario.x86_64` + `UnityPlayer.so` + `_Data`), dont la scène = **`defenseScenario`**
  (celle qu'on a tenté d'ouvrir dans l'Éditeur).

→ Donc la « lacune walkthrough » que j'avais notée est à **nuancer** : elle existe dans le wiki
*core*, pas dans l'écosystème (le repo generic-scenario + sa `DIAGRAMS.md` la couvrent). C'est
surtout un problème de **découvrabilité** (le Getting-Started ne pointe pas clairement dessus).

**Note Unity (rétrospectif) :** le Player prébuildé aurait été une **sonde Vulkan bien plus
rapide** que l'Éditeur (pas d'install 5 Go, pas d'import) — mais il rend du HDRP, donc il
heurte **le même mur lavapipe** sous WSLg (Unity refuse un device Vulkan CPU → fallback OpenGL
→ HDRP KO). Conclusion inchangée : Unity-dans-WSL exige **Dozen** (cf. `unity-vertical.md`).

## 5. Trous du wiki qui restent — matière pour le talk (slide 11 « homework »)

Même avec generic-scenario, le wiki **ne documente pas** : un guide de validation/debug des
**transforms de coordonnées** (exactement le bug qu'on a touché), ni le **bug j/k lui-même**
(latent dans leur release, ni doc ni test ne l'attrapaient). Un contributeur externe, avec
agents, a trouvé un **bug upstream latent** que leur propre CI ne couvrait pas → renforce la
thèse « docs-as-code agent-readable + tests ». Bon matériau oral (map + la loop sur le bugfix).
