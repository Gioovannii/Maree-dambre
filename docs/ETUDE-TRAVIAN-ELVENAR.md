# Travian ou Elvenar : quelle direction pour Les Marées d’Ambre ?

Étude du 16 octobre 2026. Périmètre confirmé : comparer les deux modèles de jeu et leurs usages, puis recommander une direction pour le projet.

## 1. Décision recommandée

**Prendre Travian comme référence principale pour le monde et l’expansion. Prendre Elvenar comme référence secondaire pour le développement agréable de la cité et la possibilité de progresser pacifiquement.**

Ton objectif est précis : commencer à un endroit du monde, découvrir des voisins, choisir où fonder de nouveaux établissements, commercer ou entrer en conflit. L’implantation géographique et les relations entre propriétaires doivent donc produire les décisions importantes. Ce besoin correspond davantage à la stratégie territoriale de Travian qu’à la progression centrée sur une cité d’Elvenar.

Je recommande une adaptation : **un archipel de stratégie territoriale asynchrone, avec un foyer protégé et des frontières disputées**. La colonisation pacifique doit être une voie complète de progression. Le conflit doit permettre de gagner des positions intéressantes avec un risque annoncé.

Cette adaptation est une proposition pour Marées d’Ambre, pas une description des règles de Travian. Elle modifie notamment l’exposition aux attaques pour tenir compte de ton souhait de pouvoir jouer tranquillement.

Le prochain prototype devrait prouver la fondation d’une deuxième colonie et le choix commerce/conflit. Ajouter douze pseudonymes ou de nouveaux décors, seul, ne prouverait pas cette boucle.

## 2. Méthode et limites des conclusions

L’étude croise les règles officielles de Travian: Legends, le wiki et l’assistance d’Elvenar, et le code du projet. Elle distingue les mécanismes documentés, les constats dans le dépôt et mes propositions de conception.

Il ne s’agit pas de résultats de parties comparatives instrumentées, d’une étude commerciale ou de données de rétention. Certaines pages du wiki Elvenar sont anciennes : elles étayent les mécanismes fondamentaux décrits ici, pas un inventaire exhaustif de tous les événements de 2026. Aucun chiffre de ventes, de rentabilité ou de temps de développement n’est supposé.

## 3. Ce que chaque modèle apporte

### Travian : développer une puissance située dans un monde partagé

