# Runbook — enregistrement de la démo (contributeur neuf, tout live, macOS)

But : filmer le **parcours complet d'un contributeur neuf** sur LOTUSim, **tout en
live** sur **macOS M2**, montrant que les barrières (install, lancement, 1ʳᵉ feature,
1ᵉʳ bugfix, PR) **tombent** avec un agent. LOTUSim **conteneurisé** (gz/xdyn), **Unity
natif** (Metal). Coupes / reconstruction en post **autorisées** (on sécurise chaque
étape, pas une prise parfaite). Cible deck : slide 9 *« Recorded on the repo as it is
today: no AGENTS.md, no prepared context »*.

## Politique « cold start » (crédibilité)

- **Base repo = upstream `naval-group:main`, VIERGE** — ni `AGENTS.md`, ni `CLAUDE.md`,
  ni contribution prépa. C'est la promesse du deck, tenue côté repo.
- **Workspace neuf `~/src/lotusim-record/`** → mémoire Claude Code **vide** par
  construction (la mémoire est par-dossier-projet).
- **Skill `lotusim-developer` GARDÉ actif** (décision Cyril, 2026-06-27, assumé « un peu
  triché ») — c'est l'**expertise de l'agent**, pas du contexte repo ; le repo reste
  honnête.
- **Distinction clé** : **outillage/environnement** (MCP Unity, image conteneur,
  Blender, OBS) = **autorisé** (= l'IDE du dev) ; **contribution** (modèle focus_v2, fix
  moteur, contrôleur, scène Unity) = **absente** de la base de départ.
- **Filet hors-caméra** : backup `cmoron/lotusim-focus-v2-spike` (privé) + le skill, dans
  un autre terminal, pour récupérer/retaker si une prise cale.
- ⚠️ **Tension narrative à arbitrer** : le skill **documente déjà** le bug quaternion et
  le piège `GameManager` (2 des « 6 pièges »). Skill actif ⇒ l'agent ne les **découvre**
  pas, il les **connaît** → le beat « map + loop : tombe sur un bug, le résout » devient
  « expert qui évite des pièges connus ». Option si on veut garder le *find* authentique
  sur le bug moteur : désactiver le skill **pour ce segment précis** (étapes 4/6), skill
  réactivé pour le reste. À trancher avec Cyril.

## Repos — base de départ vs cible de push

| Repo | Base départ (record) | Fork (push au ship) | État vérifié 2026-06-27 |
|---|---|---|---|
| core `LOTUSim` | `naval-group:main` | `cmoron/LOTUSim` (existe) | fork `main` = upstream **+5 commits CI SonarCloud** (PAS la contrib) → on part d'upstream = vierge |
| `LOTUSim-generic-scenario` | `naval-group:main` | **à forker** | contrib (contrôleur) dans le backup, pas dans le repo → vierge |
| `LOTUSim-Unity-modules` | `naval-group:main` | `cmoron` (existe, `main` == upstream) | fixes locaux **non poussés** → vierge ; re-ajouter le MCP (outillage) |

Deps **runtime non modifiées** (pas à forker pour éditer) : `LOTUSim-Xdyn`,
`LOTUSim-Unity-custom-hdrp`, `LOTUSim-Unity-ros-tcp-endpoint` — embarquées dans l'image
conteneur / les packages Unity.

## Setup à exécuter (avant le tournage)

1. `gh repo fork naval-group/LOTUSim-generic-scenario` (garder le fork).
2. Dossier `~/src/lotusim-record/` : **clones FRAIS** des 3 repos, `origin` = fork cmoron,
   `upstream` = naval-group, branche de travail partant de **`upstream/main`**.
3. **Vérifier chaque arbre = vierge de contribution** (aucun `focus_v2`, aucun fix moteur,
   aucun `AGENTS.md`/`CLAUDE.md`).
4. Unity : re-ajouter le **package MCP** (outillage) au clone neuf + `Window › MCP For
   Unity › Auto-Setup` + `Start Bridge`. Image conteneur déjà *pull*.
5. Préparer la **scène OBS** (plein écran 1080p : terminal + Blender + Unity + navigateur
   GitHub).
