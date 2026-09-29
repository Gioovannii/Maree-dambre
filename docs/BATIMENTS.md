# Bâtiments du Centre-ville

Les bâtiments se placent uniquement sur les lots du Centre-ville, à raison d’un exemplaire par type et par village. La vue Ressources montre les forêts, cultures et veines d’ambre autour du village : on améliore ces terrains du niveau 0 au niveau 10, sans y poser de bâtiment. Un seul terrain de la ressource concernée au niveau 10 suffit à débloquer et activer son bâtiment de production. Les copies construites avant la règle d’unicité sont retirées de façon déterministe et leur coût est remboursé.

## Jouables dans le prototype

| Bâtiment | Rôle actuel | Effet |
| --- | --- | --- |
| Maison des Veilleurs | Cœur du village, présent au départ | +2 bois, +1 ambre et +2 vivres par heure |
| Scierie | Transforme le bois récolté autour du village | +8 bois par heure |
| Ferme | Soutient l’approvisionnement du village | +8 vivres par heure |
| Atelier d’ambre | Travaille le minerai des gisements | +4 ambre par heure |
| Tour de garde | Protège le village automatiquement | +2 défense |
| Entrepôt | Agrandit les réserves | +500 de capacité pour chaque ressource |
| Maison des savoirs | Recherche | Débloque les trois unités, une minute par doctrine |
| Cour des armes | Recrutement | Entraîne jusqu’à 20 unités, 30 secondes par unité ; file unique, limite de 100 |

Les champs de niveau 10 sont une condition de production et de construction : forêt pour la Scierie, culture pour la Ferme, veine d’ambre pour l’Atelier d’ambre. Les coûts de champs sont réglés pour qu’un village neuf puisse atteindre son premier seuil en quelques heures, et non en plusieurs jours.

Ces bâtiments sont au niveau 1 dans le prototype. Le marqueur numérique en verre de mer et ambre indique ce niveau ; l’amélioration des bâtiments urbains viendra avec les mécaniques correspondantes.

## Suite prévue, à construire quand leur mécanique sera jouable

| Bâtiment | Rôle envisagé |
| --- | --- |
| Caserne | Entraînement et garnison des troupes |
| Atelier d’armes | Équipement et spécialisation des unités |
| Maison des éclaireurs | Missions de reconnaissance de la carte |
| Maison des colons | Préparation de nouveaux villages |
| Quai d’expédition | Départs et retours des missions côtières |
| Marché | Échanges locaux de ressources |
| Remparts | Défense passive du Centre-ville |

Les bâtiments de production demandent un champ niveau 10 correspondant. Une production existante se met en pause sous ce seuil et reprend dès qu’un champ correspondant atteint le niveau requis.
