# Les Marées d’Ambre

Prototype iOS solo et hors ligne. Ouvrir `MareesAmbre.xcodeproj` et choisir le schéma **MareesAmbre**.

## Boucle jouable

1. Améliorer les champs et augmenter les réserves, visibles sous la forme stock / capacité.
2. Amener un champ de forêt, de culture ou d’ambre au niveau 10. Un seul champ suffit pour débloquer le bâtiment producteur associé.
3. Construire la Maison des savoirs, rechercher une unité, puis bâtir la Cour des armes pour l’entraîner.
4. Depuis Monde, attaquer une des trois factions locales. Après l’expédition, récupérer le butin et le rapport de pertes.

Les recherches, chantiers, entraînements, productions et expéditions sont enregistrés localement et rattrapés au retour dans le jeu. Le premier raid revient après deux minutes. Les factions et leur progression sont simulées sur l’appareil ; il n’y a ni compte, ni service Firebase, ni multijoueur.

## Systèmes

- **Ressources et Centre** : deux cartes plein écran, dix terrains producteurs et douze lots urbains. Chaque bâtiment n’existe qu’en un exemplaire. Un seul chantier peut progresser à la fois ; son annulation rembourse la moitié du coût.
- **Production** : bois, ambre et vivres s’accumulent jusqu’à la capacité de la réserve, 300 au départ et +500 par Entrepôt. Les fractions et l’heure de dernière production sont sauvegardées.
- **Armée** : Maison des savoirs, Cour des armes, trois doctrines, entraînement et raids contre trois factions bots. Une expédition mobilise l’armée disponible. L’écran annonce les pertes prévues et la défense avant le départ.
- **Monde** : carte fictive de 200 × 200 cases, déplacements et zoom locaux. Les factions gagnent un niveau et étendent leur territoire toutes les six heures, jusqu’au niveau 10 et 64 cases.
- **Démarrage** : prologue, choix d’un clan, puis village généré avec une graine hebdomadaire UTC.
- **Live Activity** : les chantiers affichent le temps restant dans la Dynamic Island et sur l’écran verrouillé.

## Vérifier la base

Lancer `sh Scripts/check-domain.sh` pour les règles de ressources, constructions, migration des sauvegardes, entraînement, raids, pertes, butin et reprise hors ligne.

Lancer `zsh Scripts/check-ui-snapshots.sh verify` pour comparer les quatre captures iPhone aux références. Pour contrôler un chantier visuellement, lancer le simulateur avec `--ui-snapshot --snapshot-center --snapshot-construction`.

Avant une bêta, faire une partie neuve sur iPhone jusqu’au premier raid. Noter le temps nécessaire pour atteindre le niveau 10, les points où les ressources manquent, et si l’écran explique clairement le prochain objectif. Aucun système en ligne n’est nécessaire pour ce test.

## Limites de cette version

Les raids sont des résolutions locales abstraites : pas de déplacement animé jusqu’à la capitale, pas de contrôle manuel du combat, de fondation de nouveaux villages, de classement, de compte joueur ou de synchronisation entre appareils. Les coûts et forces des factions sont un premier équilibrage à valider en jouant.