6. **Sanity hors-caméra** : lancer une fois le conteneur gz pour confirmer qu'il tourne sur
   ce Mac (l'image `ghcr.io/naval-group/lotusim` est présente) — dernier maillon non encore
   prouvé du pipeline.

## Arc du record (tout live)

1. **Cold open** — un dev clone l'upstream LOTUSim sur un Mac.
2. **Install + lancement** ⟵ *la barrière qui tombe* : l'agent map, découvre l'absence de
   support macOS natif, bascule sur le conteneur fourni, build/pull, lance gz.
3. **Voilier focus_v2** — mesh dans **Blender (blender-mcp)**, modèle xdyn, monde.
4. **Bug moteur quaternion** — rencontré, caractérisé, corrigé, testé ⟵ *map + loop*.
5. **Dérisquage gz** — le voilier enroule la bouée.
6. **Déploiement Unity natif** (wow Metal) — scène via MCP, navigue le piège `GameManager`.
7. **Ship** — `gh repo fork` + PR (core + generic-scenario) + **issue** pour le bug.

## Capture

OBS plein écran **1920×1080**, coupe/reconstruction en post. **Unity Recorder** dispo pour
les plans HDRP propres (rendu interne, sans scaling). Speed-up post : `ffmpeg -vf
"setpts=0.25*PTS"`.

## Filet de sécurité (hors-caméra)

- Backup spike `cmoron/lotusim-focus-v2-spike` (privé) : modèle, fixes, contrôleur, mesh
  source `.blend`, traces de référence (`runs/`).
- Skill `lotusim-developer` (les 6 pièges) dans un autre terminal.
- Si une prise cale → consulter le filet, refaire **le segment** (pas tout).

## Outillage déjà sécurisé (2026-06-27)

- **MCP Unity** (CoplayDev v9.7.3) — compile dans le projet Unity, serveur `uvx` buildé.
- **blender-mcp** (v1.6.4) + **Blender 4.5.10 LTS** — serveur `✔ Connected`, addon dans
  `~/Downloads/blender-mcp-addon.py`.
- **OBS 32.1.2** + **ffmpeg 8.1.2**.
- Image conteneur `ghcr.io/naval-group/lotusim` + `lotusim:focus-v2*` présentes.

## Montage de la vidéo slide 9 (2–3 min, vitesse mixte)

**Cible** : un `.mp4` **1080p**, **~3 min**, à embedder dans la slide 9 (`.videoframe`,
cf. commentaire `⚠️ EMBED` dans `index.html`). Slide 9 annonce déjà le format :
*« sped up throughout, back to real time on the moments that matter »*.

**Principe** : le défaut, c'est l'**accéléré** (6–8×) ; on **revient à 1×** seulement sur
**3–4 « beats héros »** (~10–15 s chacun, ~45–60 s de 1× au total). Le reste file. Pas
besoin que le texte du terminal soit lisible en accéléré — c'est le **momentum** qui compte,
tu narres en live (speech §9 : tu parles peu, tu ponctues « map… plan… build… docs… the PR »).

**Les 2 moments humains DOIVENT être lisibles (1×)** — c'est ta thèse :
- **Plan → « I choose »** (les 2 stratégies, tu tranches),
- **Ship → « I sign »** : la **page PR GitHub** avec les trailers visibles
  (`Assisted-by: Claude Opus 4.8…` + `Signed-off-by: Cyril Moron`).

**Timeline indicative (~3:00)** — colle aux badges map·plan·build·doc·ship :
| t | segment | vitesse | note |
|---|---|---|---|
| 0:00–0:12 | Cold open : `git clone naval-group/LOTUSim` sur Mac vierge | 1× | montre le repo « as it is today » (pas d'AGENTS.md) |
| 0:12–0:35 | **MAP** : clone core+generic-scenario+wiki, grep, report file:line | 6–8× | **héros 1× (~8 s)** : il nomme l'analogue + la répartition core/scenario |
| 0:35–0:50 | **PLAN** : 2 stratégies, trade-offs, *I choose* | 1×/2× | moment humain, lisible |
| 0:50–1:40 | **BUILD** : mesh Blender, modèle+world, colcon, run, échecs, fixes | 8× | **héros 1× (~12 s)** : le bug quaternion caractérisé + le test de régression qui passe |
| 1:40–2:05 | dérisquage gz : le voilier navigue | 4×→1× | transition vers le wow |
| 2:05–2:35 | **Unity HDRP** : scène, spawn | 4× | **héros 1× (~15 s)** : le voilier **enroule la bouée** (le payoff, laisse respirer) |
| 2:35–2:55 | **DOC + SHIP** : page de doc, `gh pr create`, la PR sur GitHub | 6× | **1× (~5 s)** sur les trailers `Assisted-by` + `Signed-off-by` |
| 2:55–3:00 | end card : freeze sur le voilier ou la PR signée | — | |

**Pas d'honnêteté à l'écran** (le « bricolage / mur du domaine » est porté par slide 10 +
l'oral, décision actée). Sous-titres d'étape (map/plan/build/doc/ship) **optionnels** —
ils renforcent les badges de la slide.

**Outil recommandé : DaVinci Resolve** (gratuit, Mac) — la vitesse variable y est triviale :
clip → *Change Clip Speed* (vitesse fixe) ou touche **R** (*Retime Controls*) pour des rampes
1×↔8×. Assemble les rushes dans l'ordre de la timeline, retime chaque segment, exporte 1080p.

## Pipeline réel — automatisé, construit 2026-06-28 (`video/montage/`)

Les 6 rushes OBS sont dans `video/` (1660×1080 @ 60fps, ~952 MB, **gitignorés**) :
`1-prompt-map-blander-agentic-loop.mov` (1h46 : MAP/loop + Blender + bug + tests),
`2-prepare-unity.mov` (16min), `3-unity_manual_fix_mesh.mov` (14min),
`4-unity_first_run.mov` (79s, 1er run debug), `5-unity_run_fixed.mov` (79s, **le payoff**),
`6-ship.mov` (23min : issues/PR + pages GitHub).

**Un seul script assemble tout** : cut + vitesse variable (`setpts`) + cartouches PNG
(`overlay`), puis concat. ffmpeg Homebrew **n'a pas `drawtext`** → les overlays sont des PNG
rendus par ImageMagick (`make_badge.sh`), aux couleurs du deck (bleu = machine, **orange =
décision humaine**, vert = TEST). Badges = rôles du relais (Cartographer/Architect/Companion/
Writer/Reviewer).

```bash
# (re)générer les cartouches (déjà faites dans video/montage/badges/) :
#   bash video/montage/make_badge.sh "MAP" "Cartographer · reading the repos" "#4D9BFF" badges/01_map.png
# rendre la vidéo (édite la TABLE en haut de montage.sh pour nudger les in/out) :
bash video/montage/montage.sh           # -> video/_build/slide9_demo.mp4 (~2:51)
# re-scanner un rush en planche-contact horodatée (pour retrouver un timestamp) :
bash video/montage/make_sheet.sh video/5-unity_run_fixed.mov 4 5 /tmp/sheet5.png
```

La **TABLE** (une ligne par segment : `FILE|IN|LEN|SPEED|BADGE|HOLD|TPAD`) est la seule chose
à éditer. Hero = `SPEED=1` ; thinking = `SPEED=100..130`. Render ≈ 4 min (M2, décodage HW).
Draft courant : `video/_build/slide9_demo_v1.mp4` (2:51).

**À nudger avec les yeux de Cyril sur les rushes** (mes IN/LEN du draft sont des estimations
sur F1, le gros fichier) :
- ⚠️ **PLAN « I choose »** (ligne 2 de la table, `F1|1600`) tombe pile sur l'ouverture de
  Blender → **pointer le vrai moment de décision** (où tu tranches entre 2 stratégies).
- **mesh Blender** (`F1|1860`), **diff** (`F1|3000`), **test vert** (`F1|3840`) : régions
  bonnes, à resserrer au plus beau plan.
- **payoff** (`F5|36|24`) : ajuster pour cadrer l'enroulement de bouée le plus net.
- **PR signée** (`F6|1290|16`) : viser la page où `Assisted-by` + `Signed-off-by` sont lisibles.

**Alternative manuelle : DaVinci Resolve** — si tu préfères retimer à la main (touche **R**,
rampes 1×↔8×) ; même structure que la TABLE. Pour des plans HDRP propres (sans scaling
d'écran), **Unity Recorder** plutôt qu'OBS.
