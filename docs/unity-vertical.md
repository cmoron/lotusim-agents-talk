# Verticale Unity — afficher le Focus V2 dans Unity avec le moteur LOTUSim derrière

Compagnon de [`demo-sailboat.md`](demo-sailboat.md). But : pousser le « wow » du
clip démo en remplaçant la GUI Gazebo (rendu de debug) par le **vrai frontend de
rendu LOTUSim, Unity** (mer HDRP, lumières, ombres), avec **xdyn + gz qui calculent
toujours la physique derrière**. Aucun accès interne : tout reconstruit depuis les
repos publics `naval-group` + les sources LOTUSim — ce qui *est* la thèse du talk.

> ## ✅ UPDATE 2026-06-26 (macOS) — verticale UNPARKÉE + validée. Et le blocage WSL était MAL diagnostiqué.
>
> La verticale Unity **marche end-to-end sur macOS** (Docker amd64/Rosetta headless + Unity natif Metal, pont `ros_tcp_endpoint`) — runbook complet : [`macos-demo.md`](macos-demo.md). Ce doc-ci reste le **récit WSL** (valide pour ce qu'il décrit).
>
> ⚠️ **Correction de diagnostic** : le *« bateau ne spawn jamais »* qu'on attribue plus bas au **NAT return relay** était un **FAUX diagnostic**. Vrai coupable (trouvé sur Mac) : la scène **`defenseScenario`**, dont le **`GameManager` Photon** recharge `Launcher` en standalone (`if(!PhotonNetwork.IsConnected) LoadScene(...)`) → **détruit le `LotusimConnector`** → rien ne spawn, **déguisé en bug de pont/relaye** (le `RosInterface` singleton survit, le connector non — d'où l'absence de `HandleCommand` qu'on prenait pour « le message n'arrive pas »). Le mur **HDRP/Vulkan sous WSLg** (ci-dessous) est un problème **séparé et réel** (propre à WSL ; absent sur Mac/Metal). → toujours **bypasser le login Photon/Launcher**, ou partir d'une **scène minimale dédiée**.

> ## ⛔ VERDICT WSL (2026-06-26) — la voie WSL est un mur (HDRP/Vulkan) ; la verticale, elle, est validée sur macOS (UPDATE ci-dessus). Le talk garde la démo gz comme filet.
>
> **Toute la chaîne marche SAUF le rendu : WSLg n'a pas de device Vulkan de type GPU, et HDRP refuse de rendre sans.** Mur structurel, pas une config ratée.
> - **Installé + prouvé en WSL (NAT) :** Unity Hub + Editor **2022.3.62f2 Linux**, projet copié en `~/src/LOTUSim-Unity-modules` (FBX + prefab + Addressable `focus_v2` + namespace `lotusim` + fix double-Start + `Library/` chaud), **licence Personal active**. L'**import marche en headless** (`-batchmode -nographics -quit` → `Exiting batchmode successfully`).
> - **Le mur :** l'Editor retombe sur **OpenGLCore** (llvmpipe GL = 4090 via d3d12) → HDRP : *"graphics API OpenGLCore is not supported with HDRP"*. `-force-vulkan` n'aide pas : le seul ICD Vulkan est **lavapipe** (`deviceType=4`=CPU) et **Unity refuse les devices Vulkan logiciels** (`Could not select a physical device`).
> - **Pas de Vulkan matériel ici :** Mesa 24.04 sans **Dozen (`dzn`)** en amd64, driver NVIDIA WSL = DLL Windows seules (pas d'ICD Vulkan Linux).
> - **Seul fix WSL = installer Dozen** (PPA Mesa `dzn`, Vulkan-sur-D3D12 → présente la 4090 comme GPU Vulkan). Non tenté : swap mesa système invasif + couverture HDRP-14 incertaine. Bonus, talk le 2 juillet, démo gz déjà OK → **on s'arrête.**
> - **Tout est laissé sur disque (~11 G, NON supprimé)** si on veut retenter Dozen un jour ; détails + marche à suivre dans la mémoire projet `lotusim-unity-render-path`.
>
> *(Runbook ci-dessous conservé pour les détails techniques — la moitié gz→ROS2→endpoint reste 100% valide et réutilisable.)*

---

## L'architecture, en une image

```
xdyn-for-cs (physique)  ──ws://127.0.0.1:12345──►  gz sim  ──┐
                                                             │  plugin render_plugin (ROS2)
                                                             ▼  publie sur le graphe ROS2 :
                                          /lotusim/renderer_cmd    (RendererCmd : CREATE/DELETE)
                                          /lotusim/renderer_poses  (VesselPositionArray, chaque tick)
                                                             │
                                                             ▼
                              ros_tcp_endpoint  (pont ROS2 ↔ TCP, port 10000)
                                                             │
                                                             ▼
                              Unity  (LOTUSim-Unity-modules, 2022.3.18f)
                                  LotusimInterface  namespace = "lotusim", interface = "ROS2"
                                  sur CREATE → Addressables.Load<GameObject>("focus_v2") → Instantiate
                                  sur poses  → GzPoseToUnityPose + interpolation → transform
```

**Le maillon clé** : le maillage du bateau **ne transite pas** sur le réseau. Le flux ne
porte qu'un *nom* (`renderer_obj_name`) + des poses. Unity résout ce nom via **Unity
Addressables** : `Addressables.LoadAssetAsync<GameObject>(renderer_obj_name)`. Donc côté
Unity il faut un **prefab Focus V2 enregistré comme Addressable dont l'adresse = le
`renderer_type_name`** posé dans le world (ici `focus_v2`). C'est tout le secret.

Contrat exact (vérifié dans les sources) :

| Côté | Fichier | Ce qu'il fait |
|---|---|---|
| gz | `systems/render_interface/src/render_plugin.cpp` | lit `<connection_protocol>` ; pour chaque modèle avec `lotus_param/render_interface/publish_render=true`, émet un CREATE puis stream les poses |
| gz | `…/ros_interface.cpp` | publie `<world>/renderer_cmd` + `<world>/renderer_poses` ; le node est nommé sous le **nom du world** → topics préfixés `/lotusim/…` |
| Unity | `Assets/Scripts/lotusim_interface/ROS2_interface/RosInterface.cs` | souscrit `{namespace}/renderer_poses` + `{namespace}/renderer_cmd` |
| Unity | `Assets/Scripts/lotusim_interface/LotusimConnector.cs` | `Addressables.LoadAssetAsync<GameObject>(renderer_obj_name)` → Instantiate, renomme en `vessel_name` |
| Unity | `Assets/Scripts/lotusim_interface/ROSConnectionConfigurator.cs` | lit `ROS_IP`/`ROS_Port` (PlayerPrefs, défaut `127.0.0.1:10000`) |

---

## Ce qui est DÉJÀ fait et vérifié (moitié gz→ROS2)

1. **World câblé** : `assets/worlds/focus_v2_unity.world` dans le fork
   `cmoron/LOTUSim` (branche `demo/focus-v2`). C'est `focus_v2_demo.world` + 2 ajouts :
   - le plugin world `render_plugin` (`<connection_protocol>ROS2</connection_protocol>`) ;
   - dans le `lotus_param` du `focus_v2`, un bloc
     `<render_interface><publish_render>true</publish_render><renderer_type_name>focus_v2</renderer_type_name></render_interface>`.
   `focus_v2_demo.world` (la démo gz-GUI validée) est **laissé intact**.
2. **Vérif headless** (sans Unity) — co-sim lancée, `ros2 topic echo` confirme :
   - `/lotusim/renderer_cmd` → CREATE `renderer_obj_name=focus_v2`, `vessel_name=focus_v2` ;
   - `/lotusim/renderer_poses` → flux live, le bateau bouge (ex. `(0.29,1.50)`→`(0.69,4.93)`
     en ~5 s, quaternion qui tourne) ;
   - log plugin propre : `Creating connection: ROS2 / RenderPlugin started / Creation detected of vessel named focus_v2`.

> Reproduire la vérif : `bash` un script type `run_course_gui.sh` mais avec
> `WORLD=focus_v2_unity.world`, puis `ros2 topic echo --once /lotusim/renderer_cmd` et
> `ros2 topic echo /lotusim/renderer_poses`. (xdyn sur 12345, gz, `ctrl_course.py`.)
3. **Pont `ros_tcp_endpoint` buildé + testé** (cf. §A) : node `/UnityEndpoint`, écoute
   `0.0.0.0:10000`. Reste donc UNIQUEMENT le client Unity (étapes B+C, ta machine).

---

## Ce qu'il reste à faire (moitié Unity — ta machine)

### A. Le pont ROS2 ↔ Unity (`ros_tcp_endpoint`) — ✅ buildé + vérifié 2026-06-25
Package `ros_tcp_endpoint` (build_type `ament_python`, pur Python ~1 s). Clone + build faits
dans `lotusim_ws` ; testé : monte le node `/UnityEndpoint`, écoute `0.0.0.0:10000`.
```bash
cd ~/lotusim_ws/src
git clone https://github.com/naval-group/LOTUSim-Unity-ros-tcp-endpoint
# ⚠️ l'install de lotusim_ws est en layout 'merged' → il FAUT --merge-install
# (sinon : "install directory was created with the layout 'merged'… add --merge-install")
cd ~/lotusim_ws && colcon build --merge-install --packages-select ros_tcp_endpoint
source install/setup.bash
ros2 run ros_tcp_endpoint default_server_endpoint --ros-args -p ROS_IP:=0.0.0.0
# -> [UnityEndpoint]: Starting server on 0.0.0.0:10000
# même graphe ROS2 (même ROS_DOMAIN_ID) que le render_plugin -> auto-discovery DDS
```

### B. Le projet Unity + le prefab Focus V2

> **Où faire tourner Unity : natif Windows (recommandé), pas WSLg.** WSLg n'est PAS
> headless (il affiche bien Chrome/Blender/gz GUI), donc l'Editor Linux 2022.3.18f
> *pourrait* tourner sous WSLg (même-hôte → réseau trivial `127.0.0.1:10000`). Mais le
> GL par défaut de cette box est **`llvmpipe` (software)** — le GPU NVIDIA n'est utilisé
> que si on force `GALLIUM_DRIVER=d3d12`, et un projet **HDRP** entier sous ça = fragile.
> Le projet est aussi orienté Windows (Tobii Windows-only, Leap). → Unity sur **Windows**,
> xdyn+gz+endpoint restent dans **WSL2**, on traverse au TCP `:10000`.

```bash
git clone --recurse-submodules https://github.com/naval-group/LOTUSim-Unity-modules
cd LOTUSim-Unity-modules && git submodule update --remote --merge
```
⚠️ Les submodules tirent `custom-hdrp` (~296 MB) + `ROS-TCP-Endpoint`. Projet ~395 MB
hors submodules. Ouvrir dans **Unity Hub sur la ligne 2022.3 LTS**. ⚠️ Le README épingle `2022.3.18f1`
(la version d'auteur du repo) mais elle est **pré-CVE** : prendre la patch corrigée
**`2022.3.62f2`** (fix **CVE-2025-59489**, local code exec dans le runtime ; cf.
`unity.com/security/sept-2025-01`). Rester *dans* la minor 2022.3 LTS = bump de patch sûr
(réimport, pas de migration). **Ne PAS** sauter vers un major (2023/Unity 6) : migration
d'assets/HDRP irréversible qui casserait le fork custom-hdrp. (Risque réel ici faible — on
lance l'Editor en local, on ne distribue pas de build — mais la patch est gratuite.)

Dans l'Éditeur (valeurs réelles, inspectées dans le clone Windows 2026-06-25) :
0. **Ouvrir la scène `Assets/Scenes/Defense/defenseScenario.unity`** — c'est la SEULE
   qui porte déjà le connecteur `LotusimInterface` + `ROSConnectionConfigurator` + le
   ciel/mer HDRP + Addressables. Rien à reconstruire. (Cluttered : îles, soldats — OK pour
   un 1er rendu ; on fera une scène mer-only propre pour le clip final.)
1. **Namespace (LE réglage critique)** : sélectionner le GameObject qui porte
   `LotusimInterface`, Inspector → `m_namespace` est à **`defenseScenario`**, le passer à
   **`lotusim`** (= nom du world gz `focus_v2_unity.world` → topics `/lotusim/renderer_*`).
   `Interface Type` est déjà `ROS2`. **Piège n°1** (sinon : connecté mais rien ne spawn).
2. **Importer le maillage** : créer `Assets/models/focus_v2/mesh/` et y glisser
   `focus_v2.dae` (depuis `\\wsl.localhost\<distro>\home\cyril\src\LOTUSim\LOTUSim\assets\models\focus_v2\meshes\focus_v2.dae`).
   C'est exactement la structure de `Assets/models/wamv/` (tous les vaisseaux du projet
   sont en `.dae`). Le `.dae` est auto-suffisant (4 matériaux embarqués, `up_axis=Z_UP`
   → Unity redresse en Y-up). **PAS le `.obj`** (Z-up sans métadonnée → couché).
   - si couché : Import Settings → **Bake Axis Conversion** ;
   - si magenta : **Extract Materials** → shader **HDRP/Lit**, couleurs : hull rouge
     `0.72,0.04,0.06` · sail `0.95,0.95,0.92` · carbon `0.02,0.02,0.025` · lead `0.32,0.33,0.35`.
3. **Prefab** : déposer le modèle dans la scène, ré-enregistrer en
   `Assets/models/focus_v2/focus_v2.prefab` (template = `Assets/models/wamv/wamv.prefab`).
   Pas d'Animator (voilier, pas d'hélice). Échelle 1 (mètres).
   ⚠️ Cap : commencer en rotation identité ; si la proue ne suit pas la marche, baker un
   ~90° yaw dans le prefab (la conversion de pose runtime est gérée par `CoordinateSystemUtils`).
4. **Addressable** : sélectionner `focus_v2.prefab` → cocher *Addressable* → adresse
   **exactement `focus_v2`**. Elle rejoint le groupe existant (`wamv`, `fremm`, `lrauv`,
   `commando`, `bluerov2_heavy`, `mine`, `pha`, `x500` — convention = nom court du modèle).
5. **IP/port du pont** (PlayerPrefs `ROS_IP`/`ROS_Port`, défaut `127.0.0.1:10000`).
   Unity (Windows) est le **client TCP**, il se connecte à l'endpoint (serveur, WSL2,
   bind `0.0.0.0:10000`) ; tout est multiplexé sur cette connexion → seul
   **Windows→WSL2:10000** doit être joignable. WSL2 ici est en **NAT** :
   - essaie `ROS_IP=127.0.0.1` d'abord (localhostForwarding, défaut WSL2) ;
   - sinon l'IP eth0 WSL2 (`ip -4 addr show eth0`, ex. `172.18.x.x` — change au reboot) ;
   - vérif côté Windows pendant que l'endpoint tourne : `Test-NetConnection localhost -Port 10000`.
   **Piège n°2** (réseau cross-OS).
