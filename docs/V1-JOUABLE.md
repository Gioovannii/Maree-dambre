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

1. **Continuité du village corrigée.** Une partie active est conservée ; la sauvegarde ancienne la plus récemment jouée est reprise lors de la migration.
2. **Revenus hors ligne corrigés.** Production, chantier et retour de raid sont traités dans leur ordre chronologique. Les tests comparent absence et mises à jour régulières, y compris aux plafonds.
3. **Activités de construction : concurrence corrigée.** Un arrêt en attente ne peut plus fermer une activité créée après lui. La vérification sur appareil, application suspendue, reste à faire.
4. **Faire une vraie partie depuis une installation neuve**, puis fermer et rouvrir
   pendant construction, recherche, entraînement et raid. Les tests automatisés
   ne remplacent pas cette validation sur iPhone ni un test sur plusieurs jours.

## Pour rendre la première partie compréhensible

- Guide Premiers pas ajouté : ouverture après le choix du clan, prochaine étape et accès direct au champ ou bâtiment concerné.
- Le guide explique les plafonds, le niveau 10, le recrutement et les pertes.
- Définir un premier objectif de session et tester les temps d'attente avec des joueurs.
- Aligner les textes sur les fonctions réelles : les bots n'attaquent pas le village,
  la défense et les rôles d'exploration annoncés ne constituent pas encore une boucle jouable.

## Peut attendre après la bêta solo

Comptes et synchronisation, vrais adversaires humains, alliances, colonies, classement,
combats animés et illustrations dédiées aux deux nouveaux bâtiments. L'équilibrage
des pertes et du butin reste provisoire : surveiller les raids répétés et la progression.
