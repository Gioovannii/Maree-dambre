# Boucle de raids contre les bots

## Objectif

Donner au joueur des cibles régulières pour gagner des ressources, tester son armée et progresser vers les unités lourdes, sans dépendre du multijoueur ni d’un serveur. Les bots sont des adversaires persistants de la carte ; ils ne représentent pas de vrais joueurs.

## Proposition de première version

- Passer de 3 à 12 voisins IA, répartis en quatre portées : les 3 voisins proches déjà présents, 3 intermédiaires, 3 lointains et 3 très lointains (jusqu’à 90 cases). Le placement reste déterministe pour que chaque joueur retrouve les mêmes voisins sur sa carte.
- Conserver les trois tribus existantes. Chaque voisin a un pseudonyme propre ; sa fiche indique aussi sa tribu, son niveau et sa distance. Les noms ne doivent pas se répéter sur une même carte.
- Faire monter la difficulté avec la distance : niveau initial 1 pour les voisins actuels, puis 3, 5 et 7 par portée. La progression actuelle des bots continue ensuite, avec un plafond de niveau à 10.
- Garder une seule armée en expédition à la fois. Les attaques contre les bots restent répétables ; chaque cible récupère pendant 10 minutes après le retour, comme aujourd’hui. Le joueur peut donc choisir une autre cible pendant ce délai. Cette règle concerne uniquement les bots et ne préjuge pas du quota PvP.
- Conserver le butin limité par la capacité de transport, le niveau du Quai et la place disponible dans l’entrepôt. Une victoire ne doit jamais dépasser ces plafonds ; une défaite ne rapporte rien et entraîne les pertes déjà prévues.
- Présenter la distance, le niveau, la durée aller-retour (qui augmente avec la distance) et la défense dans la liste des cibles. La préparation permet ensuite d’examiner les troupes et les pertes possibles ; le rapport de retour indique le butin réellement stocké.

## Progression recherchée

Les voisins proches permettent de démarrer avec les unités de base. Les cibles intermédiaires encouragent à améliorer les champs, l’entrepôt et le Quai. Les cibles lointaines deviennent un objectif de recherche et d’amélioration des armes, préparant l’accès aux unités lourdes. Les bâtiments et unités doivent donc rendre les paliers de difficulté lisibles plutôt que rendre les raids plus longs sans bénéfice.

## Riposte des voisins

La campagne de défense existante sert de boucle de riposte : le voisin le plus proche mène le premier assaut, puis les voisins se relaient. Le niveau de l’assaillant et les assauts déjà résolus déterminent sa force. La garnison, la Tour, les pertes et le butin pillé continuent d’utiliser les règles et rapports de défense existants. Le joueur fait toujours avancer les marées lui-même ; les assauts ne se résolvent pas pendant son absence.

## Garde-fous de conception

- Les ressources gagnées restent bornées par le transport et le stockage, pour éviter une boucle de butin sans limite.
- Le délai de récupération est par cible ; il n’empêche pas le joueur de poursuivre ses raids sur d’autres voisins.
- Les règles PvP, la fréquence des attaques humaines et les coûts serveur sont hors de ce chantier solo.
- Ajouter des voisins ne doit pas modifier les positions ni l’identité des trois cibles déjà présentes dans les sauvegardes. Les nouvelles cibles doivent être ajoutées de manière compatible avec les cartes et états existants.

## Vérifications de produit avant équilibrage

Sur un parcours de départ, le joueur doit pouvoir gagner un premier raid avec ses unités initiales, comprendre pourquoi une cible plus lointaine est plus difficile, puis identifier une amélioration concrète qui rend cette cible accessible. Les quantités de butin et les durées seront ajustées après ce parcours, sans changer le principe de récupération indépendante par cible.
