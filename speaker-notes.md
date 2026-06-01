# Support de présentation — *From idea to LOTUSim contribution, faster with AI agents*

> Talk ~15 min · LOTUSim Technical Conference · Naval Group · 02/07/2026
> Notes perso (FR) à garder sous les yeux pendant la prez. **Slides en anglais, notes en français.**
> ⚠️ Ébauche — à retravailler / resserrer / chronométrer.

**Audience :** surtout des partenaires externes qui vont contribuer à la partie **open-source** de LOTUSim ; beaucoup ne sont **pas** experts agents IA.
**Ton :** concret, honnête, zéro hype. Jargon bas. On vend une méthode, pas un produit.
**Fil rouge :** la barrière d'entrée d'un simu robotique peut tomber d'un ordre de grandeur — sans sacrifier la qualité.

Budget ~15 min : intro 1' · contexte (3-7) 4' · méthode (8-14) 6' · démo 2' · limites/clôture 2'.

---

## 1 · Cover
- Me présenter en une ligne : Cyril, lead dev LOTUSim.
- La promesse du talk : *« comment des agents IA bien orchestrés font tomber la barrière d'entrée d'un simu ROS / Gazebo / Xdyn. »*
- Annoncer le format : 15 min, une méthode + une démo.

## 2 · Two kinds of « agents »
- Désambiguïsation rapide, importante pour cette salle (MAS / robotique).
- Dans **LOTUSim** : un agent = une plateforme simulée (drone, navire, sous-marin).
- Dans **ce talk** : un agent = *a large language model given tools* — il lit le repo, édite des fichiers, lance build/tests/git, voit le résultat, recommence.
- Punchline : **« the second kind of agent helps you build the first. »**

## 3 · The wall
- Contribuer à un simu robotique, c'est un mur, sur 3 axes :
  - surface technique (C++, CMake, ROS, Gazebo, SDF/URDF, Xdyn),
  - couplage physique (un capteur = modèle + message ROS + plugin + scénario),
  - conventions implicites jamais écrites dans le README.
- Message : *« beaucoup de bonnes idées meurent entre "je veux contribuer" et "ma PR est prête". »*

## 4 · Why now
- Pourquoi *maintenant* et pas il y a 18 mois ? 3 bascules fin 2025 :
  - modèles enfin fiables sur le tool-calling (Opus 4.5, GPT-5.2),
  - contextes longs (tout le codebase + docs en un coup),
  - **autonomie tenue par la boucle agentique** : *map → build → run → test → review*, en boucle jusqu'au vert.
- Insister : ce qui tient une tâche sur la durée, c'est la boucle, pas un prompt plus gros.

## 5 · The Linux kernel made the call  *(signal n°1 : légitimité)*
- Même le noyau Linux — communauté la plus conservatrice qui soit — a **tranché** et publié sa 1re politique officielle sur l'IA (`coding-assistants.rst`).
- Pas d'interdiction, pas d'évangélisme. **AI = just a tool**, responsabilité humaine **totale**, `Signed-off-by` reste humain.
- Nouveau trailer `Assisted-by:` (montre quel agent / modèle / outils). Exemple tiré tel quel de la doc kernel.

## 6 · OpenClaw  *(signal n°2 : échelle — SLIDE CLÉ, ~1.5 min)*
- OpenClaw : le projet open-source à la croissance **la plus rapide de l'histoire de GitHub**.
- Taille : **376 k stars**, **56 k commits** en 6 mois.
- Mode de travail : **~100 agents en parallèle** qui codent **et se reviewent entre eux**, chassent les failles, dédupliquent les issues.
- Le coût, à bien préciser : Steinberger **à lui seul** a brûlé **~1.3 M$ de tokens en un mois (avril 2026)** — financé par **OpenAI** comme recherche.
- Garde-fous humains : *real-behavior proof* sur chaque PR, 28+ mainteneurs qui signent.
- Le revers, qu'on assume : **~600 advisories de sécurité** en 6 mois → *le coût caché de la vitesse* (on y revient slide 16).

## 7 · What the pioneers learned
- 4 principes **portables**, indépendants de l'outil/vendor :
  - **Close the loop** — l'agent compile, exécute, teste son propre travail.
  - **Prompt > pull request** — la qualité de la demande prédit la qualité du résultat.
  - **Architecture > code review** — le débat humain monte d'un cran.
  - **The human signs** — pas de « dark factory », quelqu'un est responsable.

## 8 · Scenario — sonar sensor
- Cas concret qu'on va dérouler : **ajouter un capteur sonar à une plateforme sous-marine**.
- Volontairement non-trivial : touche **toute la stack** (physics / systems / interfaces / launch / docs).
- Objectif : de zéro connaissance du repo → une **PR prête à review**, en une session. *No magic, just method.*

