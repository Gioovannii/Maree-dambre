# Bâtiments du Centre-ville

Les bâtiments se placent uniquement sur les lots du Centre-ville, à raison d’un exemplaire par type et par village. La vue Ressources montre les forêts, cultures et veines d’ambre autour du village : on améliore ces terrains du niveau 0 au niveau 10, sans y poser de bâtiment. Un seul terrain de la ressource concernée au niveau 10 suffit à débloquer et activer son bâtiment de production. Les copies construites avant la règle d’unicité sont retirées de façon déterministe et leur coût est remboursé.

## Jouables dans le prototype

| Bâtiment | Rôle actuel | Effet |
| --- | --- | --- |
| Maison des Veilleurs | Cœur du village, présent au départ | +2 bois, +1 ambre et +2 vivres par heure |
| Scierie | Transforme le bois récolté autour du village | +8 bois par heure |
| Ferme | Soutient l’approvisionnement du village | +8 vivres par heure |
| Atelier d’ambre | Travaille le minerai des gisements | +4 ambre par heure |
| Tour de garde | Poste de veille décoratif dans cette version | Aucun effet sur les combats actuels ; les factions n’attaquent pas le village |
| Entrepôt | Agrandit les réserves | +500 de capacité pour chaque ressource |
| Maison des savoirs | Recherche | Débloque les deux unités du peuple choisi, une minute par unité |
| Cour des armes | Recrutement | Entraîne jusqu’à 20 unités, 30 secondes par unité ; file unique, limite de 100 |
| Marché | Échanges locaux | Lots de 20 ressources ; l’ambre vaut deux fois le bois ou les vivres ; le marché conserve la moitié de la valeur |
| Forge | Amélioration des armes | Trois recherches de 60 s ; chaque niveau ajoute 1 attaque à toutes les unités |
| Infirmerie | Soins après combat | Pertes de 10 % en victoire (5 % avec un mage), 35 % en défaite |
| Quai d’expédition | Transport et départs | +25 % de transport, cumulable avec le bonus humain ; plafond de butin porté de 60 à 90 par ressource |

Les douze types correspondent désormais aux douze lots du Centre-ville, Maison des Veilleurs comprise. Les quatre nouveaux bâtiments utilisent le chantier urbain habituel (60 s, exemplaire unique, annulation remboursée à 50 %), sans prérequis de champ au niveau 10.

### Échanges du Marché

Un lot donne 20 bois contre 10 vivres ou 5 ambres, 20 vivres contre 10 bois ou 5 ambres, ou 20 ambres contre 20 bois ou 20 vivres. On peut échanger de 1 à 10 lots à la fois. L’aperçu annonce exactement les quantités avant confirmation. Un stock insuffisant ou une réserve d’arrivée trop petite refuse tout l’échange, sans dépense ni perte. Les échanges sont immédiats et sauvegardés ; aucune boucle d’échange ne crée de ressources.

### Recherches de la Forge et raids

Les niveaux d’armes 1, 2 et 3 coûtent respectivement 40/20/30, 80/40/60 et 120/60/90 (bois/ambre/vivres). Une seule recherche d’armes progresse à la fois, indépendamment du chantier et des doctrines de la Maison des savoirs. Les coûts sont payés au lancement ; la recherche se termine aussi hors ligne. Le bâtiment reste au niveau 1 : les trois niveaux concernent les armes, et apparaissent dans son panneau.

L’attaque, les taux de pertes, le bonus de transport et le plafond de butin sont enregistrés au départ de chaque nouveau raid. Une recherche ou un bâtiment terminé pendant son trajet profite au raid suivant. En victoire les pertes s’arrondissent vers le bas par type d’unité, en défaite vers le haut. Le Quai ne change pas la durée ni le temps de récupération des factions ; les survivants et les réserves restent les limites réelles du butin.

Les sauvegardes des versions 2 à 10 migrent vers la version 11 sans modifier les réserves, bâtiments ou troupes. Les anciennes expéditions conservent leurs règles antérieures ; les armes commencent au niveau 0. Les tests couvrent les échanges, recherches, bonus figés au départ, reprise hors ligne, migration et sauvegarde d’un Centre complet.

Les champs de niveau 10 sont une condition de production et de construction : forêt pour la Scierie, culture pour la Ferme, veine d’ambre pour l’Atelier d’ambre. Les coûts de champs sont réglés pour qu’un village neuf puisse atteindre son premier seuil en quelques heures, et non en plusieurs jours.

Ces bâtiments sont au niveau 1 dans le prototype. Le marqueur numérique en verre de mer et ambre indique ce niveau ; l’amélioration des bâtiments urbains viendra avec les mécaniques correspondantes.

## Suite prévue, à construire quand leur mécanique sera jouable

| Bâtiment | Rôle envisagé |
| --- | --- |
| Caserne | Entraînement et garnison des troupes |
| Spécialisations d’armes | Étendre les recherches de la Forge avec des choix par unité |
| Maison des éclaireurs | Missions de reconnaissance de la carte |
| Maison des colons | Préparation de nouveaux villages |
| Missions côtières | Étendre le Quai d’expédition au-delà des raids actuels |
| Remparts | Défense passive du Centre-ville |

Les bâtiments de production demandent un champ niveau 10 correspondant. Une production existante se met en pause sous ce seuil et reprend dès qu’un champ correspondant atteint le niveau requis.

Le lot 12 (identifiant interne 23) est désormais réservé au Quai, au bord de l’eau. Les autres bâtiments restent sur les lots terrestres. Un ancien Quai placé à l’intérieur du village est échangé avec l’occupant éventuel de la rive ; les chantiers conservent leur coût et leur date de fin. Le Quai reste fixé sur la rive.
