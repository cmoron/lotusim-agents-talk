# Démo Unity « wow » sur macOS — runbook + pièges (validé 2026-06-26)

But : le rendu **Unity HDRP** du voilier Focus V2, piloté par la **co-simulation LOTUSim
(xdyn + Gazebo)**, **sur Mac (Apple Silicon, Metal)** — ce que WSL ne pouvait pas faire
(mur Vulkan/HDRP). Le pivot est **prouvé end-to-end le 2026-06-26** : un bateau bouge en
live sur la mer HDRP d'Unity, sa pose venant du conteneur.

> ## ⚠️ LE PIÈGE À NE JAMAIS REFAIRE — bypasser le login/redirection du scénario
>
> La scène `defenseScenario` **n'est pas jouable seule**. À `Play`, `GameManager.Start()`
> voit `!PhotonNetwork.IsConnected` et fait `SceneManager.LoadScene("Launcher")` →
> **recharge la scène et DÉTRUIT le `LotusimConnector`** (le récepteur de rendu) une frame
> après le Play. Résultat : le pont se connecte, souscrit… mais **le CREATE n'est jamais
> instancié → aucun bateau**, en mode ROS2 **comme** TCPUDP. Ça nous a coûté des heures
> car ça se déguise en « bug de relaye ». **TOUJOURS bypasser ça avant un run** (cf. §5.7).

---

## 1. Architecture (le mental model)

```
Docker Desktop (VM Linux amd64, émulée Rosetta)            macOS natif (Metal)
  xdyn-for-cs (binaire x86-64) ──ws://127.0.0.1:12345──► gz sim -s -r (headless, sans GPU)
        ^ lit focus_v2.yaml                               ├ physics_interface_plugin (client xdyn)
        │                                                  ├ render_plugin (connection=ROS2)
        │                                                  │     └► /<world>/renderer_cmd  (CREATE, transient_local)
        │                                                  │        /<world>/renderer_poses (poses, 20 Hz)
        │                                                  └ ros_tcp_endpoint ──TCP :10000──►  Unity Editor
        │   découverte DDS intra-conteneur = SHM            (port exposé -p 10000)             (LOTUSim-Unity-modules)
        │                                                                                       ├ RosInterface (ROS-TCP-Connector)
        │                                                                                       ├ LotusimConnector → Addressables
        │                                                                                       └ mer HDRP rendue sur Metal
```

Points clés :
- **Toute la stack ROS/gz/xdyn tourne DANS le conteneur, headless, sans GPU.** Le seul
  GPU utilisé = le Metal du Mac pour Unity. C'est ça qui débloque WSL (qui butait sur
  Vulkan/HDRP).
- **Émulation amd64 (Rosetta), pas arm64 natif** : les binaires xdyn (`physics/xdyn-for-cs`,
  …) sont des **ELF x86-64 versionnés dans le repo** — pas de source xdyn dans le core
  (elle est dans `naval-group/LOTUSim-Xdyn`, mais la rebuilder arm64 = boost/eigen/ssc,
  hors-scope). Donc image **amd64 sous Rosetta**. Rosetta tient une co-sim mono-bateau à
  20 Hz sans problème.
- **Le pont** : `ros_tcp_endpoint` (nœud ROS2 Python, dans le conteneur) relaie le graphe
  ROS2 vers une **socket TCP** ; Unity (ROS-TCP-Connector) s'y connecte sur `localhost:10000`.
  Tout le DDS reste dans le conteneur ; une seule connexion TCP traverse vers le Mac.

## 2. Prérequis

- **Docker Desktop** (Apple Silicon), démarré. Émulation amd64 (Rosetta) activée — vérifier :
  `docker run --rm --platform linux/amd64 alpine uname -m` → `x86_64`.
- **Unity Hub + Editor `2022.3.62f2` (Apple Silicon)** — révision qui patche le CVE
  (le projet épingle `2022.3.18f1` dans son README ; ouvrir avec 62f2 = même LTS,
  upgrade sûr).