6. **« Où est mon bateau ? »** : il spawn à la position gz convertie (course ~`(0,0)`→`(0,12)` m).
   Bouger la caméra Scene/Game là, ou flèches ←/→ (CameraDynamicTargetsNavigator). Console :
   `[RosInterface] HandleCommand: 0 focus_v2` = CREATE reçu ✓ ;
   `Failed to create object with type focus_v2` = adresse Addressable fausse.

### C. Ordre de lancement
```
1. xdyn-for-cs … --port 12345          # physique
2. gz sim -s -r focus_v2_unity.world   # publie /lotusim/renderer_cmd + /renderer_poses
3. ros2 run ros_tcp_endpoint …         # pont :10000
4. Unity ▶ Play                         # se connecte, charge "focus_v2", suit les poses
5. python3 ctrl_course.py …            # le bateau contourne la bouée → visible dans Unity
```
L'ordre exact 2↔3 est souple (le CREATE est **latched / TRANSIENT_LOCAL** : Unity le
reçoit même s'il se connecte après le spawn).

---

## Les pièges trouvés (à ne pas réapprendre)

1. **`m_namespace` Unity = `lotusim`** (nom du world), pas `Silent_Storm`. #1 cause de
   « Unity connecté mais rien ne s'affiche ».
2. **Adresse Addressable = `renderer_type_name`** au caractère près (`focus_v2`).
3. **Protocole = `ROS2`** (la string exacte testée par `CreateRenderInterface`), pas `ROS`.
4. **Le maillage ne transite pas** : pas la peine de chercher un loader de mesh runtime —
   le prefab doit préexister côté Unity.
5. **Réseau cross-OS** (Unity Windows ↔ ROS2 WSL2) : `ROS_IP` host + endpoint `0.0.0.0`.
6. **Plugin lib = `render_plugin`** (`librender_plugin.so`), name `lotusim::gazebo::RenderPlugin`.

## Verdict pour le talk
La moitié difficile à *comprendre* (le contrat de rendu, le mécanisme Addressables, le
namespace) est élucidée et la moitié gz→ROS2 **tourne et est prouvée**. Le reste est de
l'intégration d'éditeur Unity, mécanique mais qui demande la machine. Côté récit : un
contributeur externe, avec des agents et les repos publics, a recâblé toute la stack de
rendu LOTUSim sans accès interne — le talk qui se démontre lui-même.
