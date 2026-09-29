# État de la V1 jouable — 29 septembre 2026

La boucle locale existe : produire, développer les champs, construire, rechercher,
entraîner, attaquer une faction et rapporter des ressources. Ce sont des adversaires
simulés, pas des joueurs connectés. Firebase n'est pas nécessaire pour cette bêta solo.

## Corrections réalisées

- Un raid de début de partie est désormais accepté par la validation des sauvegardes
  (défense 14 ou 18). Les valeurs des anciennes sauvegardes restent acceptées.
- Déplacer un bâtiment sur un chantier est interdit pour éviter son écrasement
  à la fin des travaux.
- Le chantier montre progressivement le bâtiment construit, avec des fondations
  au début et un échafaudage latéral.

## À traiter avant une bêta durable

1. **Conserver le village au changement de semaine.** `VillageSession` choisit encore
   la graine de la semaine courante, et `VillageStorage` charge une sauvegarde par
   graine. La semaine suivante ouvre donc une autre partie sans accès aux anciennes.
   Garder un identifiant de partie active et réserver le renouvellement à une action
   explicite du joueur.
2. **Calculer les revenus dans l'ordre des événements.** `updateInRealTime` termine
   le chantier avant de calculer toute la production écoulée. Un bâtiment producteur
   terminé pendant l'absence peut produire rétroactivement. Découper le calcul à
   l'heure de fin du chantier et vérifier les plafonds lors du retour des raids.
3. **Vérifier les activités de construction sur appareil.** Tester fin au premier
   plan, application suspendue, annulation puis lancement immédiat d'un chantier.
   L'arrêt asynchrone des Live Activities mérite une vérification de concurrence.
4. **Faire une vraie partie depuis une installation neuve**, puis fermer et rouvrir
   pendant construction, recherche, entraînement et raid. Les tests automatisés
   ne remplacent pas cette validation sur iPhone ni un test sur plusieurs jours.

## Pour rendre la première partie compréhensible

- Ajouter un objectif suivant visible : améliorer un champ, construire la Maison
  des savoirs, rechercher une unité, construire la Cour des armes, mener un raid.
- Expliquer les ressources plafonnées, les conditions de niveau 10 et les pertes.
- Définir un premier objectif de session et tester les temps d'attente avec des joueurs.
- Aligner les textes sur les fonctions réelles : les bots n'attaquent pas le village,
  la défense et les rôles d'exploration annoncés ne constituent pas encore une boucle jouable.

## Peut attendre après la bêta solo

Comptes et synchronisation, vrais adversaires humains, alliances, colonies, classement,
combats animés et illustrations dédiées aux deux nouveaux bâtiments. L'équilibrage
des pertes et du butin reste provisoire : surveiller les raids répétés et la progression.
