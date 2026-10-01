# Carte du monde SpriteKit

La géographie reste issue de WorldMap et les territoires de VillageState. Le relief illustré lisse les côtes sans modifier les terrains enregistrés. Forêts et ambre sont dessinés selon les cases réelles ; les capitales utilisent les coordonnées sauvegardées.

Une texture de terrain de 2000 × 2000 pixels est calculée dans une tâche en arrière-plan et conservée en mémoire pour le dernier seed. Les ouvertures suivantes réutilisent la texture. Les intersections du relief sont assemblées en contours continus avant lissage, avec une bordure de sable fine. SpriteKit gère la caméra, les villages, la sélection et le shader de mer. Le rendu est limité à 30 images/seconde et suspendu lorsque l’application devient inactive. Réduire les animations immobilise la mer et supprime les déplacements animés de caméra.

Navigation : glisser, pincer, zoom +/−, vue des quatre villages, boutons de destination et coordonnées accessibles. Le tracé doré indique uniquement le lieu sélectionné, jamais un déplacement militaire réel.

Vérifications : compilation device et simulateur, tests métier. Validation visuelle et performance sur appareil encore nécessaires : le service simulateur ne répond pas dans cet environnement.
