# Montage de la vidéo slide 9 — pilotage manuel

Pipeline ffmpeg + ImageMagick : **cut + vitesse variable + cartouches PNG**. Tout se
pilote depuis **une table texte** (`montage.sh`) et des **badges PNG** (`badges/`).

## La boucle d'itération

1. **Tester un seul clip** (vitesse / cut / badge) en ~3 s, sans tout re-rendre :
   ```bash
   bash video/montage/preview.sh FILE IN OUT SPEED [BADGE] [HOLD]
   # IN et OUT acceptent secondes OU mm:ss OU hh:mm:ss (colle l'heure QuickTime telle quelle)
   # ex : le bateau dans l'éditeur Unity, de 5:16 à 5:24, temps réel, badge mis-oriented :
   bash video/montage/preview.sh 3-unity_manual_fix_mesh.mov 5:16 5:24 1 16_misorient.png
   # ex : le payoff de 36 s à 60 s en 1,5×, badge qui s'efface après 4 s :
   bash video/montage/preview.sh 5-unity_run_fixed.mov 36 60 1.5 09_payoff.png 4
   ```
   Ça ouvre le clip dans QuickTime. Ajuste IN/OUT/SPEED/BADGE jusqu'à ce que ça te plaise.

2. **Reporter dans la table** : ouvre `montage.sh`, recopie la ligne validée dans `TABLE`.

3. **Rendre la vidéo complète** (~4 min) :
   ```bash
   bash video/montage/montage.sh        # -> video/_build/slide9_demo.mp4
   open video/_build/slide9_demo.mp4
   ```

## La TABLE (dans `montage.sh`) — une ligne = un segment

```
FILE | IN | OUT | SPEED | BADGE | HOLD | TPAD
```

| colonne | rôle |
|---|---|
| **FILE**  | le rush (`$F1`…`$F6`, définis juste au-dessus de la table) |
| **IN**    | **début** dans le rush — **secondes, `mm:ss` ou `hh:mm:ss`** (colle l'heure QuickTime telle quelle) |
| **OUT**   | **fin** dans le rush — même format. Pas de calcul de durée : durée écran = `(OUT - IN) / SPEED` |
| **SPEED** | **1 = temps réel** (ralenti = hero) · **100 = ×100** (accéléré = thinking). Décimales OK (`1.5`) |
| **BADGE** | un png de `badges/` (ex `04_mesh.png`) ou `-` pour aucun |
| **HOLD**  | secondes d'affichage du badge (temps de sortie) ou `full` (tout le segment) |
| **TPAD**  | fige la **dernière image** N secondes de plus (`0` = rien) — pour une fin sur freeze |

> Astuce : `IN`/`OUT` acceptent `9:55` aussi bien que `595`. Tu lis le temps dans QuickTime
> et tu le colles — aucune conversion en secondes, aucun calcul de durée.

**Édits courants :**
- **Accélérer un passage** → monte `SPEED` (la durée à l'écran diminue).
- **Ralentir un hero** → `SPEED` = `1` (ou `1.5`, `2`).
- **Couper / stopper un passage** → **supprime la ligne** (ou rapproche `OUT` de `IN`).
- **Décaler un cut** → change `IN` (début) et/ou `OUT` (fin).
- **Geler une image (stop)** → mets `TPAD` à `3` sur la ligne (fige 3 s à la fin du segment).
- **Faire disparaître le badge en cours de plan** → `HOLD` = `4` (badge visible 4 s puis off).

## Trouver les bons timestamps dans un rush

- **Le plus simple** : ouvre le `.mov` dans **QuickTime**, mets en pause, avance/recule
  **image par image** avec **←/→** ; le temps s'affiche. Note IN et IN+LEN.
- **Vue d'ensemble** (planche-contact horodatée toutes les N s) :
  ```bash
  bash video/montage/make_sheet.sh video/3-unity_manual_fix_mesh.mov 5 6 /tmp/sheet.png && open /tmp/sheet.png
  #                                  <rush>                          ^N  ^colonnes
  ```

## Faire des variantes sans rien écraser

Le **nom de sortie pilote tout** : chaque rendu a **ses propres segments** (`_build/segs_<nom>/`),
donc une variante n'écrase **ni** la vidéo **ni** les segments d'une autre.

```bash
bash video/montage/montage.sh video/_build/slide9_demo_v4.mp4   # -> segs_slide9_demo_v4/
# v3 (slide9_demo_v3.mp4 + segs_slide9_demo_v3/) reste intact.
```

- **Geler la recette (la TABLE)** avant d'expérimenter : copie le script.
  `montage-v3.sh` est déjà la **recette v3 figée** — lance-le pour reproduire v3 à l'identique.
  ```bash
  cp video/montage/montage.sh video/montage/montage-v5.sh   # puis édite la TABLE de la copie
  bash video/montage/montage-v5.sh video/_build/slide9_demo_v5.mp4
  ```
- ⚠️ Relancer **le même nom de sortie** reconstruit (donc efface) **les segments de ce nom-là**
  uniquement. Les autres variantes ne sont jamais touchées. Garde un nom par version.
- Les rendus `slide9_demo_v1/v2/v3.mp4` sont déjà conservés dans `_build/` (fichiers nommés).

## Éditer / créer un badge

Les badges sont des **PNG transparents** générés par `make_badge.sh` :
```bash
bash video/montage/make_badge.sh "TITRE" "sous-titre" "#COULEUR" badges/NN_nom.png
# ex (changer le texte du ship) :
bash video/montage/make_badge.sh "SHIP" "Reviewer · doc · issues · pull requests" "#4D9BFF" badges/11_ship.png
```
Palette du deck : **machine** `#4D9BFF` (bleu) · **décision humaine** `#FF5A36` (orange)
· **test** `#36D17A` (vert). (La forme/police/position se changent dans `make_badge.sh`.)

**Badges actuels :** `01_map 02_plan 03_build 04_mesh 05_diff 06_test 07_run_gz 08_unity
09_payoff 10_doc 11_ship 12_sign 13_firstrun 14_loop 15_doc_human 16_misorient
17_unity_human 18_straight`.

**Déplacer le badge à l'écran** : dans `montage.sh` **et** `preview.sh`, le `overlay=64:H-h-56`
= `x=64, y=hauteur-hauteurbadge-56` (bas-gauche). Ex haut-droite : `overlay=W-w-64:56`.

## Alternative tout-visuel : DaVinci Resolve

Si tu préfères retimer/cutter à la souris : importe les rushes dans **DaVinci Resolve**
(gratuit), touche **R** pour les rampes de vitesse, et **glisse les PNG de `badges/`** comme
calques d'incrustation (ils sont transparents → réutilisables tels quels). Même logique que
la table, mais visuelle.
