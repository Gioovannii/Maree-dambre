# Carte du monde SpriteKit

La géographie reste issue de WorldMap et les territoires de VillageState. Le relief illustré lisse les côtes sans modifier les terrains enregistrés. Forêts et ambre sont dessinés selon les cases réelles ; les capitales utilisent les coordonnées sauvegardées.

Une texture de terrain de 3200 × 3200 pixels est calculée dans une tâche en arrière-plan et conservée en mémoire pour le dernier seed. Les ouvertures suivantes réutilisent la texture. Les intersections du relief sont assemblées en contours continus avant lissage. Hauts-fonds, sable ivoire et écume bordent les côtes ; un atlas illustré fournit la végétation et les rochers. SpriteKit gère la caméra, les villages, la sélection et le shader de mer. Le rendu est limité à 30 images/seconde et suspendu en arrière-plan. Réduire les animations immobilise la mer et supprime les déplacements animés de caméra.

Navigation : glisser, pincer, zoom +/−, vue des quatre villages, boutons de destination et coordonnées accessibles. Le tracé doré indique uniquement le lieu sélectionné, jamais un déplacement militaire réel.

Échelle des villages : repères d’environ 34 points à l’échelle régionale,
réduits à grande distance. La sélection et la vue d’ensemble recalculent aussi
cette échelle. Les noms des villages non sélectionnés sont masqués au-delà
d’un facteur caméra de 5 pour préserver la place entre les voisins. Les boutons
de destination sous la carte conservent l’accès aux noms complets. Cette
carte reprend désormais la direction méditerranéenne illustrée, avec de petits
repères et des noms indépendants du décor. Les voisins portent un pseudonyme
stable ; leur tribu et leur statut d’IA sont indiqués dans la fiche.

Parcours à contrôler : ouverture de Monde, sélection directe d’un village,
boutons des voisins, zoom sans changement de sélection, glissement du terrain,
retour à la vue d’ensemble et navigation vers Missions. Contrôler le cadrage
sur iPhone et iPad ainsi que les noms et commandes en grandes tailles de texte.

Vérifications : compilations Debug/Release, génération du monde, traductions
françaises/anglaises, captures iPhone et iPad ; sélection directe et par bouton,
zoom sans changement de sélection, glissement et retour depuis Missions.
Les grandes tailles de texte utilisent une légende en colonne ; la fiche de
sélection est à droite sur iPad. Performance et lisibilité avec une population
plus dense restent à contrôler sur appareil.
