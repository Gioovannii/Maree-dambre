# Conflits entre joueurs

## Direction retenue

Les joueurs pourront attaquer d’autres joueurs et préparer la défense de leurs
possessions. Le jeu sera gratuit au début ; l’objectif exprimé est de maîtriser
la consommation et les coûts serveur. Une attaque par semaine était une piste
pour respecter cette contrainte, **pas une cadence de jeu arrêtée**. Le PvP n’est
pas encore implémenté.

La nécessité et le sens exact d’un quota restent à confirmer : une attaque lancée et une reçue,
seulement une attaque lancée, ou un seul combat lancé ou subi par semaine.
La limite des attaques lancées ne suffit pas à limiter les attaques reçues :
plusieurs adversaires pourraient chacun dépenser leur attaque sur la même cible.

## Hypothèses de rythme, à valider par le jeu et les mesures

- Compter les engagements par joueur, tous ses villages confondus, pour que
  fonder dix villages ne donne pas dix attaques hebdomadaires.
- Autoriser au maximum une attaque lancée et une attaque reçue par période.
- Préférer sept jours glissants à une remise à zéro le lundi, afin d’éviter
  deux attaques rapprochées de part et d’autre du changement de semaine.
- Réserver la disponibilité de la cible dès la validation d’un départ pour
  empêcher plusieurs attaques concurrentes sur un joueur encore disponible.
- Afficher l’heure de l’impact et les possibilités de défense avant le combat.
  Une défense préparée doit pouvoir se résoudre pendant une absence.

Ces points sont des propositions, pas des règles confirmées. Le choix de la
période, de son point de départ, des annulations et de la consommation du quota
devra être explicite avant toute réalisation. Le renforcement d’un allié doit
également être défini sans permettre de contourner les limites.

## Maîtriser la consommation serveur

Le coût d’une attaque dépend de son traitement et de l’hébergement choisi. Le
nombre de combats ne permet pas, seul, de déduire la consommation totale : la
carte, les synchronisations, les convois, les recherches et les connexions
contribuent aussi à la charge. Aucun hébergeur ni plafond gratuit n’est choisi
dans cette décision.

La proposition d’architecture est de traiter les actions datées : validation du
départ, résolution à l’échéance et retour. La progression des ressources se
calcule depuis un stock et une date, sans écriture chaque seconde. Les animations
restent sur le téléphone. Les états partagés et les résultats militaires sont
vérifiés côté serveur, même si l’affichage est local.

Limiter les données de carte à la région visible, mettre en cache les données
stables et éviter les rafraîchissements permanents inutiles doit précéder un
quota de jeu très restrictif. Par exemple, Firestore facture notamment les
lectures, écritures et mises à jour reçues par les écouteurs ; cela illustre
l’importance du modèle de synchronisation, sans constituer un choix de Firebase.
[Facturation officielle](https://firebase.google.com/docs/firestore/pricing).

Avant de fixer la fréquence des attaques, mesurer les lectures, écritures,
durées de calcul et transferts par joueur actif, par combat et par convoi, puis
projeter la charge totale avec une marge. Les limites techniques de requêtes et
la disponibilité d’une cible doivent être vérifiées côté serveur. Une bêta à
effectif contrôlé permet de mesurer ces valeurs. Les quotas gratuits et les
coûts devront être vérifiés chez le fournisseur retenu à cette étape.

## Articulation avec la Merveille

La coopération économique reste utile même pour un joueur qui ne lance pas
d’attaque. Les ressources envoyées à la ville de construction doivent y arriver
avant d’être dépensées. Les conséquences d’une attaque sur cette ville, ses
stocks, ses convois ou son chantier restent à déterminer : autoriser le PvP
n’implique pas automatiquement la destruction de la Merveille ou la conquête
d’un village.

Les protections géographiques décrites dans l’étude Travian/Elvenar restent des
propositions antérieures. Leur coexistence avec le quota hebdomadaire devra être
tranchée ; elles ne constituent pas une règle du prototype.

## Conditions de réalisation

Un serveur devra vérifier les propriétaires, les deux disponibilités, les troupes
et les horaires dans une opération cohérente. La réservation et la résolution
doivent résister aux départs simultanés, aux reconnexions et aux requêtes répétées.
La défense, les pertes, le butin et le retour ne doivent s’appliquer qu’une fois.
