# Les Marées d’Ambre

Prototype iOS solo et hors ligne. Ouvrir `MareesAmbre.xcodeproj` et choisir le schéma **MareesAmbre**.

## Boucle jouable

1. Améliorer les champs et augmenter les réserves, visibles sous la forme stock / capacité.
2. Développer les bâtiments du Centre et l’Entrepôt. À plus long terme, amener un champ au niveau 10 débloque le bâtiment producteur associé.
3. Construire la Maison des savoirs, rechercher une unité, puis bâtir la Cour des armes pour l’entraîner.
4. Depuis Monde, attaquer une des trois factions locales. Après l’expédition, récupérer le butin et le rapport de pertes.

Les recherches, chantiers, entraînements, productions et expéditions sont enregistrés localement et rattrapés au retour dans le jeu. Le premier raid revient après deux minutes. Les factions et leur progression sont simulées sur l’appareil ; il n’y a ni compte, ni service Firebase, ni multijoueur.

## Systèmes

- **Amélioration des champs et bâtiments** : dix niveaux, coûts et délais croissants. La production
  précédente continue jusqu’à la fin. Champs et bâtiments partagent un seul chantier ;
  annuler rembourse 50 % du coût, arrondi à l’entier inférieur par ressource.
  Les travaux sont sauvegardés et terminent aussi pendant l’absence.

- **Domaine vivant** : les dix exploitations sont peintes dans le décor ; seuls les niveaux et les chantiers changent. La mer ondule à 24 images/s et sept passants marchent sur les chemins et le pont à 30 images/s. Les silhouettes fixes ont été retirées du décor. Les animations se suspendent hors de l’app et respectent Réduire les animations. Stocks, sélection et améliorations restent de vrais contrôles SwiftUI. Voir `docs/LIVING_DOMAIN.md`.
- **Centre harmonisé** : décor en pierre claire, titres et médaillons partagés avec le domaine, mer animée et passants. Les bâtiments restent déplaçables et les lots inchangés. Voir `docs/CENTER_HARMONIZATION.md`.
- **Ressources et Centre** : deux cartes plein écran, dix terrains producteurs et douze lots urbains. Chaque bâtiment n’existe qu’en un exemplaire. Un seul chantier peut progresser à la fois ; son annulation rembourse la moitié du coût.
- **Production** : bois, ambre et vivres s’accumulent jusqu’à la capacité de la réserve, 300 au départ puis 300 + 500 par niveau d’Entrepôt. Les fractions et l’heure de dernière production sont sauvegardées.
- **Armée** : Maison des savoirs, Cour des armes, deux unités propres à chaque peuple, entraînement et raids contre trois factions bots. Le joueur choisit les effectifs envoyés par type et conserve le reste au village. L’écran annonce la force, les pertes prévues et les effectifs gardés avant le départ ; le bonus du mage dépend de sa présence dans l’expédition.
- **Douze bâtiments améliorables** : chaque niveau renforce leur effet. La Forge recherche dix niveaux d’armes séparément par type d’unité (+1 attaque et défense par niveau), dans la limite du niveau de la Forge. Les effets des raids sont fixés au départ ; les recherches d’armes se terminent aussi hors ligne. Voir [la progression](docs/PROGRESSION.md) pour les coûts, durées et capacités, et `docs/BATIMENTS.md` pour les règles des bâtiments.
- **Monde** : carte fictive de 200 × 200 cases, mer turquoise, côtes ivoire et végétation illustrée dans le style du Centre. Petits villages et pseudonymes des voisins simulés, tribus dans les fiches, déplacements et zoom locaux. Les factions gagnent un niveau et étendent leur territoire toutes les six heures, jusqu’au niveau 10 et 64 cases. Voir [l’harmonisation de la carte](docs/WORLD_HARMONIZATION.md).
- **Démarrage** : prologue et choix d’un clan, puis accès direct au village. Le guide en modale a été retiré ; le futur onboarding TipKit avec un personnage et un chat dédié est reporté à la fin. La graine initiale dépend de la semaine UTC, mais le village reste le même ensuite, même au changement de semaine.
- **Live Activity** : les chantiers affichent le temps restant dans la Dynamic Island et sur l’écran verrouillé.

## Vérifier la base

Sur iPad, les fenêtres d’au moins 700 × 600 points affichent la carte et les détails
côte à côte. Les parcelles se sélectionnent sans quitter la carte. La carte garde
ses proportions ; les fenêtres plus étroites utilisent la présentation compacte.
Contrôler Ressources, Centre, recherche, recrutement et Monde en portrait et paysage,
puis en fenêtre réduite, avant de publier une version iPad.

Avec les tailles de texte d’accessibilité, les stocks s’affichent en colonne et
les écrans principaux deviennent défilants. Les parcelles apparaissent dans une
liste avec leurs noms complets ; leur sélection et le déplacement des bâtiments
conservent les mêmes actions. Contrôler aussi ces parcours à la plus grande taille
de texte, puis rétablir le réglage du simulateur avant les comparaisons de captures.

