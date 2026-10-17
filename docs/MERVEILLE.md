# Merveille : objectif de fin de partie

## Direction retenue

La Merveille exige au moins **dix villages** et une coordination des livraisons
vers **une ville de construction**. Les ressources sont réunies dans cette ville
avant de lancer les travaux. Cette règle définit la cible de conception ; elle
n’est pas encore jouable dans le prototype, qui ne gère qu’un village local.

Le seuil de dix villages est fixé. Leur répartition entre les joueurs reste à
préciser : dix possessions d’un joueur ou dix villages participant à un projet
collectif. La proposition est de compter les villages participants à un projet
collectif, avec des contributions identifiables, pour favoriser la coopération.
Le seuil est une condition d’éligibilité ; les contributions nécessaires doivent
aussi rendre la coopération utile économiquement.

## Parcours proposé

1. Développer un premier village, puis fonder et spécialiser des colonies.
2. Choisir une ville de construction et constituer le groupe de villages
   participants. Afficher les prérequis restant à remplir.
3. Organiser les convois : origine, destination, cargaison, capacité et délai.
   Les ressources sont retirées au départ et reçues une seule fois à l’arrivée.
4. Réunir sur place les ressources exigées et vérifier les dix villages
   participants avant d’autoriser le lancement.
5. Payer les ressources et démarrer un chantier long, visible de tous les
   contributeurs. La durée, les éventuelles étapes et les conditions de victoire
   restent à équilibrer.

Chaque village conserve sa production et ses réserves propres. Le projet ne
doit pas additionner des stocks encore dispersés comme s’ils étaient déjà
disponibles dans la ville centrale. Les ressources en transit ne sont pas
comptées parmi les ressources livrées.

## Conséquences pour l’économie

La capacité des entrepôts doit croître avec les coûts et la production horaire.
L’autonomie de stockage dépend de la production locale ; le temps avant
saturation dépend aussi du stock présent et des arrivages prévus. Ces deux
indicateurs doivent guider les améliorations.

La ville de construction devra pouvoir contenir le prix nécessaire au lancement
de la Merveille. Le plafond actuel de 5 300 par ressource est celui du prototype,
pas une limite imposée à cette future économie. Avant d’introduire son coût,
prévoir soit des niveaux de stockage supplémentaires, soit un grand entrepôt,
soit une réserve de chantier dédiée. Aucun choix n’est encore implémenté.

Les coûts doivent se mesurer en **heures de production des villages développés**,
avec une estimation du temps de rassemblement et de transport. Fixer un prix
élevé sans vérifier le stockage rendrait le lancement impossible ; multiplier
uniquement les réserves pourrait au contraire supprimer tout arbitrage.

Il faut aussi décider du traitement d’un convoi arrivant devant une réserve
pleine : attente, retour ou autre règle annoncée avant l’envoi. La réception doit
rester cohérente après une déconnexion, sans duplication ni perte silencieuse.

## Ordre de développement

Le monde inclura des attaques entre joueurs. La cadence reste à définir : la
piste d’une attaque par semaine visait surtout à maîtriser les coûts serveur au
démarrage gratuit. Le quota éventuel et les conséquences sur le chantier restent à préciser ; voir
[les règles de conflit en préparation](CONFLITS.md).

Les fondations nécessaires sont, dans cet ordre : plusieurs villages persistants,
colonisation, transport entre villages, coordination et permissions du projet,
stockage adapté, puis construction de la Merveille. Une coopération entre vrais
joueurs nécessitera un état partagé faisant autorité côté serveur.

À préciser avant réalisation : qui contrôle la ville centrale, comment sont
acceptés les participants, quels droits possède chaque contributeur, ce qui
arrive si un village quitte le projet, les risques de transport et les effets
éventuels des conflits sur le chantier.
