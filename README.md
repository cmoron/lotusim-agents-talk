# From idea to LOTUSim contribution — faster with AI agents

Slides d'un talk sur l'utilisation d'agents de code IA pour contribuer à [LOTUSim](https://github.com/naval-group/LOTUSim) (simulateur robotique sous-marin), de la lecture du codebase à la pull request.

## Voir la présentation

- **Slides** : https://cmoron.github.io/lotusim-agents-talk/
- **Notes présentateur** (minuteur + notes, synchronisées entre fenêtres du même navigateur) : [`?presenter`](https://cmoron.github.io/lotusim-agents-talk/?presenter) — ou touche `p`
- **Speech seul** (prompteur défilable au doigt, pour tablette — pas de slides, pas de clavier) : [`?speech`](https://cmoron.github.io/lotusim-agents-talk/?speech)

## Navigation

| Touche | Action |
|---|---|
| `→` · `↓` · `Space` · `PageDown` · `Enter` | Slide suivante |
| `←` · `↑` · `PageUp` · `Backspace` | Slide précédente |
| `Home` · `End` | Première · dernière slide |
| `f` · `t` · `p` | Plein écran · thème · vue présentateur |

Le jeu de touches suivant/précédent couvre celui de PowerPoint, pour que les télécommandes de présentation USB fonctionnent.

## Local

Aucun build, aucune dépendance — c'est un fichier HTML autonome.

```bash
# Servir localement
python -m http.server 8000
# puis ouvrir http://localhost:8000
```

Ou ouvrir directement `index.html` dans un navigateur.

## Déploiement

Servi par GitHub Pages depuis `main` / `/` à chaque push.
