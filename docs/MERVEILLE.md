# Le Grand Phare — objectif de campagne

## Implémenté le 27 octobre 2026

Le domaine comprend une capitale et deux colonies au maximum. Une fois les trois
villages fondés, la reconstruction du Grand Phare devient accessible dans Missions.
Cette direction remplace l’ancienne proposition collective de dix villages.

Les ressources de chaque étape sont prélevées uniquement dans la capitale.
Les convois existants permettent de réunir la production des colonies ; leurs
cargaisons en transit ne sont jamais comptées comme du stock disponible.
Le chantier possède sa propre file et ne bloque pas les améliorations ordinaires.

| Étape | Bois | Ambre | Vivres | Travaux |
| --- | ---: | ---: | ---: | ---: |
| Restaurer les jetées | 1 200 | 600 | 900 | 2 h |
| Relever la tour | 2 600 | 1 200 | 1 800 | 4 h |
| Réparer le cœur d’ambre | 2 000 | 4 000 | 2 500 | 6 h |
| Poser la lentille | 3 200 | 4 200 | 3 000 | 8 h |
| Allumer le Grand Phare | 5 000 | 5 000 | 5 000 | 12 h |

Total : 14 000 bois, 15 000 ambre, 13 200 vivres et 32 heures de travaux,
hors collecte et transport. Les prix tiennent dans l’entrepôt existant de niveau 10
(capacité 5 300 par ressource). Chaque étape est payée intégralement avant de
commencer, après confirmation ; elle ne peut pas être annulée. La suivante exige
une nouvelle décision et un nouveau paiement. Les délais continuent hors ligne.
Ces valeurs constituent un premier réglage, pas une durée de campagne validée.

## Victoire et poursuite de la partie

L’allumage enregistre la fin de campagne une seule fois. Les raids automatiques
cessent dans tout le domaine, y compris une attaque encore planifiée à la date
de reprise. Les villages restent jouables ; les expéditions et les campagnes
manuelles restent accessibles. Aucun compte à rebours ne force à recommencer.

La première version propose une victoire par reconstruction économique. Elle
n’implémente pas les pièces uniques, le siège final ou les routes déverrouillées
décrits dans la proposition narrative historique de VISION-SOLO.md. Aucun monde
partagé, classement Game Center ou vainqueur de serveur n’est annoncé.

## Sauvegarde et vérifications

La progression appartient au domaine et suit le joueur lorsqu’il change de village.
Les instantanés des villages inactifs ne contiennent pas de copie du chantier.
Le schéma 20 préserve les anciennes parties et empêche les anciennes versions de
l’app de réécrire une progression qu’elles ne comprennent pas.

Les vérifications couvrent les prérequis, le stockage, le paiement unique,
les colonies non débitées, le changement de village, les échéances exactes,
la reprise hors ligne, la victoire persistante, l’arrêt des raids, les sauvegardes
authentifiées et l’isolation du mode test. Les stocks sont accordés dans ces tests
transactionnels : ils ne mesurent pas le temps réel nécessaire pour financer le
Phare à partir d’une nouvelle partie. Cet audit économique reste à réaliser.

Aperçus reproductibles : `lighthouse` et `lighthouseVictory` dans
`Scripts/check-ui-snapshots.sh`.
