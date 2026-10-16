# Aperçu vivant du Domaine d’Ambre

Ouvrir `http://127.0.0.1:3003/preview.html` pour la lecture automatique en boucle et le bouton Pause/Reprendre. Le serveur local sert ce dossier.

`index.html` est la composition HyperFrames de six secondes à 887 × 1774 px. Sa timeline GSAP reste en pause ; HyperFrames la parcourt pour les captures et `preview.html` la pilote pour l’aperçu en boucle.

La mer reçoit une déformation douce et des reflets mobiles, limités à un masque qui protège la côte, les bateaux et l’interface. Cinq habitants ont de petits mouvements locaux ancrés aux pieds. Ce sont des gestes sur place à partir d’une illustration, pas des personnages animés capables de marcher.

La version corrigée a passé `hyperframes check` sans erreur. L’avertissement de structure monoscène et les informations de débordement des images masquées sont sans effet sur le cadrage final. Captures dans `proof-v2/`. Comparaison des pixels : HUD parfaitement fixe ; mer et travailleurs effectivement animés.

Cet aperçu est indépendant de l’app native et aucune vidéo n’a été exportée. Le rendu natif adopté ensuite est documenté dans `../../docs/LIVING_DOMAIN.md`. Les captures de preuve sont des fichiers locaux régénérables, exclus du dépôt.

Pour relancer le lecteur depuis ce dossier : `python3 -m http.server 3003 --bind 127.0.0.1`, puis ouvrir `http://127.0.0.1:3003/preview.html`.