Le joueur démarre avec un village. Il peut fonder de nouveaux villages sur des emplacements libres ou en conquérir. La position compte : production, distances et coordination avec une alliance donnent une valeur stratégique aux emplacements. La colonisation repose notamment sur des colons et des conditions de développement. Si deux expéditions visent la même place, la première arrivée l’obtient. [Règles officielles de colonisation](https://support.travian.com/en/articles/56-settling-villages).

L’expérience sociale est centrale : les voisins peuvent devenir partenaires ou adversaires et les alliances organisent coopération et défense. Les mondes se jouent en manches, avec une fin puis un redémarrage. [Présentation officielle](https://support.travian.com/en/articles/138-what-is-travian-legends).

**Ce que j’en retiens pour Ambre :** la carte est un espace où l’on s’installe et où l’on s’engage. Un port éloigné peut offrir un bon rendement mais compliquer les renforts. Une nouvelle colonie change l’économie et les relations locales.

### Elvenar : développer sa cité en explorant et en coopérant

Le développement étend l’espace constructible de la cité. Les agrandissements s’obtiennent notamment par la recherche et l’achèvement de provinces : ce sont des extensions urbaines, une logique différente de la fondation de villages séparés. [Agrandissements de la cité](https://en.wiki.elvenar.com/index.php?title=Expansions).

La carte sert à découvrir des provinces et des villes voisines. Les provinces proposent des rencontres ; leur résolution contribue à la progression. Les voisins sont aussi des villes à visiter et à découvrir. [Carte du monde](https://en.wiki.elvenar.com/index.php?title=World_Map).

Les combats documentés sont ceux des provinces : on peut négocier ou affronter leurs unités. Le système de bataille comprend différentes classes, des forces et faiblesses, et un placement sur un terrain. [Règles de combat](https://en.wiki.elvenar.com/index.php?title=Battle).

Les relations sociales incluent l’entraide de voisinage, les communautés et le commerce. Elvenar est donc aussi une référence de jeu social en ligne ; l’opposer à Travian comme « solo contre multijoueur » serait trompeur. [Entraide](https://support.innogames.com/kb/Elvenar/en_DK/298), [communautés](https://en.wiki.elvenar.com/index.php?title=Fellowships), [commerce](https://en.wiki.elvenar.com/index.php?title=Trader).

**Ce que j’en retiens pour Ambre :** le plaisir de voir sa ville progresser peut soutenir des sessions régulières, même pour quelqu’un qui n’aime pas attaquer ses voisins. La voie économique doit donner accès à des avancées significatives.

### Comparaison des intentions de jeu

Les appréciations ci-dessous sont mon analyse de conception à partir de ces règles.

| Besoin | Orientation Travian | Orientation Elvenar | Pertinence pour Ambre |
| --- | --- | --- | --- |
| Fonder un établissement ailleurs | Constitue un moteur de progression | Développement principalement centré sur la cité | Travian répond directement au but annoncé |
| Choisir sa place par rapport aux voisins | Géographie et rivalités structurantes | Découverte et interactions autour de la cité | Travian pour la carte stratégique |
| Progresser sans attaquer d’autres joueurs | Possible, mais suppose de gérer le risque environnant | Cohérent avec la boucle d’exploration et de développement | Elvenar inspire une voie paisible crédible |
| Affronter un voisin pour un enjeu territorial | Très pertinent | Les combats de provinces répondent à une autre intention | Travian pour le conflit entre propriétaires |
| Contempler et organiser une belle cité | Moyen au service de la puissance | Attraction centrale | Elvenar complète bien les visuels déjà réalisés |
| Créer des histoires entre joueurs | Fort potentiel de rivalités et de coopération | Fort potentiel d’entraide et de progression sociale | Choisir la nature des relations avant de construire un chat |
| Produire la progression longue | Interactions et compétition, à équilibrer | Chapitres et contenu, à produire | Aucun modèle ne donne une durée de vie gratuitement |

## 4. Étude des cas d’usage

### Cas 1 — Je veux m’installer puis découvrir les alentours

**Attente :** comprendre qui habite près de moi, repérer un lieu libre et choisir ma prochaine implantation.

Travian est la meilleure référence. Pour Ambre, l’écran initial doit montrer une région lisible avec des voisins identifiés et quelques options d’expansion. Afficher toute une grande carte peu occupée ne crée pas ce sentiment.

**Décision proposée :** présenter le nom du propriétaire, le nom du village, le peuple et la relation avec lui. Une culture peut être partagée par de nombreux propriétaires. Un joueur peut posséder plusieurs villages. Un voisin n’est pas automatiquement un ennemi.

### Cas 2 — Je veux coloniser au calme

**Attente :** investir dans mon économie et fonder une deuxième colonie sans devoir piller quelqu’un.

La colonisation de Travian répond au choix géographique ; l’orientation paisible d’Elvenar répond mieux au besoin de sérénité. Leur combinaison exige une règle explicite : dans un territoire attaquable, ne pas attaquer ne suffit pas à garantir la paix.

**Décision proposée :** un foyer protégé et des emplacements de colonisation paisibles donnant une progression économique réelle. Les meilleures récompenses militaires peuvent se trouver aux frontières, mais la recherche et la deuxième colonie ne doivent pas exiger une victoire contre un joueur.

**Test décisif :** un testeur refuse toutes les attaques et atteint malgré tout un nouvel établissement et un objectif de développement significatif.

### Cas 3 — Je veux attaquer et agrandir mon influence

**Attente :** observer une cible, préparer des effectifs, risquer des pertes et modifier la situation sur la carte.

Travian est la meilleure référence. Le raid actuel d’Ambre rapporte du butin ; il ne prend pas le contrôle d’un village. Raid et conquête doivent devenir deux actions distinctes, avec des conditions et conséquences distinctes.

**Décision proposée :** commencer par des postes frontaliers disputés. Leur occupation donne un avantage visible et exige une garnison. Réserver la conquête complète de cités à une étape ultérieure, une fois les pertes et la reconstruction éprouvées.

### Cas 4 — Je joue dix minutes et je reviens demain

**Attente :** accomplir une décision utile sans devoir surveiller constamment le téléphone.

Le risque de pression temporelle est plus élevé avec des attaques entre joueurs. Travian prévoit une protection de débutant temporaire ; celle-ci prépare l’entrée dans un environnement exposé et n’est pas une garantie permanente de tranquillité. [Protection officielle](https://support.travian.com/en/articles/12-beginner-s-protection).

**Décision proposée :** rendre les possessions exposées et les fenêtres de risque visibles avant tout engagement. Une notification informe ; elle ne doit pas être le seul moyen d’éviter une perte catastrophique. Le foyer protégé permet au joueur absent de garder un point de reprise.

### Cas 5 — Je veux commercer et être utile à mes voisins

**Attente :** apporter quelque chose aux autres sans avoir l’armée la plus forte.

Elvenar est une bonne référence pour l’entraide et les échanges ; Travian inspire la logistique entre établissements et partenaires.

**Décision proposée :** spécialiser les colonies, donner une utilité aux surplus et aux transports. Un rôle marchand doit avoir ses propres décisions : route, délai, partenaire et coût. Il faut aussi prévenir le transfert abusif de ressources entre comptes ; Travian possède lui-même des limites de partage, ce qui montre que le sujet ne se réduit pas à afficher un marché. [Limites officielles de partage](https://support.travian.com/en/articles/125-automatic-resource-sharing-limits).

### Cas 6 — Je viens pour une ville superbe

**Attente :** voir mes investissements transformer le lieu et conserver une relation affective avec lui.

Elvenar est la référence la plus pertinente. Ambre a déjà investi dans les domaines illustrés, les vagues et les habitants. Ces éléments deviennent plus précieux si le joueur retrouve un foyer identifiable.

**Décision proposée :** garder le port principal comme lieu visuel fort. Une colonie doit toutefois être un vrai établissement : production, stocks, investissements et rôle logistique. Une fiche de site produisant un bonus peut être un avant-poste ; elle ne remplace pas à elle seule la promesse de fonder un second village.

### Cas 7 — J’arrive après les autres

**Attente :** disposer encore d’une place et de choix utiles.

Dans un monde territorial, des joueurs installés peuvent accaparer les positions et les ressources. Le guide Travian recommande d’ailleurs un monde récent pour commencer sur une base plus comparable. [Premiers pas officiels](https://support.travian.com/en/articles/142-first-steps-in-the-game).

**Décision proposée :** prévoir le placement des nouveaux arrivants et la disponibilité d’emplacements neutres. Une région d’accueil ou des cohortes de démarrage valent mieux qu’un nouveau village posé au milieu d’empires déjà dominants. Un simple bonus de production ne corrige pas une carte verrouillée.

### Cas 8 — Nous sommes seulement quelques testeurs

**Attente :** rencontrer assez de situations intéressantes pour évaluer le jeu.

Un modèle territorial dépend de la densité locale d’activité. Un modèle plus proche d’Elvenar peut proposer des objectifs PvE même quand les interactions entre voisins sont rares.

**Décision proposée :** une petite région de test et des ports IA identifiés comme tels. Ils soutiennent l’économie et les situations de test, mais ne doivent pas être présentés comme des humains connectés. Mesurer les voisins réellement actifs et les interactions, pas seulement le nombre d’inscriptions.

### Cas 9 — Je perds une bataille

**Attente :** comprendre ma défaite et avoir un plan de reprise.

La stratégie territoriale produit des enjeux forts, mais peut aussi créer un effet boule de neige : davantage de colonies donnent davantage de ressources, puis davantage de moyens de conquérir.

**Décision proposée :** limiter d’abord les postes contestables, afficher les pertes, permettre le retrait et maintenir une économie de reconstruction. Tester un perdant aussi sérieusement que le gagnant. Protéger un foyer ne suffit pas si un adversaire peut bloquer toutes ses routes utiles.

### Cas 10 — Nous visons le même emplacement

**Attente :** obtenir une résolution cohérente et un retour clair si la place est prise.

C’est un vrai enjeu du modèle Travian. Il faut décider si un emplacement est réservé au départ ou attribué à l’arrivée. Pour Ambre, je propose une attribution à l’arrivée, avec un coût de voyage annoncé et une règle explicite de retour/remboursement en cas d’échec.

Dans un monde partagé, le serveur doit départager les actions et éviter la double attribution. Le calcul local d’un téléphone ne peut pas arbitrer les deux propriétaires.

### Cas 11 — Je joue plusieurs semaines

**Attente :** voir apparaître de nouvelles décisions, pas seulement des coûts plus élevés.

Travian peut renouveler les situations par les relations et les enjeux collectifs. Elvenar structure aussi sa progression en chapitres. [Chapitres d’Elvenar](https://en.wiki.elvenar.com/index.php?title=Chapters).

**Décision proposée :** trois paliers : établir sa première colonie ; spécialiser et relier plusieurs établissements ; choisir une ambition régionale économique ou militaire. Le Grand Phare peut devenir un objectif coopératif régional ou un objectif PvE, plutôt qu’une fin obligatoire identique pour tous. C’est à prototyper : de nouveaux noms de voisins ne créent pas ces paliers.

### Cas 12 — Je paie pour ce jeu

**Attente :** une expérience qui tient sa promesse et reste équitable.

La beauté actuelle peut attirer et donner une identité, mais ne démontre pas la volonté de payer ni la profondeur. Une formule premium solo peut financer une campagne définie ; un monde en ligne implique aussi une exploitation durable. Aucun des deux ne détermine automatiquement le bon prix.

**Décision proposée :** évaluer le paiement après un test de la boucle territoriale. Pour le modèle recommandé, éviter de vendre une supériorité militaire : cela contredirait la confiance nécessaire aux conflits. Tester une proposition commerciale précise avec des joueurs avant de choisir achat initial, contenus ou cosmétiques.

## 5. Compatibilité avec le projet actuel

Constats issus du dépôt au moment de l’étude :

| Élément | État observé | Conséquence |
| --- | --- | --- |
| Village | Un seul `VillageState` porte les stocks, bâtiments, recherches et troupes | Plusieurs colonies demandent un modèle de propriétaire et une collection d’établissements |
| Monde | Carte de 200 × 200, foyer fixe en 100,100 | La taille graphique ne constitue pas une simulation territoriale |
| Voisins | Trois profils fixes dans `BotFaction` | Peuple, propriétaire et village doivent devenir des notions distinctes |
| Sauvegarde | `VillageStorage` exige les identifiants `[0, 1, 2]` | Ajouter des voisins demande validation et migration compatibles |
| Expansion | Les bots gagnent niveau et territoire toutes les six heures | Le joueur ne dispose pas de la colonisation correspondante |
| Raids | Résolution locale, butin calculé sans débit d’un stock adverse | Le combat ne représente pas encore un échange entre deux économies |
| Horloges | Production et raids en temps réel ; campagne côtière et contrats en marées décidées par le joueur | Une horloge partagée doit être définie avant le multijoueur |
| Persistance | Sauvegardes locales `UserDefaults` | Aucun arbitrage commun des possessions et combats |

Sources locales : [état du village](/Users/giovannigaffe/Documents/Maree-dambre/MareesAmbre/Domain/VillageState.swift), [sauvegarde](/Users/giovannigaffe/Documents/Maree-dambre/MareesAmbre/Persistence/VillageStorage.swift), [raids](/Users/giovannigaffe/Documents/Maree-dambre/MareesAmbre/Domain/ArmyState.swift), [contrats](/Users/giovannigaffe/Documents/Maree-dambre/MareesAmbre/Domain/CommerceState.swift).

Les visuels et une partie des règles économiques sont réutilisables. La colonisation, la gestion de plusieurs établissements et les relations doivent être construites dans les deux cas si l’on conserve ton objectif. Une orientation Elvenar réduirait le besoin de confrontation territoriale, mais demanderait davantage de progression de cité et de contenu PvE pour porter sa propre promesse.

Le document [VISION-SOLO.md](/Users/giovannigaffe/Documents/Maree-dambre/docs/VISION-SOLO.md) proposait une campagne finie avec quelques avant-postes. Cette étude constate une évolution de ton intention vers un monde d’implantation libre ; elle ne transforme pas automatiquement cette ancienne proposition en fonctionnalités réalisées.

## 6. Le vrai compromis : liberté, tranquillité et conflit

Une frontière attaquable crée une opportunité pour un joueur et une menace pour un autre. On ne peut donc pas promettre simultanément une conquête libre de toutes les cités et une tranquillité garantie partout.

Je propose une règle géographique simple :

| Espace | Usage principal | Risque proposé |
| --- | --- | --- |
| Foyer et possessions paisibles | Construction, colonisation, économie, échanges | Progression conservée ; pas de conquête PvP |
| Frontière contestée | Postes à valeur stratégique, garnisons, rivalités | Occupation et pertes possibles, affichées avant engagement |
| Sites PvE | Exploration, ruines, corsaires | Défis annoncés sans victime humaine |

Le choix d’un poste exposé engage le joueur dans le conflit selon des règles visibles. Il ne faut pas pouvoir attaquer puis mettre instantanément son armée ou son butin à l’abri : retrait différé, engagements en cours et transport devront être définis.

Les avantages paisibles doivent rester utiles ; sinon le jeu impose de fait la voie militaire. Les avantages frontaliers doivent rester désirables ; sinon le conflit devient décoratif. L’équilibre relève des tests, pas d’une formule choisie dans cette étude.

## 7. Développement et exploitation : ce que le choix implique

**Les deux références sont des jeux exploités dans la durée.** Un modèle territorial humain ajoute toutefois des problèmes spécifiques : conflits de propriété, pertes subies, voisins inactifs, multi-comptes, transferts abusifs et disponibilité du monde.

Pour un monde partagé, les ordres doivent être validés côté serveur : propriétaire autorisé, ressources disponibles, trajet, arrivée et résultat. Un serveur faisant autorité est adapté aux états communs et à la réduction de la confiance accordée au client. [Documentation technique de référence](https://heroiclabs.com/docs/nakama/concepts/multiplayer/authoritative/).

Cela n’exige pas une simulation de bataille à haute fréquence. Pour Ambre, des commandes et événements datés peuvent suffire : départ, arrivée, combat, retour. C’est une proposition d’architecture, pas un choix de fournisseur. Les actions concurrentes doivent rester cohérentes ; une écriture conditionnelle est un mécanisme possible, mais ne remplace pas à elle seule une transaction portant sur deux économies. [Exemple de gestion des versions](https://heroiclabs.com/docs/nakama/concepts/storage/collections/).

Les marées avancées manuellement par un joueur ne peuvent pas faire progresser le monde de tous les autres. Il faut soit les garder dans des défis individuels, soit définir une phase globale prévisible avec des fenêtres suffisamment larges. Ce choix doit précéder l’équilibrage des trajets.

Le budget dépendra du trafic réel, du nombre d’ordres, des données conservées, de la région d’hébergement, de la surveillance et du support. Le coût humain d’exploitation doit être estimé avec l’hébergement. Sans ces mesures, annoncer un montant mensuel ou une date de livraison serait artificiel.

## 8. Matrice de décision

Ces appréciations sont des jugements de conception, pas des scores de marché.

| Critère pour ton projet | Travian comme socle | Elvenar comme socle |
| --- | --- | --- |
| Fidélité à « spawn, voisins, colonisation, conflit » | Très forte | Partielle ; change la nature de l’expansion |
| Monde dont la géographie devient importante | Très forte | Forte pour l’exploration, différente pour les possessions |
| Jeu paisible sans surveillance militaire | À concevoir explicitement | Plus naturellement compatible |
| Valorisation du domaine vivant déjà produit | Bonne | Très bonne |
| Rivalité et diplomatie entre propriétaires | Très forte | Dimension sociale plutôt tournée vers la coopération documentée |
| Progression avec peu de voisins actifs | Fragile sans contenu de secours | Plus compatible avec une progression PvE |
| Besoin de nouveaux contenus à long terme | Systèmes et interactions à soutenir | Chapitres et contenu à renouveler |
| Facilité depuis le code actuel | Chantier important | Chantier important si l’on veut une vraie profondeur |

**Verdict : Travian est le choix le plus pertinent pour ton intention déclarée.** Elvenar deviendrait le premier choix si la priorité passait à embellir et agrandir une seule cité, explorer et coopérer sans chercher à posséder des villages sur une carte commune.

## 9. Plan recommandé et critères de passage

### Étape A — Prouver la colonisation

Créer un propriétaire, un peuple et plusieurs établissements distincts. Générer des voisins nommés et des sites libres. Réaliser reconnaissance, choix d’un site, préparation, trajet, fondation et sélection de la nouvelle colonie. Commencer avec deux établissements administrables suffit pour tester le principe.

La distance doit compter dans la logistique ; les stocks ne doivent pas devenir automatiquement un portefeuille mondial sans transport. Préserver les anciennes sauvegardes avec une migration testée. Les profils IA sont clairement identifiés et possèdent de vraies ressources et décisions, même simples.

**Passage :** une nouvelle partie permet de fonder une seconde colonie sans raid, de comprendre son intérêt et de retrouver les deux établissements après relance.

### Étape B — Prouver les deux styles

Tester un parcours économique et un parcours militaire sur une même région. Donner aux colonies des spécialisations et proposer un premier poste disputé, avec pertes, retraite et reprise. Garder les peuples comme trois identités réutilisables parmi de nombreux voisins.

**Passage :** les deux parcours produisent des décisions et des ambitions distinctes ; le perdant peut reprendre ; le joueur paisible ne se trouve pas bloqué par une obligation militaire.

### Étape C — Prouver le monde partagé

Introduire comptes, état commun faisant autorité et commandes persistées. Tester en priorité deux colonisations concurrentes, une commande répétée après coupure réseau, un raid sur une garnison déjà engagée, la résolution pendant l’absence et la reprise après arrêt du service. Les parties locales restent séparées des possessions compétitives ; importer librement leurs ressources compromettrait l’équité.

Un petit prototype IA permet de tester les décisions. Il ne faut cependant pas terminer une grande campagne solo avant de valider ces fondations communes : l’IA et les humains doivent agir sur les mêmes règles de propriété.

**Passage :** une place a un seul propriétaire ; aucune ressource ni récompense n’est dupliquée ; les joueurs retrouvent des rapports cohérents après reconnexion.

### Étape D — Prouver l’intérêt avec des joueurs

Première cohorte proposée : 6 à 8 personnes, mêlant amateurs de stratégie territoriale, bâtisseurs paisibles et nouveaux joueurs. Observer leurs premières sessions sans leur expliquer chaque action. Puis organiser un essai sur une semaine pour voir si les projets de colonisation donnent réellement envie de revenir.

Mesurer : compréhension du voisinage ; découverte de la prochaine action ; temps et obstacles jusqu’à la deuxième colonie ; raison du choix de site ; usage du commerce ; conséquences d’une défaite ; envie de revenir et retour effectif ; disponibilité de voisins actifs. Une petite cohorte aide au diagnostic et ne prédit pas la rétention commerciale.

Recruter ensuite une cohorte plus large et coordonnée pour éprouver les interactions humaines. Le nombre nécessaire dépend de la densité de la région et de la fréquence des échanges ; ce document ne fixe pas un seuil universel de population.

## 10. Ce que je ferais ensuite

Je fixerais la promesse suivante : **« Fonde ton port dans un archipel vivant, relie tes colonies et choisis entre prospérité commerciale et conquête des frontières. »**

Je construirais ensuite une première colonisation jouable et son modèle de propriété. Les beaux domaines actuels deviennent les foyers auxquels on tient. La carte gagne sa fonction de décision. Les Missions montrent départs, arrivées, échanges et conflits. Le Grand Phare peut servir d’ambition régionale plus tard, une fois cette base validée.

La recommandation finale est donc une stratégie territoriale inspirée de Travian, avec une voie paisible réellement soutenue et un foyer visuellement valorisé. La décision à tester maintenant est l’intérêt de créer et relier un deuxième établissement. C’est elle qui dira si nous avons le début du jeu que tu imagines.
