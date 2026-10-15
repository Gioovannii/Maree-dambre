# Bâtiments du Centre-ville

Les bâtiments se placent uniquement sur les lots du Centre-ville, à raison d’un exemplaire par type et par village. La vue Ressources montre les forêts, cultures et veines d’ambre autour du village : on améliore ces terrains du niveau 0 au niveau 10, sans y poser de bâtiment. Un seul terrain de la ressource concernée au niveau 10 suffit à débloquer et activer son bâtiment de production. Les copies construites avant la règle d’unicité sont retirées de façon déterministe et leur coût est remboursé.

## Jouables dans le prototype

| Bâtiment | Rôle actuel | Effet |
| --- | --- | --- |
| Maison des Veilleurs | Cœur du village, présent au départ | +2 bois, +1 ambre et +2 vivres par heure |
| Scierie | Transforme le bois récolté autour du village | +8 bois par heure |
| Ferme | Soutient l’approvisionnement du village | +8 vivres par heure |
| Atelier d’ambre | Travaille le minerai des gisements | +4 ambre par heure |
| Tour de garde | Fortification du port contre les corsaires | +20 de défense, cumulés avec les unités présentes au village |
| Entrepôt | Agrandit les réserves | +500 de capacité pour chaque ressource |
| Maison des savoirs | Recherche | Débloque les deux unités du peuple choisi, une minute par unité |
| Cour des armes | Recrutement | Entraîne jusqu’à 20 unités, 30 secondes par unité ; file unique, limite de 100 |
| Marché | Échanges et contrats | Dépannage immédiat par lots de 20 ; contrats maritimes avec cargaison, escorte et paiement différé |
| Forge | Amélioration des armes | Trois recherches de 60 s ; chaque niveau ajoute 1 attaque et 1 défense par unité |
| Infirmerie | Soins après combat | Pertes de 10 % en victoire (5 % avec un mage), 35 % en défaite |
| Quai d’expédition | Transport et départs | +25 % de transport, cumulable avec le bonus humain ; plafond de butin porté de 60 à 90 par ressource |

Les douze types correspondent désormais aux douze lots du Centre-ville, Maison des Veilleurs comprise. Les quatre nouveaux bâtiments utilisent le chantier urbain habituel (60 s, exemplaire unique, annulation remboursée à 50 %), sans prérequis de champ au niveau 10.

### Échanges du Marché

Un lot donne 20 bois contre 10 vivres ou 5 ambres, 20 vivres contre 10 bois ou 5 ambres, ou 20 ambres contre 20 bois ou 20 vivres. On peut échanger de 1 à 10 lots à la fois. L’aperçu annonce exactement les quantités avant confirmation. Un stock insuffisant ou une réserve d’arrivée trop petite refuse tout l’échange, sans dépense ni perte. Les échanges sont immédiats et sauvegardés ; aucune boucle d’échange ne crée de ressources.

### Recherches de la Forge et raids

Les niveaux d’armes 1, 2 et 3 coûtent respectivement 40/20/30, 80/40/60 et 120/60/90 (bois/ambre/vivres). Une seule recherche d’armes progresse à la fois, indépendamment du chantier et des doctrines de la Maison des savoirs. Les coûts sont payés au lancement ; la recherche se termine aussi hors ligne. Le bâtiment reste au niveau 1 : les trois niveaux concernent les armes, et apparaissent dans son panneau.

L’attaque, les taux de pertes, le bonus de transport et le plafond de butin sont enregistrés au départ de chaque nouveau raid. Une recherche ou un bâtiment terminé pendant son trajet profite au raid suivant. En victoire les pertes s’arrondissent vers le bas par type d’unité, en défaite vers le haut. Le Quai ne change pas la durée ni le temps de récupération des factions ; les survivants et les réserves restent les limites réelles du butin.

Les sauvegardes des versions 2 à 12 migrent vers la version 13 avec les migrations
antérieures conservées. La campagne côtière reste inactive jusqu’au choix du joueur.
Les anciennes expéditions conservent leurs règles antérieures ; les armes absentes
commencent au niveau 0. Les tests couvrent les échanges, recherches, bonus figés au
départ, reprise hors ligne, migration et sauvegarde d’un Centre complet.

### Garnison et défense du port

Le Lancier apporte 10 de défense, le Pillard 3, le Gardien 14, le Mage 4, le
Guerrier 7 et l’Archer 12, avant le bonus d’armes. La tour ajoute 20 et le peuple
des récifs 1. Les troupes en expédition et en formation sont exclues. Les pertes
utilisent les mêmes taux et arrondis que les raids, avec les mages et l’Infirmerie
présents au moment de l’assaut. À égalité, le port tient.

### Contrats maritimes du Marché

Le Comptoir des Roseaux achète 20 bois, avec 5 vivres consommés au départ.
La route des lagunes dure trois marées et paie 18 ambres sans perte d’escorte.
La passe des corsaires dure deux marées et paie 26 ambres si l’escorte atteint
24 de force ; sinon, la cargaison est perdue et les pertes de défaite s’appliquent.
Armes, mages, Infirmerie et bonus de transport sont figés au départ.

Une offre par route se renouvelle six marées après son départ. Un seul convoi
commercial voyage à la fois ; sa cargaison est payée immédiatement et ses unités
quittent la garnison. Les survivants rentrent après le combat de leur marée, même
si le paiement ne tient pas encore dans l’entrepôt. Le paiement reste au comptoir
jusqu’à récupération complète, une seule fois ; il doit être récupéré avant
d’accepter un autre contrat. Aucune progression commerciale pendant une absence.

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
