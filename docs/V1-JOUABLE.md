# État de la V1 jouable — 14 octobre 2026

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
- Le guide se rouvre depuis les trois écrans principaux ; les parcelles sont
  sélectionnables avec VoiceOver, y compris pour déplacer un bâtiment.
- Une sauvegarde illisible reste intacte pendant les mises à jour automatiques.
  Fonder un nouveau village conserve une copie des données originales avant remplacement.
- La validation des sauvegardes refuse les dates extrêmes, fractions de production
  invalides et chantiers incohérents avant le calcul des revenus hors ligne.
- Les textes de la Tour de garde décrivent son rôle actuel, sans annoncer d’attaques
  du village. Les recherches concernent les deux unités du peuple choisi.
- Le manifeste de confidentialité déclare le stockage local par `UserDefaults`.
- Les tailles de texte d’accessibilité utilisent un bandeau de ressources en
  colonne et une liste de parcelles défilante. Les noms, stocks et commandes
  restent lisibles ; la sélection et le déplacement ont été contrôlés sur simulateur.

## À traiter avant une bêta durable

1. **Continuité du village corrigée.** Une partie active est conservée ; la sauvegarde ancienne la plus récemment jouée est reprise lors de la migration.
2. **Revenus hors ligne corrigés.** Production, chantier et retour de raid sont traités dans leur ordre chronologique. Les tests comparent absence et mises à jour régulières, y compris aux plafonds.
3. **Activités de construction : concurrence corrigée.** Un arrêt en attente ne peut plus fermer une activité créée après lui. La vérification sur appareil, application suspendue, reste à faire.
4. **Faire une vraie partie depuis une installation neuve**, puis fermer et rouvrir
   pendant construction, recherche, entraînement et raid. Les tests automatisés
   ne remplacent pas cette validation sur iPhone ni un test sur plusieurs jours.

## Premier lot de la nouvelle direction : choix des troupes

- Une préparation d’expédition remplace le départ imposé de toute l’armée.
- Chaque type d’unité possède un effectif choisi ; les autres troupes restent au village.
- Deux raccourcis permettent de tout sélectionner ou de garder la moitié de
  chaque type au village. La sélection peut ensuite être ajustée individuellement.
- L’estimation des pertes tient compte des seuls mages envoyés. Les armes,
  l’Infirmerie et le Quai restent enregistrés au départ pour toute l’expédition.
- Une sélection vide, négative ou supérieure aux troupes disponibles est refusée.
- La garnison et les troupes parties sont conservées après relance ; les survivants
  rejoignent la garnison. Le recrutement compte aussi les troupes parties dans le plafond de 100.
- Les champs, leurs niveaux et les délais actuels de production/recrutement restent en place.
- Les tests de domaine et de session couvrent les départs partiels, les pertes,
  les bonus, la sauvegarde, le recrutement pendant le trajet et le retour unique.
- La compilation iOS et les 369 clés de textes français/anglais ont été vérifiées.
  Sur iPhone simulé, le choix des effectifs et le départ ont été contrôlés en taille
  normale en français puis à la taille d’accessibilité maximale en anglais.
  Conserver ces deux tailles de vérification pour les prochains écrans modifiés.

Les attaques entrantes, défenses de positions, contrats, époques, merveille et
classements restent les lots suivants décrits dans `VISION-SOLO.md`.

## Pour rendre la première partie compréhensible

- Guide Premiers pas ajouté : ouverture après le choix du clan, prochaine étape et accès direct au champ ou bâtiment concerné.
- Le guide explique les plafonds, le niveau 10, le recrutement et les pertes.
- Définir un premier objectif de session et tester les temps d'attente avec des joueurs.
- Les bots n’attaquent pas le village. La Tour de garde est décorative ; les missions
  d’exploration et de colonisation restent à construire.

## Après validation de la première boucle

Le classement Game Center fait partie de la direction du produit et sera ajouté
par un lot dédié. Il n’est pas nécessaire pour tester la première boucle locale.
Le multijoueur partagé, les comptes personnels, les villes multiples et les combats
animés restent hors du premier périmètre. L’équilibrage des pertes et du butin reste
provisoire : surveiller les raids répétés et la progression.