Lancer `sh Scripts/check-domain.sh` pour les règles de ressources, constructions, migration des sauvegardes, entraînement, raids, pertes, butin et reprise hors ligne.

Les validations refusent aussi les dates hors de l’intervalle `Date.distantPast...Date.distantFuture`, les fractions de production invalides et les chantiers qui écraseraient un bâtiment ou sortiraient des emplacements autorisés. Les données refusées sont conservées pour le diagnostic.

Lancer `sh Scripts/check-session.sh` pour la reprise réelle de la session, les mises à jour automatiques et la protection des sauvegardes illisibles. Ces vérifications utilisent des préférences isolées ; elles ne touchent pas à une partie existante. Une sauvegarde illisible reste intacte tant que le joueur ne fonde pas un nouveau village. À cette action, une copie des données originales est conservée sous une clé `village.unreadable.<graine>.<identifiant>` avant toute nouvelle sauvegarde. Cette copie sert au diagnostic ; l’app ne propose pas encore sa restauration.

Pour contrôler l’avertissement de sauvegarde illisible visuellement, lancer avec `--ui-snapshot --snapshot-save-recovery`. Le mode `--ui-snapshot` fige aussi l’animation de l’eau pour rendre les captures comparables.

Lancer `zsh Scripts/check-ui-snapshots.sh verify` pour comparer les neuf captures iPhone aux références : Ressources, Centre, amélioration, Monde, marché, forge, infirmerie, quai et contrats maritimes. Lancer `SNAPSHOT_DEVICE=ipad zsh Scripts/check-ui-snapshots.sh verify` pour les trois captures iPad. Les scripts détectent Xcode et le simulateur iOS 27.0 correspondant ; `DEVELOPER_DIR` et `SIMULATOR_ID` permettent de les choisir explicitement. La langue de l’app est fixée au français et la date de la barre d’état est figée. Après contrôle visuel d’un changement voulu, le mode `record` actualise les références. Pour contrôler un chantier visuellement, lancer le simulateur avec `--ui-snapshot --snapshot-center --snapshot-construction`. Pour tester la fondation sans toucher aux sauvegardes, utiliser `--ui-snapshot --snapshot-new-village`.

Pour voir les douze bâtiments sans toucher à une sauvegarde, lancer avec `--ui-snapshot --snapshot-center --snapshot-developed`. Les arguments `--ui-snapshot --snapshot-market`, `--ui-snapshot --snapshot-forge`, `--ui-snapshot --snapshot-infirmary` ou `--ui-snapshot --snapshot-expeditionQuay` ouvrent leurs panneaux dans une partie de démonstration. Ajouter `--snapshot-actions` pour cadrer le bas de la fiche et ses commandes.

Avant une bêta, faire une partie neuve sur iPhone jusqu’au premier raid, sans imposer un champ niveau 10 avant le combat. Noter les temps d’attente, les points où les ressources manquent et si l’écran explique clairement le prochain objectif. Mesurer ensuite la progression vers les niveaux élevés et l’agrandissement de la réserve. Aucun système en ligne n’est nécessaire pour ce test.

## Limites de cette version

La campagne côtière s’ouvre volontairement depuis Monde → Organiser la défense,
après construction de la Cour des armes et recrutement d’une unité. Le premier
assaut arrive après deux marées, les suivants toutes les trois marées. Le joueur
décide chaque passage ; les absences ne font avancer aucune attaque. La Tour de
garde ajoute 20 de défense par niveau à la garnison du port. Les expéditions et productions
gardent leurs délais réels. Le Marché et le Monde donnent accès aux contrats maritimes : 20 bois et 5 vivres
au départ, escorte choisie, route sûre de trois marées (18 ambres) ou route
exposée de deux marées (26 ambres, force ennemie 24). Les escortes reviennent après
les combats ; les paiements restent au comptoir si la réserve est pleine. Chaque
route propose une offre toutes les six marées. Routes sur la carte, alliances,
avant-postes, merveille et classements restent à développer.

La cible de fin de partie est une Merveille nécessitant au moins dix villages
et des livraisons coordonnées vers une ville de construction. Le seuil est fixé ;
la répartition des villages entre joueurs et les règles du projet restent à préciser.
Voir [la conception de la Merveille](docs/MERVEILLE.md).

Le manifeste `PrivacyInfo.xcprivacy` déclare l’utilisation de `UserDefaults` pour les sauvegardes locales (motif Apple `CA92.1`), sans suivi ni collecte de données. Vérifier sa présence dans une archive avec `python3 Scripts/check-archive.py /chemin/vers/MareesAmbre.xcarchive`, puis effectuer la validation de distribution signée dans Xcode avant un envoi.

Les raids sont des résolutions locales abstraites : pas de déplacement animé jusqu’à la capitale, pas de contrôle manuel du combat, de fondation de nouveaux villages, de classement, de compte joueur ou de synchronisation entre appareils. Les coûts et forces des factions sont un premier équilibrage à valider en jouant.
