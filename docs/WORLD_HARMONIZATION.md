# Harmonisation de l’archipel

La carte reprend les matières du Centre et du domaine : mer bleue et turquoise,
sable ivoire, pierre claire, végétation méditerranéenne et lumière chaude.
Les contrôles utilisent le bleu profond, l’ambre et les caractères du jeu.

## Terrain et navigation

Les 40 000 cases et les coordonnées sauvegardées restent celles de `WorldMap`.
Les contours sont lissés et légèrement irrégularisés au rendu ; les arbres et
affleurements suivent les cases de forêt et d’ambre. Le décor est une texture
calculée en fond, pas une image fixe portant de fausses destinations.

Le terrain est dessiné dans une texture transparente de 3 200 × 3 200 pixels,
au-dessus de la mer SpriteKit. Des lavis colorés nuancent les plaines ;
les rivages ont une transition turquoise fine, du sable et de l’écume. L’atlas est découpé
et réduit en mémoire avant peinture ; la texture finale est mise en cache pour
la dernière graine, puis réutilisée pendant le déplacement et le zoom.

Les villages occupent environ 34 points à l’échelle régionale, avec des noms
indépendants du décor. Les noms des villages non sélectionnés se masquent à
grande distance. Zoom et vue d’ensemble sont sur la carte ; les destinations
restent de vrais boutons SwiftUI sous celle-ci. Les gestes sont attachés au
terrain pour éviter qu’un bouton sélectionne aussi la case située derrière lui.

Les voisins simulés ont des pseudonymes courts, déterminés par la graine et
l’identifiant existant. Leur fiche distingue le pseudonyme, la tribu et le
statut d’IA. Cela ne crée ni compte joueur ni nouveau voisin dans la simulation.

La hauteur de carte s’adapte à la fenêtre. Les grandes tailles de texte gardent
un écran défilant et les commandes accessibles. La mer est figée avec Réduire les
animations et en capture déterministe ; la scène est suspendue en arrière-plan.
La légende passe en colonne aux tailles d’accessibilité. Sur iPad, la fiche de
la sélection est placée dans le panneau de droite, à côté de la carte.

## Asset généré

ImageGen intégré a produit l’atlas transparent à partir de la référence de style
`CentreAmbreVivant.imageset/CentreAmbreVivant.png`. Il est livré dans
`MareesAmbre/Assets.xcassets/ArchipelVegetation.imageset/ArchipelVegetation.png`.
Les six cellules sont découpées par le moteur ; le fichier original conserve
sa transparence et sa résolution.

Un second asset, `MareesAmbre/Assets.xcassets/ArchipelPrairie.imageset/ArchipelPrairie.png`,
fournit la matière du sol, mélangée aux lavis de terrain. Il est généré avec le
même outil intégré et la même référence de style, sans transparence.

Prompt utilisé :

> Use case: stylized-concept. Create a production game sprite atlas on a genuinely TRANSPARENT background for the world map of Les Marées d’Ambre. The reference image is ONLY a style reference: match its beautiful sunlit Mediterranean fantasy painterly 3D illustration, ivory limestone, olive greens, cypress trees and warm amber highlights. This is a NEW asset, do not reproduce its city layout. Composition: perfectly regular 3 COLUMNS by 2 ROWS, six isolated environmental sprites, each centered in its own equal cell with generous fully transparent margins, absolutely no overlap between cells. Row 1 left: a compact natural grove of 3 olive trees; row1 middle: 3 slender cypresses and a low bush; row1 right: a lush mixed grove of pines and olives. Row2 left: a cluster of cream limestone outcrops with small golden AMBER crystals, row2 middle: a larger rocky limestone hill with olive bushes and a few exposed amber veins, row2 right: pale rocky coastal outcrop with 2 cypresses and Mediterranean scrub. High overhead three-quarter map view with visible treetops, consistent light from top left, natural volumes, crisp attractive silhouettes that read at tiny size. Objects fill at most 70% of each cell. Tiny soft contact shadows only immediately under each object; no ground tiles, no square bases, no scenery background, no water, no buildings, no roads, NO text, no labels, no UI, no border, no drawn grid, no checkerboard. Square atlas.

Prompt du sol :

> Use case: stylized-concept. NEW game terrain material texture for a Mediterranean fantasy world map matching the painterly warm sunlight, ivory limestone dust and olive/sage greens of the reference. Reference is STYLE ONLY. A completely flat orthographic TOP DOWN seamless tileable meadow ground texture, fills the entire square image edge to edge. Subtle short sage-green and moss-green grasses mixed with sunlit dry ochre grass, tiny scattered herb tufts, very small pale limestone flecks, natural soft organic patches of bare warm beige earth. Rich fine painterly detail but calm broad low-contrast color variation, a harmonious slightly desaturated sage and honey palette. Intended to tile underneath tiny forest and village sprites, so texture details must be small and evenly distributed. Seamlessly wrapping all four edges. NO trees, NO bushes, NO large rocks, NO mountains, NO hills with cast shadows, NO rivers or water, NO buildings, NO roads, NO paths, NO grid, NO obvious repeating decorative motif, NO text, NO border, NO vignettes, NO perspective horizon. A uniform flat ground material, not an aerial landscape composition.

## Limites

Le monde conserve les trois voisins simulés du prototype. La colonisation,
les échanges entre joueurs et la Merveille ne sont pas implémentés par cette
refonte. Les performances sur appareil physique et la lisibilité d’une région
plus peuplée restent à mesurer.

## Correction de la mer

La surface utilise `MareesAmbre/Assets.xcassets/ArchipelMer.imageset/ArchipelMer.png`,
une texture de mer peinte générée avec ImageGen intégré, à partir de la même
référence du Centre, sans transparence. `WorldSeaSurface` la répète dans les
coordonnées du monde et lui applique une houle visible à l’échelle régionale.
La déformation et le courant ont été renforcés après un premier aperçu trop discret ;
des variations douces de lumière accompagnent la houle. Les taches lumineuses
sinusoïdales et le halo turquoise large ont été supprimés. Les rivages ont été
affinés pour éviter l’aspect de bassins bordés d’un anneau lumineux.

Prompt de la mer :

> Use case: stylized-concept. Asset type: seamless top-down OCEAN WATER MATERIAL for the Mediterranean fantasy world map of Les Marées d’Ambre. The reference is STYLE ONLY: match the beautiful blue sea in the reference coastal village. Produce an entirely water-filled square, true orthographic overhead view, richly painted high-end game illustration, clear azure and medium cobalt blue water with a very subtle turquoise undertone, small delicate irregular wind ripples and fine muted pale blue highlights, subtle depth and moving-water appearance. Small-scale texture suitable for repeating under a zoomable world map. Natural softly intertwined irregular ripples, no regular wave rows, no foam, no large waves, no circular caustic blobs, no glowing spots, no broad light patches, no sparkling stars, no horizon, no land, no coast, no objects, no boats, no rocks, no UI, no text, no gradient toward the borders. Even color and lighting across the whole material. The texture must tile seamlessly on every edge, subdued contrast to keep the villages and terrain readable. Clean blue sea, not teal swimming-pool water.
