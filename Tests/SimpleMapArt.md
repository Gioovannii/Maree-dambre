# Cartes sobres

Fonds produits avec l’outil intégré de génération d’images, à partir des anciennes cartes. Assets : `CentreSobre.imageset` et `ChampsSobres.imageset` dans `MareesAmbre/Assets.xcassets`.

Consigne : conserver le style peint méditerranéen et le format portrait ; retirer bâtiments, champs, parcelles, clôtures, accessoires, ponts, bateaux, cascades et cristaux. Garder une grande surface centrale de prairie vide, une côte calme et quelques arbres en périphérie. Aucun texte ni grille dans l’image.

Les contours des parcelles sont dessinés dans SwiftUI pour correspondre aux zones tactiles. Neuf lots de construction et le bâtiment principal sont visibles au centre. Les deux lots historiques supplémentaires restent affichés lorsqu’ils sont occupés, afin de préserver les sauvegardes.

## Parcelles de ressources

Assets intégrés : ParcelleBois, ParcelleVivres et ParcelleAmbre. Outil intégré de génération d’images, fond transparent. Consigne commune : parcelle carrée isolée, vue isométrique légèrement plongeante, bordure basse de pierre claire sur quatre côtés, illustration peinte méditerranéenne, sans texte ni personnage. Bois : cinq arbres et une souche. Vivres : terre labourée et quelques jeunes pousses. Ambre : roches calcaires traversées de veines dorées.

## Derniers ajustements

Les lots du centre sont visibles uniquement pendant le placement ou le déplacement. Le bouton Construire est dans les commandes de GameView, au-dessus de la navigation iPhone et dans la colonne iPad.

Images générées avec l’outil intégré et enregistrées dans Assets.xcassets : MaisonVeilleurs (maison principale compacte de pierre claire, bois et tuiles, petite lanterne, bannière dorée, vue isométrique, fond transparent) et ChantierCouvert (échafaudages de bois entourant un bâtiment couvert de toile beige, fondations visibles, même style, fond transparent). ChantierCouvert remplace les étapes progressives.