- **Fork de travail** : `cmoron/LOTUSim` (core, branche `demo/focus-v2`) et
  `cmoron/LOTUSim-Unity-modules`. ⚠️ Cloner Unity **avec `--recurse-submodules`**
  (`Submodules/custom-hdrp`, `Submodules/ROS-TCP-Endpoint`). En pratique le manifest tire
  **HDRP 14.0.12 du registry** et **ROS-TCP-Connector depuis git**, donc les submodules
  vides ne bloquent pas le rendu — mais c'est plus propre de les avoir.
- **Repos** (org `naval-group`) : seuls nécessaires = `LOTUSim` (forké) + le conteneur
  embarque déjà `ros_tcp_endpoint`. `LOTUSim-Xdyn` = fallback arm64 (non requis).
  `LOTUSim-generic-scenario` (player Linux prébuildé) ne tourne pas sur Mac.

## 3. Construire les images (une fois)

Contexte de build = le fork core (`lotusim-focus-v2-spike` / `cmoron/LOTUSim`). Les fichiers
sont dans `~/src/lotusim-private/lotusim-macos-demo/` :

```bash
cd ~/src/lotusim-private/lotusim-macos-demo

# Image de base upstream (amd64, ~6.3 GB) — pull une fois
docker pull --platform linux/amd64 ghcr.io/naval-group/lotusim:latest

# Couche focus-v2 : overlay du fork (1 SEUL package C++ à recompiler + assets)
docker build --platform linux/amd64 -t lotusim:focus-v2 \
  -f Dockerfile.focus-v2 ~/src/lotusim-private/lotusim-focus-v2-spike

# Couche bridge : + ros_tcp_endpoint (package Python, build instantané)
docker build --platform linux/amd64 -t lotusim:focus-v2-bridge \
  -f Dockerfile.bridge ./vendor/LOTUSim-Unity-ros-tcp-endpoint
```

Pourquoi un overlay et pas un full build : le **diff fork↔upstream** ne touche qu'**un**
package ROS (`systems/physics_engine_interface` : `<control_surfaces>` + fix quaternion) ;
tout le reste = des **assets** (modèles, worlds). D'où `FROM lotusim:latest` + COPY +
`colcon build --merge-install --packages-select physics_engine_interface`.

## 4. Lancer (séquence qui marche)

L'ordre **compte** (cf. pièges §5.4 et §5.5). Le conteneur **attend** qu'Unity se connecte
**avant** de démarrer gz, et tourne avec **SHM** :

```bash
# 1. Démarrer le backend (endpoint idle, en attente d'Unity ; SHM ; world = defenseScenario/wamv)
cd ~/src/lotusim-private/lotusim-macos-demo
docker run -d --name fv2demo --platform linux/amd64 -p 10000:10000 \
  -e PYTHONUNBUFFERED=1 -e FASTDDS_BUILTIN_TRANSPORTS=DEFAULT \
  -e WORLD=world_defense.world -e WAIT_UNITY=600 \
  -v "$PWD":/work \
  -v "$PWD/world_defense.world":/lotusim_ws/src/LOTUSim/assets/worlds/world_defense.world \
  lotusim:focus-v2-bridge bash /work/run_demo.sh

# 2. Dans Unity : ouvrir defenseScenario, vérifier les patches (§5.7), puis Play.
#    -> le conteneur détecte la connexion, démarre xdyn+gz, le bateau spawn.

# 3. Caméra Game : cliquer la Game view, flèches ←/→ pour cycler la cible jusqu'à focus_v2.

# Suivre : docker logs -f fv2demo   |   Arrêter : docker stop fv2demo
```

Vérifs santé conteneur :
- endpoint : `Connection from 192.168.65.1` puis `RegisterSubscriber(defenseScenario/renderer_cmd…)`
- co-sim : `RenderPlugin::PreUpdate: Creation detected of vessel named focus_v2`,
  `XdynWebsocket::onOpen`, `physics in domain Surface init completed`
- match pub/sub (après ~2 s, la 1ʳᵉ requête est souvent un faux négatif de découverte) :
  `ros2 topic info /defenseScenario/renderer_cmd` → `Publisher count: 1 / Subscription count: 1`

## 5. Les problèmes rencontrés — symptôme → cause → fix

