# État de la V1 jouable — 15 octobre 2026

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
- Les parcelles sont sélectionnables avec VoiceOver, y compris pour déplacer
  un bâtiment. Le guide en modale et son bouton livre ont été retirés.
- Une sauvegarde illisible reste intacte pendant les mises à jour automatiques.
  Fonder un nouveau village conserve une copie des données originales avant remplacement.
- La validation des sauvegardes refuse les dates extrêmes, fractions de production
  invalides et chantiers incohérents avant le calcul des revenus hors ligne.
- La Tour de garde apporte désormais un bonus à la défense côtière. Les recherches
  concernent les deux unités du peuple choisi.
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

## Deuxième lot : premières défenses côtières

- Accès depuis Monde → Organiser la défense ou depuis la Tour de garde.
- Activation volontaire après la Cour des armes et une première unité ; aucune
  campagne n’est activée automatiquement dans les sauvegardes existantes.
- Marées de campagne décidées par le joueur : premier assaut à la marée 2, puis
  aux marées 5, 8, etc. Aucune attaque rétroactive pendant une absence.
- Première vague de 4 pillards, force 24 ; deux pillards supplémentaires par
  vague, plafonnés à 42 et force 252, sans adaptation à la puissance du joueur.
- Garnison seule, bonus de Tour (+20), armes (+1 par niveau et unité), mage et
  Infirmerie pris en compte. Une égalité de force tient le port.
- Prévision du résultat, des pertes et stocks pillés avant résolution. La préparation
  d’un raid affiche aussi la défense qui restera et la menace annoncée.
- En défaite, pillage limité à force ennemie / 3 par ressource, plafond de 90,
  avec 20 protégés si disponibles. Champs, bâtiments, recherches, formation et
  troupes déjà parties sont conservés ; la reconstruction reste possible.
- Rapport de défense structuré et sauvegardé séparément du rapport d’expédition.
  Relance, production hors ligne et passages suivants ne rejouent pas le combat.
- État défensif conservé dans la migration en version 13 et validation des compteurs
  et rapports corrompus. Tests de règles et de session réelle réussis.
- Compilation iOS et 409 textes français/anglais vérifiés. Victoire et pillage
  contrôlés sur iPhone simulé en français à taille normale ; préparation,
  confirmation et rapports contrôlés aussi en anglais à taille d’accessibilité
  maximale. Les libellés des commandes
  passent en colonne aux grandes tailles et la confirmation reste défilante.

Ce premier cycle rend le choix sortie/garnison concret. Les marées ne distribuent
pas encore de production et n’agissent pas sur les routes ; elles servent à
tester la préparation et la résolution des menaces. La progression territoriale
des trois pavillons existants garde son horloge de six heures et ne déclenche pas
ces assauts. Avant-postes, alliances commerciales, époques, merveille et classements
restent les lots suivants décrits dans `VISION-SOLO.md`.

## Troisième lot : contrats et escortes

- Accès depuis Monde → Voir les contrats ou depuis le Marché. La campagne côtière
  doit être ouverte volontairement ; le commerce ne l’active pas automatiquement.
- Premier partenaire : Comptoir des Roseaux. Coût commun : 20 bois et 5 vivres au
  départ. Route sûre : trois marées, 18 ambres, aucune perte. Route courte : deux
  marées, 26 ambres, pillards de force 24 ; une égalité suffit à livrer.
- Choix des effectifs par type, prévision du résultat et de la défense restante.
  Les armes, taux de pertes et bonus de transport sont enregistrés au départ.
- Une offre par route toutes les six marées après son départ ; un convoi commercial
  à la fois. Les unités d’escorte comptent dans la limite commune de 100 avec
  garnison, recrutement et raids. Elles ne sont disponibles pour aucune autre tâche.
- Combat du port avant retour des convois de la même marée. Les survivants rentrent
  même si l’entrepôt est plein. Le paiement est conservé, réclamable une fois dès
  qu’il tient en réserve ; aucun contrat suivant ne peut écraser un paiement dû.
- La fermeture de l’app ne fait avancer ni le trajet ni l’offre. Sauvegarde en
  version 13 ; anciennes armées conservées, contrôles des effectifs et états de
  contrat incohérents avant chargement.
- Tests de domaine et de session réelle réussis : trajets sûrs/risqués, pertes,
  départ atomique, capacité de transport, garnison, plafond de 100, reprise,
  réserve pleine, paiement unique et sauvegardes corrompues.
- Parcours complet de la route courte contrôlé en police normale, puis route sûre
  en police d’accessibilité maximale, avec défense pendant le trajet et paiement.
  Compilation iOS et 451 textes français/anglais vérifiés.
- Neuf références iPhone, dont l’écran de contrats, et trois références iPad
  contrôlées visuellement puis comparées avec succès. Le masque matériel est
  fixé en noir pour éviter les variations de l’encoche du simulateur, sans
  augmenter la tolérance de comparaison de l’interface.

Ce lot ne crée pas encore d’alliance, de marché mondial, de routes sur la carte ou
de variation des trajets selon haute/basse mer. Ces règles restent à tester avec
les avant-postes et le premier objectif du phare.

## Pour rendre la première partie compréhensible

- Le guide « Premiers pas », son ouverture après le choix du clan et le bouton
  livre sont supprimés à la demande du porteur du projet. La fondation ouvre
  directement le village.
- Fondation vérifiée sur simulateur, puis lecture du village à taille normale
  et maximale. Les références iPhone et iPad ne contiennent plus le guide.
- Le nouvel onboarding est reporté à la fin : conseils TipKit et personnage avec
  chat dédié via CoreAI, dont le choix technique sera étudié lors de ce lot.
- Définir un premier objectif de session et tester les temps d'attente avec des joueurs.
- Les corsaires attaquent dans la campagne côtière activée par le joueur. Les
  missions d’exploration et de colonisation restent à construire.

## Après validation de la première boucle

Le classement Game Center fait partie de la direction du produit et sera ajouté
par un lot dédié. Il n’est pas nécessaire pour tester la première boucle locale.
Le multijoueur partagé, les comptes personnels, les villes multiples et les combats
animés restent hors du premier périmètre. L’équilibrage des pertes et du butin reste
provisoire : surveiller les raids répétés et la progression.
