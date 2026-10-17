# Progression du village

## Choix de jeu

Les champs vont du niveau 0 au niveau 10, les douze bâtiments du niveau 1 au
niveau 10 et les armes du niveau 0 au niveau 10 **par type d’unité**. Le joueur
arbitre entre augmenter sa production, agrandir ses réserves et renforcer son
armée. Monter un champ au niveau 10 n’est pas nécessaire pour lancer ses premiers
raids ; ce seuil débloque le bâtiment de production complémentaire correspondant.

Un seul chantier est partagé par les champs, les constructions et les
améliorations urbaines. La Forge possède une recherche d’armes indépendante ;
les doctrines et le recrutement gardent aussi leurs propres files. Le bâtiment
continue de fonctionner à son ancien niveau pendant son amélioration.

## Coûts et temps

`L` désigne le niveau à atteindre. Chaque quantité est arrondie à l’entier
supérieur, sauf les remboursements et les gains des échanges, arrondis vers le bas.

| Action | Coût bois / ambre / vivres | Durée avant bonus |
| --- | --- | --- |
| Champ de bois | `(5L / 0 / plancher(L/3)) × 1,08^(L−1)` | `60 s × 1,45^(L−1)` |
| Champ de vivres | `(4L / 0 / 2L) × 1,08^(L−1)` | idem |
| Champ d’ambre | `(7L / 2L / 3L) × 1,08^(L−1)` | idem |
| Bâtiment | Prix de construction initial × `1,5^(L−1)` | `60 s × 1,5^(L−1)` |
| Armes d’un type d’unité | `(40 / 20 / 30) × 1,6^(L−1)` | `60 s × 1,5^(L−1)` |

La Maison des Veilleurs est offerte au niveau 1 ; ses améliorations utilisent une
base de 40 bois, 10 ambres et 25 vivres. Chaque niveau supplémentaire multiplie la
durée des futurs chantiers par 0,97. La Maison des savoirs divise la durée des
recherches d’armes par `1 + 0,04 × (niveau−1)`. Les délais sont enregistrés au
lancement : un bonus obtenu ensuite ne modifie pas une tâche déjà engagée.

Exemples sans bonus : un bâtiment passe au niveau 2 en 1 min 30 s, au niveau 5 en
5 min 4 s et au niveau 10 en 38 min 27 s. Les armes de niveau 10 coûtent
2 749 bois, 1 375 ambres et 2 062 vivres pour le type choisi.

## Entrepôt et absence de blocage

La réserve initiale contient 300 unités **de chaque ressource**. Un Entrepôt de
niveau `N` donne une capacité de `300 + 500N`, soit 800 au niveau 1, 2 800 au
niveau 5 et 5 300 au niveau 10. Le panneau d’amélioration et la Forge indiquent
quand il faut agrandir l’Entrepôt pour pouvoir payer le prix affiché.

Les tests vérifient que chacun des dix niveaux de l’Entrepôt peut être payé avec
la capacité du niveau précédent. Le passage au niveau 10 coûte 1 730 bois,
193 ambres et 962 vivres, pour une réserve précédente de 4 800. Ils vérifient
aussi que tous les coûts de champs, de bâtiments et d’armes tiennent dans la
capacité finale : le coût maximal actuel d’une ressource est de 2 749, inférieur
à 5 300. Cette vérification doit accompagner toute extension au-delà du niveau 10.

## Effets des niveaux

| Bâtiment | Effet au niveau N |
| --- | --- |
| Maison des Veilleurs | +2N bois, +N ambres, +2N vivres/h ; durée des chantiers × `0,97^(N−1)` |
| Scierie / Ferme / Atelier d’ambre | +8N bois / +8N vivres / +4N ambres par heure ; champ correspondant au niveau 10 requis |
| Entrepôt | Capacité `300 + 500N` par ressource |
| Tour de garde | +20N de défense du port |
| Cour des armes | `30 / (1 + 0,08(N−1))` secondes par unité ; lots de 20 au plus, armée limitée à 100 |
| Maison des savoirs | Doctrine : `60 / (1 + 0,08(N−1))` secondes ; accélère aussi les recherches d’armes |
| Marché | Valeur conservée : `50 + 2,5(N−1)` %, soit 72,5 % au niveau 10 ; aucun aller-retour rentable |
| Forge | Autorise les armes jusqu’au niveau N pour chaque type d’unité débloqué |
| Infirmerie | Pertes en victoire : `10 − 0,5(N−1)` % ; défaite : `35 − (N−1)` %. Mage : −5 points en victoire, minimum 1 % |
| Quai d’expédition | Transport : `25 + 5(N−1)` %, plus le bonus humain de 20 points ; butin maximal `90 + 20(N−1)` par ressource |

Un niveau d’armes ajoute 1 attaque et 1 défense à chaque unité du type choisi,
y compris les prochaines recrues. Améliorer les Gardiens ne renforce pas les
Pillards. Une seule recherche d’armes progresse à la fois. Les niveaux d’armes,
soins et bonus de transport d’un raid ou d’un convoi sont figés au départ.

## Sauvegardes et vérifications

Les sauvegardes passent en version 14. Les bâtiments existants commencent au
niveau 1. Les anciennes recherches d’armes communes restent acquises pour tous
les types, y compris ceux débloqués plus tard. Une ancienne recherche commune
en cours se termine avec son effet commun ; les suivantes sont individuelles.
Les anciens travaux conservent leur prix et leur échéance.

Les nouvelles tâches paient au lancement, persistent et se terminent aussi hors
ligne. Annuler un chantier rembourse 50 % du coût payé par ressource et conserve
le niveau déjà acquis. Un bâtiment en amélioration ne se déplace pas ; les niveaux
des autres bâtiments suivent leurs déplacements.

Les vérifications automatisées couvrent tous les bâtiments jusqu’au niveau 10,
les armes par type jusqu’au niveau 10, les capacités, les coûts et durées croissants,
les remboursements, le chantier commun, les effets différés, les sauvegardes,
les anciens travaux et la résolution hors ligne. Un parcours neuf atteint un
premier raid en moins d’une heure sans maximiser un champ.

La fin de partie vise une [Merveille soutenue par au moins dix villages](MERVEILLE.md),
avec des ressources livrées vers une ville de construction. Cette cible demandera
une progression du stockage et du transport au-delà des limites du prototype.

Ces coefficients sont un premier équilibrage de prototype. Ils restent à mesurer
avec des joueurs : délai du premier raid, fréquence de réserve pleine, choix
économiques et militaires, temps d’attente des niveaux élevés. La colonisation et
le monde multijoueur restent des systèmes futurs.