### 5.1 Pas de rendu GPU / arm64 natif impossible pour la physique
- **Symptôme** : tentation de builder l'image en arm64 natif (plan initial CLAUDE.md).
- **Cause** : `physics/xdyn-for-cs` & co sont des **ELF x86-64** versionnés (pas de source).
- **Fix** : image **amd64 sous Rosetta**. `--platform linux/amd64` partout. Pas de GPU dans
  le conteneur (gz `-s` headless ; le rendu est sur le Mac).

### 5.2 `colcon build` échoue : « install dir created with merged layout »
- **Cause** : l'image upstream a été buildée avec `--merge-install`.
- **Fix** : ajouter `--merge-install` à notre `colcon build` (déjà dans `Dockerfile.focus-v2`).

### 5.3 Plugins gz « No plugins detected in library »
- **Cause** : `bash -lc` (login shell) **ne source pas** `~/.bashrc` → `install/setup.bash`
  du workspace non sourcé → `LD_LIBRARY_PATH`/`GZ_SIM_SYSTEM_PLUGIN_PATH` absents.
- **Fix** : sourcer explicitement `/opt/ros/jazzy/setup.bash` **et**
  `/lotusim_ws/install/setup.bash`, puis `export GZ_SIM_SYSTEM_PLUGIN_PATH=$LOTUSIM_WS/install/lib`
  et `GZ_SIM_RESOURCE_PATH=$LOTUSIM_MODELS_PATH` (cf. `run_demo.sh`).

### 5.4 Endpoint Python : `accept()` affamé sous charge (Unity ne peut pas se connecter)
- **Symptôme** : Unity « Connection failed / ThreadAbortException » ; côté endpoint **0
  `Connection from`** alors que le port répond à `nc`.
- **Cause** : `ros_tcp_endpoint` est **mono-thread Python** ; une fois gz qui inonde le
  graphe (poses 20 Hz + découverte DDS), le **GIL** étrangle la boucle `accept()`. (Endpoint
  **seul, sans gz** → `nc` passe instantanément. Test décisif.)
- **Fix** : **connect-first** — l'endpoint **attend** qu'Unity se connecte à l'endpoint *idle*
  (accept libre), **puis** on démarre gz. Une connexion **déjà établie** n'est pas affectée
  par la famine d'accept. (`run_demo.sh` poll `Connection from` avant de lancer xdyn+gz.)

### 5.5 Découverte DDS abonné-avant-publisher cassée (0 message livré)
- **Symptôme** : Unity connecté + souscrit, mais **aucun message** (`ros2 topic info` →
  `Publisher count: 0` alors que `ros2 topic hz` reçoit — incohérence = découverte flaky).
- **Cause** : le Dockerfile upstream pose **`FASTDDS_BUILTIN_TRANSPORTS=UDPv4`**, ce qui
  **désactive le SHM**. En connect-first, l'endpoint souscrit **avant** que les publishers gz
  existent ; sans SHM, le multicast UDP en loopback ne matche jamais l'abonné au publisher tardif.
- **Fix** : **`FASTDDS_BUILTIN_TRANSPORTS=DEFAULT`** (réactive SHM). Test : un abonné créé
  *avant* gz reçoit 379 msgs avec DEFAULT, 0 avec UDPv4.

### 5.6 Socket Unity zombie → proxy Docker Desktop coincé
- **Symptôme** : après un restart de conteneur, Unity « connecté au proxy » (`ESTABLISHED`
  en `lsof`) mais l'endpoint ne voit rien ; nouvelles connexions ne passent plus.
- **Cause** : la **`ROSConnection` d'Unity persiste à travers Stop/Play** (singleton). Quand
  on tue le conteneur, le socket reste en `CLOSE_WAIT` côté Unity / `FIN_WAIT_2` côté proxy →
  le proxy userspace de Docker Desktop reste coincé sur le port 10000.
- **Fix** : **quitter complètement Unity (Cmd+Q) puis rouvrir** pour libérer le socket ;
  éviter les restarts de conteneur rapprochés pendant qu'Unity est connecté. (Repartir d'une
  scène stable — §5.7 — supprime le besoin de restarts.)