## 9 · Five stages, five agent roles
- Ma méthode : 5 étapes, 5 rôles d'agents **spécialisés** (Map · Plan · Build · Doc · Ship).
- Pointer l'animation : un agent passe le relais au suivant — *specialisation = quality*.
- Bien préciser : *« une décomposition possible, pas une doctrine — adaptez à votre projet. »*

## 10 · Map
- Étape 1 : comprendre le codebase en **minutes**, pas en jours.
- L'agent parcourt l'arbre, suit les `#include`, situe les plugins Gazebo, répond *« où est câblé AUV → topic ROS ? »* avec fichier:ligne.
- Outils : Claude Code, docs Gazebo/ROS à jour via context7/MCP.

## 11 · Plan  *(là où le « taste » vit le plus)*
- Étape 2 : l'architecte **ne code pas**, il **propose** 2-3 stratégies avec trade-offs, risques, dette.
- Exemple à l'écran : option A (analytique) / B (ray-cast) / C (plugin tiers).
- Mon edge humain : **choisir** — vite, bien. *C'est la part qui ne se délègue pas.*

## 12 · Build  *(close the loop)*
- Étape 3 : ce qui change, ce n'est pas la vitesse de frappe, c'est **le cycle**.
- **L'agent** (pas moi) lance `colcon build` + le simu, lit l'échec, corrige. Je pilote **par exception**.
- **Local CI > remote CI** : l'agent voit l'échec en 12 s, pas en 10 min.

## 13 · Doc
- Étape 4 : documenter **pendant qu'on sait encore pourquoi** (documenter « plus tard » = jamais).
- Docs-as-code : même repo, même PR, même review ; l'agent reprend les décisions du Plan, génère un exemple notebook.
- La doc devient un **livrable de la session**, pas une dette.

## 14 · Ship  *(l'humain signe)*
- Étape 5 : process LOTUSim explicite — *issue labellisée → fork → PR → review*. Les agents l'exécutent à la lettre, **je signe**.
- Commit **transparent** sur l'assistance IA : `Assisted-by:` + `Signed-off-by:` (format emprunté au kernel).

## 15 · Demo
- De repo cloné à PR **en une session, ≈3 h** (timings réels, estimés : 25 Map / 20 Plan / 70 Build / 25 Doc / 20 Ship).
- [LIVE ou vidéo accélérée — à décider.]
- Message : **le code n'est pas jetable** — lisible, testé, documenté, aux conventions du repo.

## 16 · What I'm not selling you  *(honnêteté)*
- **Mind what's confidential** — l'open-source est public, le partager avec un agent est OK ; la prudence c'est le jour où le travail touche de l'**interne/classifié** → adapter la garde à la donnée. *(Ne pas faire peur : personne ici n'est obligé d'héberger des modèles locaux pour contribuer à l'open-source.)*
- Hallucinations (APIs Gazebo inventées) → build + tests = filet obligatoire.
- Supervision **pas optionnelle** (pas de « dark factory »).
- **Pas un substitut** : sans socle C++/ROS/physique, l'agent te fait juste foncer dans le mur plus vite.

## 17 · What it changes for LOTUSim
- La barrière d'entrée tombe d'**un ordre de grandeur**.
- Contributeur : *« des semaines avant ma 1re contribution »* → *« une PR utile dès la 1re session »*.
- Projet : plus de PR mieux préparées → moins de friction en review.
- Communauté : des profils qui n'auraient pas franchi le mur (chercheurs, intégrateurs, partenaires).
- Mainteneurs : le débat monte à l'architecture, pas le ligne-à-ligne.

## 18 · Close
- *« An open simulator. An augmented practice. »*
- Call to action : **clone the repo · ask an agent a question · pick an issue · come back with your first PR.**
- Merci — questions ?

---

## Prep Q&A (à garder en tête, pas sur slide)
- **Torvalds / kernel** : la citation a été retirée du deck ; son ton réel était plus sceptique (« the AI slop issue is NOT going to be solved with documentation »). Si on me cite la doc, l'assumer : la doc est *« for good actors »*, elle ne règle pas tout.
- **Sécurité OpenClaw** : ~600 advisories = argument pour *close the loop* + revue, pas contre l'approche. Vitesse sans garde-fou = dette de sécu.
- **Confidentialité défense** : si on me pousse, distinguer clairement *contribuer à l'open-source* (OK) vs *travailler sur de l'interne* (modèles self-hosted, séparation de contexte).
- **« L'IA va remplacer les devs ? »** : non — *taste & system design remain the ultimate moats* (Steinberger). L'humain choisit et signe.
- **Repo** : github.com/naval-group/LOTUSim.