### 5.7 ⭐ LE BLOQUEUR : redirection de scène `GameManager` détruit le récepteur de rendu
- **Symptôme** : pont parfait (connexion, souscriptions, CREATE publié, abonné matché) mais
  **`focus_v2` jamais instancié**, ni en ROS2 ni en TCPUDP. En ROS2 le `RosInterface`
  (singleton) survivait et masquait le problème ; en TCPUDP le `TCPIPInterface` démarrait
  puis `Destroy()` immédiatement (« TCP Listener stopped »).
- **Cause** : `GameManager.Start()` (`Assets/Scripts/MultiUser/GameManager.cs`) :
  ```csharp
  if (!PhotonNetwork.IsConnected) { SceneManager.LoadScene("Launcher"); return; }
  ```
  En jouant `defenseScenario` **seule** (sans flow Photon), Photon n'est pas connecté →
  **rechargement de scène → destruction du `LotusimConnector`** (qui exécute
  `ProcessCreateCmds` et **instancie le prefab**). Le « formulaire de login » qu'on voyait
  au début = l'UI du **Launcher** (le vrai point d'entrée).
- **Fix (démo)** — bypasser la redirection : remplacer le `LoadScene("Launcher")` par un
  simple `return` (reste dans la scène + skip le setup joueur Photon) :
  ```csharp
  if (!PhotonNetwork.IsConnected) { return; }   // DEMO BYPASS
  ```
  *(Alternative « propre » : passer par la scène `Launcher` en mode offline
  `PhotonNetwork.OfflineMode = true`, qui charge `defenseScenario` avec Photon connecté.)*

### 5.8 Bugs upstream trouvés et corrigés en route (candidats PR)
1. **double-`Start`** dans `LotusimConnector.cs` : `CreateInterface()` appelle déjà
   `iface.Start("")`, puis `Start()` rappelle `m_interface.Start(m_namespace)` →
   interface démarrée 2× (namespace vide puis le bon), churn de socket. **Fix** : passer
   `m_namespace` à `CreateInterface(...)` et supprimer le second `Start`.
2. **transport DDS** (§5.5) : `UDPv4`-only casse la découverte intra-conteneur → `DEFAULT`.
3. (interne) le `connection_protocol=TCPUDP` du `render_plugin` est fonctionnel et
   contourne endpoint+DDS (cf. §6) — non-bug, alternative documentée.

### 5.9 Cosmétique (prefab stand-in `wamv`)
- **Va tout droit** : pas de contrôleur (le `ctrl_course.py` était sur la machine WSL). Le
  voilier navigue sur le vent uniforme du yaml. → porter le contrôleur.
- **Skin wamv** : on a réutilisé l'Addressable `wamv` pour valider le pont **sans** authorer
  de prefab. → créer un prefab Addressable `focus_v2`.
- **En crabe** : le **+90°** de convention (xdyn met l'axe d'avance sur le `+y` du link).
  Côté gz on corrige par `<visual><pose>0 0 0 0 0 1.5708</pose>`. Côté Unity : **rotation
  locale** du mesh sous la racine du prefab (la racine est écrasée par les poses).
- **Nez enfoncé** : pivot/ligne de flottaison du prefab `wamv` ≠ repère sim. Disparaît avec
  un prefab `focus_v2` authoré au bon repère.

## 6. Alternative TCPUDP (explorée, puis abandonnée pour garder ROS2/DDS propre)

`render_plugin` accepte `<connection_protocol>TCPUDP</connection_protocol>` → gz parle en
**socket direct** à Unity, **sans `ros_tcp_endpoint` ni DDS** (contourne §5.4 et §5.5). Mais :
- **gz = client**, **Unity = serveur** (`TcpListener`/`UdpClient` sur **23457**,
  `IPAddress.Any`). Le conteneur se connecte **vers** le Mac → `<ip>` = IPv4 de
  `host.docker.internal` = **`192.168.65.254`** (numérique obligatoire, `from_string`). Pas
  de `-p`.
- Unity : `LotusimConnector.selectedInterfaceType = "TCPIP"` (namespace ignoré). Unity doit
  être en Play (à l'écoute) **avant** gz (`render_plugin` connecte une fois, sans retry).
- Fichiers : `world_tcpudp.world`, `run_demo_tcpudp.sh`, `run_tcpudp.sh`.
- **A quand même buté sur §5.7** (le vrai bloqueur). On est repassés en **ROS2/DDS** pour
  l'archi propre (le pont via endpoint).

## 7. Le vrai run end-to-end (à enregistrer pour la démo) — checklist

Objectif : tout faire de bout en bout, sur le repo propre, et capturer le voilier Focus V2
qui **contourne la bouée** sur la mer HDRP.

1. **Docker Desktop** démarré (Rosetta OK).
2. **Blender sur le Mac** → construire le **mesh Focus V2** (depuis `focus_v2_demo.blend` du
   spike, ou ré-author depuis dimensions publiques). Export pour Unity : **OBJ** (importé
   nativement par Unity ; le `.dae` Blender 4.5 importe vide) ou **FBX**
   (`bake_space_transform=True, axis_forward='-Z', axis_up='Y'`, racine à l'identité).
3. **Images** construites (§3).
4. **Unity** : fork cloné `--recurse-submodules`, ouvert en `2022.3.62f2` Apple Silicon.
5. **Patches Unity** (dans le fork `LOTUSim-Unity-modules`) :
   - ⭐ **bypass login** `GameManager.cs` (§5.7) — **À NE PAS OUBLIER**.
   - double-`Start` `LotusimConnector.cs` (déjà committé dans le fork).
   - `LotusimConnector.selectedInterfaceType = "ROS2"`.
6. **Prefab Addressable `focus_v2`** : importer le mesh OBJ → prefab → marquer Addressable,
   **adresse = `focus_v2`** ; corriger l'orientation (rotation locale du mesh, §5.9).
   Remettre `<renderer_type_name>focus_v2</renderer_type_name>` dans le world.
7. **Contrôleur** : porter `ctrl_course.py` (barre+voile, P-control sur le cap de route,
   `--sign -1 --kp 1.0`, dt 0.05 ; cf. `docs/demo-sailboat.md`) → publie sur
   `/<world>/vessel_cmd_array` (`mainsail(sail)` + `rudder(angle)`) → enroule la bouée.
8. **(Recommandé) Scène minimale dédiée** plutôt que `defenseScenario` : mer HDRP +
   `LotusimConnector` + caméra de suivi, **sans Photon/Launcher/GameManager/otages**. Évite
   le piège §5.7 **par construction** et donne un cadrage propre pour la capture.
9. **Lancer** (§4), **Play** (login bypassé), caméra sur `focus_v2` (flèches), **enregistrer**.

## 8. Fichiers (dans `~/src/lotusim-private/lotusim-macos-demo/`)

| Fichier | Rôle |
|---|---|
| `Dockerfile.focus-v2` | overlay du fork sur `lotusim:latest` (1 package recompilé + assets) → `lotusim:focus-v2` |
| `Dockerfile.bridge` | + `ros_tcp_endpoint` → `lotusim:focus-v2-bridge` |
| `run_demo.sh` | orchestration conteneur ROS2 : endpoint → **attend Unity** → xdyn → gz ; **`FASTDDS=DEFAULT`** |
| `run.sh` | lanceur hôte (ROS2) |
| `world_defense.world` | world focus_v2, **world name = `defenseScenario`** (matche le namespace de la scène), `renderer_type_name = wamv` (stand-in) |
| `verify_render*.sh` | vérifs headless (CREATE + poses qui bougent) |
| `run_demo_tcpudp.sh` / `run_tcpudp.sh` / `world_tcpudp.world` | alternative TCPUDP (§6) |
| `UNITY-GATE3.md` | réglages Unity (IP/port, namespace, Addressable) |
| `vendor/LOTUSim-Unity-ros-tcp-endpoint/` | clone du nœud-pont (buildé dans l'image) |

Patches dans le fork `cmoron/LOTUSim-Unity-modules` (non commités tant que non décidé) :
`GameManager.cs` (bypass login), `LotusimConnector.cs` (double-Start).
