# Direction recommandée — Le Grand Phare

État au 27 octobre 2026 : une première reconstruction du Grand Phare en cinq
étapes, financée par un domaine de trois villages, est jouable. Voir
[MERVEILLE.md](MERVEILLE.md) pour les règles réalisées. Le siège final, les pièces
uniques et les classements ci-dessous restent des propositions historiques.

Proposition de conception du 14 octobre 2026 pour Les Marées d’Ambre.
Le choix des troupes, un premier cycle de défense du port et deux contrats
maritimes avec escortes sont implémentés. La campagne complète, les effets de
marée sur les routes, les alliances, les avant-postes, le phare et les classements restent à construire ; voir
`V1-JOUABLE.md` pour l’état réalisé.
Les nombres de sites, de missions et les durées sont des hypothèses de prototype,
pas des résultats de tests.
Précisions intégrées après la référence vidéo et la demande de classements :
conserver le développement des champs, le recrutement et une comparaison entre joueurs.

## Décision

Créer un jeu de stratégie solo dans un archipel de fantasy maritime, inspiré
des ports et forteresses du Moyen Âge tardif. Le joueur transforme un refuge en
puissance commerciale, contrôle quelques positions, compose ses expéditions et
reconstruit un grand phare qui rouvre les routes de l’archipel.

Promesse : **« Bâtis ton port, maîtrise les marées et rallume le Grand Phare,
avant de défendre ce que tu as réuni. »**

La campagne a une vraie fin et se rejoue avec une autre géographie et d’autres
choix. Sa simulation et sa victoire fonctionnent localement. Le produit comprend
aussi des classements partagés : leurs scores sont envoyés ponctuellement à un
service en ligne, avec Game Center comme premier choix. Cela ne transforme pas
les campagnes individuelles en un monde multijoueur hébergé.

Cette recommandation cherche le meilleur compromis entre identité, décisions
intéressantes et moyens de développement limités. Elle ne garantit ni succès
commercial, ni mise en avant par Apple, ni fidélité des joueurs : ces hypothèses
doivent être confrontées à un prototype et à des personnes extérieures.

## Socle à conserver : champs et recrutement

Le développement des champs et la construction d’unités restent au cœur de la
progression. Ils ne sont pas remplacés par les contrats ou les étapes du phare.

- Améliorer individuellement les parcelles de vivres, les exploitations de bois
  et les gisements d’ambre. Leur niveau augmente durablement la production.
- Investir les ressources dans les bâtiments, les recherches, la capacité de
  stockage, les fortifications et le recrutement.
- Débloquer des unités, entraîner des effectifs, conserver une garnison et
  préparer ses expéditions. Les pertes militaires rendent la production utile
  pour reconstruire les forces.
- Faire des nouveaux accès et des époques une extension de cette économie,
  sans supprimer les améliorations obtenues sur les champs existants.

Boucle économique : **champs → ressources → bâtiments et recherches → unités →
expansion, commerce et défense → nouveaux investissements et merveille.**

Les marées ajoutent des choix à cette boucle. Le rythme des constructions et des
recrutements reste à éprouver ; conserver les champs et les unités ne décide pas
à lui seul si tous les délais doivent être réels ou exprimés en tours de campagne.

## Direction visuelle issue de la vidéo

Référence fournie : ScreenRecording_10-13-2026 20-49-42_1.MP4, durée 33,44 secondes.
L’examen de neuf images réparties sur la séquence montre une publicité présentant
une ville en vue isométrique, des champs autour du centre, des remparts, des
habitants, des charrettes, des ateliers et un bateau. Elle ne montre pas une
séquence vérifiable de construction, de recrutement ou de combat ; en tirer une
référence de présentation plutôt qu’une preuve de gameplay.

Direction retenue : une cité maritime que l’on voit grandir, avec champs en
périphérie, centre construit, défenses puis activité du port. Déplacement et zoom
permettent d’observer les détails ; toucher un champ ou un bâtiment conserve
une action de jeu simple et lisible.

Pour le premier essai : terrain et bâtiments en 2D isométrique, quelques habitants
sur des trajets, un convoi visible et un bateau. Les sprites d’ambiance représentent
l’activité sans simuler chaque habitant ni afficher chaque soldat de l’armée.
Vérifier la lisibilité des parcelles et les performances avant d’augmenter la densité.

La sensation de ville vivante est réalisable par étapes. Reproduire toute la
densité et la finesse de cette référence demande un travail artistique important ;
ce rendu ne découle pas automatiquement des images présentes dans le projet.

## Pourquoi cette direction

| Direction envisagée | Ce qui attire | Limite pour ce projet |
| --- | --- | --- |
| Traverser l’histoire, de la préhistoire au futur | Transformations spectaculaires, nombreuses découvertes | Multiplie les bâtiments, unités, recherches et règles à produire et équilibrer |
| Survie contre un déluge, construction d’une arche | Urgence et objectif faciles à comprendre | Le départ final valorise moins la ville construite ; une échéance réelle risque de punir les absences |
| Archipel, routes et Grand Phare | Un même objectif donne un sens à l’économie, aux alliances, aux conquêtes et aux sièges | Il faut rendre les routes et les marées utiles dès les premières minutes |

Le troisième choix est recommandé. La portée historique plus large et l’arche
ne sont pas de mauvaises idées ; elles demandent une autre production et une
autre expérience que celle que l’on peut valider rapidement ici.

Travian fournit une inspiration pour l’expansion, l’engagement des troupes et
l’objectif de merveille. Mais sa merveille mobilise plusieurs joueurs et termine
un monde partagé. Notre interprétation pour le solo : remplacer cette coordination
humaine par l’organisation de plusieurs positions et les relations avec des ports
simulés. Copier seulement les coûts et les délais laisserait de côté cette tension.

Les époques de Forge of Empires et les chapitres d’Elvenar montrent l’intérêt
d’une progression qui ouvre de nouvelles possibilités. Pour nous, trois étapes
qui changent les décisions valent mieux qu’une longue liste de niveaux similaires.
Thronefall est une référence pour la clarté du rythme construire/préparer/défendre ;
son combat d’action n’entre pas dans notre périmètre.

## Scénario et époque

Après la rupture du Grand Phare, les bancs de sable et les courants ont isolé
les ports. Les cartes anciennes sont incomplètes. Une ligue de corsaires contrôle
les passages connus et prélève des tributs sur les convois.

Le joueur accueille quelques habitants dans un refuge côtier. Un premier convoi
secouru révèle qu’une partie des plans du phare a survécu. Restaurer l’ouvrage
permettrait aux ports de commercer librement : les uns soutiennent le chantier,
d’autres exigent des contreparties, les corsaires tentent de l’arrêter.

L’ambre nourrit une petite part de merveilleux : il sert au cœur lumineux du
phare. L’univers reste lisible — bois, vivres, navires, tours, ruines — sans
nécessiter une encyclopédie ou une nouvelle technologie à chaque chapitre.
Les images existantes doivent faire l’objet d’une vérification de cohérence
visuelle ; leur présence ne garantit pas une direction artistique unifiée.

Trois rôles de factions suffisent à la première campagne :

- **Les Sauniers** : surplus de vivres, contrats commerciaux et aide logistique.
- **Les Gardiens de Nacre** : savoir ancien, pièce du phare et soutien défensif
  si le joueur protège un site auquel ils tiennent.
- **La Ligue des Écueils** : adversaire principal, embuscades, blocus et sièges.
  Ses postes expliquent les attaques ; le joueur peut les affaiblir.

Ces noms et rôles sont proposés. Le prototype actuel possède des factions,
mais leurs comportements et relations ne réalisent pas ce scénario.

## Trois époques, trois manières de jouer

| Époque | Transformation visible visée | Décisions nouvelles | Passage à l’étape suivante |
| --- | --- | --- | --- |
| **Les Refuges** | Palissades, ateliers et débarcadère | Produire, choisir un premier site, partager les soldats entre sortie et défense | Sécuriser le port, rencontrer un voisin et retrouver les plans |
| **Les Comptoirs** | Quais, entrepôts et pavillons des partenaires | Installer des avant-postes, organiser les convois, négocier ou conquérir un accès | Obtenir les connaissances et les accès nécessaires au chantier |
| **Le Grand Phare** | Citadelle, chantier puis lumière visible depuis l’archipel | Tenir plusieurs positions, recevoir les soutiens acquis, engager la merveille | Résister à l’offensive finale et allumer le phare |

Le passage d’époque résulte d’objectifs accomplis. Il n’a pas lieu après un nombre
de jours d’installation et ne remet pas les bâtiments à zéro. Une amélioration
rend un nouveau choix possible : transporter davantage, tenir un passage, voir
une attaque plus tôt. Son intérêt ne se limite pas à un pourcentage de production.

Le prototype peut employer les images existantes et des éléments simples. La
version publique devra montrer réellement la transformation du port et du phare :
des titres et des badges seuls ne suffiront pas.

## Boucle de jeu et signature des marées

**Observer → investir → répartir ses forces → choisir un contrat ou une
expédition → engager la marée suivante → lire les conséquences → ouvrir un
nouvel accès ou avancer le phare.**

Une marée est un tour stratégique de campagne, alternant basse et haute. Elle
avance sur confirmation du joueur après ses préparatifs. Elle ne dépend pas de
l’heure réelle ou des horaires des marées naturelles.

- **Marée basse** : certaines chaussées, ressources et ruines deviennent accessibles.
  Un passage peut aussi ouvrir une voie d’assaut ennemie.
- **Marée haute** : des voies de navigation s’ouvrent et les chaussées se ferment.
  Les convois circulent, mais certains passages sont exposés aux corsaires.
- La carte montre la phase actuelle, la suivante et les accès qui vont changer.
  Le premier prototype n’a qu’une chaussée et une route concernées par ce système.

Les préparatifs restent simples : un chantier actif, une répartition de garnison,
puis un nombre limité de missions. Une mission peut immobiliser des forces
jusqu’à une marée ultérieure ; elle affiche son retour avant confirmation.
Les résultats apparaissent dans un rapport court avec une conséquence visible
sur la carte. Pas de combat d’action ou de bataille 3D à produire.

Les productions contrôlées rapportent leurs ressources à chaque marée. Construire,
entraîner et voyager demandent des ressources et un nombre annoncé de marées.
Ainsi, continuer à jouer fait avancer l’économie sans attendre l’horloge réelle.
Passer une marée pour accumuler des stocks fait aussi avancer les mobilisations
ennemies déjà annoncées ; préparer a donc un coût stratégique.

Ce changement est volontaire par rapport au prototype : les minuteurs ne sont
plus le moteur principal du plaisir. La simulation stratégique progresse avec les
décisions. Les durées de construction et de trajet sont exprimées en marées et
restent à tester ; ne pas ajouter des heures d’attente à chaque tour.

## Expansion : contrôler des accès plutôt que remplir une carte

La première campagne vise environ douze sites significatifs et au maximum trois
avant-postes simultanés, autour d’un port principal. La carte actuelle peut servir
de support, mais chaque site jouable doit avoir une raison d’exister. Les distances
doivent être lisibles sans parcourir des écrans vides.

- Une forêt produit du bois, mais se défend mal à marée basse.
- Un détroit donne une route commerciale plus courte, au prix d’une garnison.
- Une ruine apporte un savoir du phare, mais provoque la ligue qui la contrôlait.
- Un refuge allié peut fournir une escorte sans devenir une ville à administrer.

Le joueur sécurise un accès par occupation ou par accord, selon le site. Un accord
ne crée pas les mêmes revenus ni obligations qu’une conquête. Pas de duplication
complète du village : une fiche, un avantage, une garnison et un état suffisent.

Le plafond de positions et l’immobilisation des forces empêchent une expansion
automatiquement avantageuse. Tout contrôler n’est pas une condition de victoire.
Une position perdue peut être reprise ou contournée par une autre route.

## Commerce : des partenaires et des engagements

Conserver trois ressources : bois pour les ouvrages, vivres pour les missions,
ambre pour les recherches, achats et éléments du phare. Les pièces uniques du
chantier sont des objectifs identifiés, pas une quatrième économie répétitive.

Le marché propose un échange immédiat qui conserve la moitié de la valeur,
ainsi que deux premiers contrats vers le Comptoir des Roseaux. Le dépannage
immédiat reste disponible ; le voyage en marées mobilise une escorte réelle.
La suite étendra les contrats à des partenaires et avantages identifiables.

Un contrat annonce : partenaire, cargaison, récompense, route, durée en marées,
besoin de transport et danger. Deux offres contrastées suffisent à commencer :
bonne marge sur un passage dangereux, ou marge moindre sur une route sûre.
L’escorte utilise une partie des mêmes forces que la défense.

Des livraisons ou une mission de secours peuvent transformer un partenaire neutre
en allié. L’alliance apporte une aide précise : pièce du phare, convoi de chantier
ou renfort pour le dernier siège. Pas de simulation mondiale des prix, de
conversation libre ou de négociation complexe.

Les offres sont limitées et évoluent avec les marées et les étapes de campagne.
Les quantités, provisions consommées et capacités de transport empêchent une
boucle d’achat/revente sans coût. Un contrat engagé réserve la marchandise promise ;
il ne devient pas impossible parce que le joueur a fermé l’app. Une expiration
éventuelle est exprimée en marées et annoncée avant acceptation.

Les relations n’exigent pas de vendre à perte systématiquement. Une voie commerciale
obtient certains accès sans conquête et réduit les pertes par l’aide des alliés.
Elle conserve un besoin de défense contre la ligue ennemie.

## Attaques et défenses : engager une armée est un choix

Le système actuel permet de choisir les troupes envoyées et de conserver une
garnison. Le deuxième lot rend cette garnison utile contre des assauts corsaires
annoncés, résolus au passage d’une marée décidé par le joueur. Les escortes,
avant-postes et effets de terrain restent à intégrer.

Commencer avec deux rôles jouables : une unité qui tient les positions et une
unité adaptée aux expéditions. Les six unités et les trois peuples existants
pourront devenir des variations de style ; tout équilibrer dès le premier essai
détournerait du test de la boucle principale.

La force, le rôle des unités, la fortification et l’accès lié à la marée expliquent
le résultat. Garder une tour sur un passage étroit peut économiser des soldats ;
détruire un poste de corsaires peut rendre une escorte moins nécessaire.

Trois formes de menace suffisent :

- **Pillage** : des assaillants rapides visent les stocks d’un avant-poste.
- **Blocus** : une route cesse de fournir son avantage tant que le passage ennemi
  n’est pas neutralisé ou contourné.
- **Siège** : une offensive lourde menace un site stratégique ou le phare.

Une attaque affiche cible, marée d’arrivée, types de forces repérés et cause de
l’offensive. Une reconnaissance réduit l’incertitude si nécessaire. Les événements
sauvegardés ne changent pas simplement parce que l’app est relancée. Le rapport
explique les pertes, l’effet des fortifications et ce qu’il faut réparer.

La ligue progresse par paliers liés aux accès ouverts, à ses postes contestés et
aux étapes du phare. À l’intérieur d’un palier, ses mobilisations avancent avec les
marées jouées, dans des limites annoncées. Sa puissance ne s’ajuste pas
automatiquement à chaque amélioration de l’armée du joueur : un bon investissement
donne un avantage réel. Détruire un poste ennemi réduit un danger identifiable.

Les attaques peuvent être violentes : pertes importantes, cargaison perdue,
avant-poste occupé, ravitaillement interrompu ou chantier endommagé. Les
connaissances et les étapes acquises sont conservées. Le port principal laisse
un socle de production et une voie de reconstruction. Le premier essai doit
prouver une reprise avec les moyens restants, sans attendre plusieurs jours ni payer.

## Exemple de décision centrale

Une livraison donne accès à la lentille du phare. La route courte mobilise une
escorte pendant deux marées. Un siège annoncé arrive à la prochaine marée basse
sur l’avant-poste qui fournit le bois du chantier.

Trois réponses possibles, à rendre viables par l’équilibrage :

1. Renforcer la garnison et reporter la livraison : protéger le chantier au prix
   d’une progression commerciale plus lente.
2. Prendre une route plus sûre avec moins d’escorte : dépenser plus de vivres et
   immobiliser le transport plus longtemps pour conserver ses défenseurs.
3. Engager la livraison, abandonner provisoirement l’avant-poste et acheter le bois
   à un allié : avancer le phare en acceptant une perte territoriale et économique.

La réponse dépend des relations, du terrain, des réserves et de la préparation.
C’est le test du concept : si une option est toujours supérieure ou si attendre
suffit à effacer le dilemme, il faut revoir les coûts et les contraintes.

## La merveille en cinq moments

Les plans sont découverts au début. Le joueur voit rapidement ce qu’il construit.
Le Grand Phare est présent sur la carte dès la première session, à l’état de ruine.

| Étape | Ce qu’il faut accomplir | Bénéfice ou conséquence |
| --- | --- | --- |
| 1. Restaurer les jetées | Assurer une livraison et le site du chantier | Un nouvel accès de navigation |
| 2. Relever la tour | Réunir les matériaux et défendre la position | Repérage plus précoce des mouvements ennemis |
| 3. Réparer le cœur d’ambre | Obtenir un savoir et acheminer l’ambre | Un passage devient plus sûr pour les convois |
| 4. Poser la lentille | Obtenir la pièce par accord ou expédition ; choisir ses soutiens | La ligue annonce sa dernière offensive et ses cibles |
| 5. Allumer le Grand Phare | Préparer puis gagner le siège final | Routes rouvertes, bilan et fin de campagne |

Chaque chantier commence volontairement, avec conditions et danger annoncés.
Les travaux demandent économie, accès et connaissances ; verser une énorme
quantité de ressources ne remplace pas ces objectifs.

Certaines livraisons doivent rejoindre le chantier pendant ses travaux. Constituer
une réserve avant de commencer ne remplace donc pas entièrement la protection
des routes au moment du siège. La capacité militaire couvre l’ensemble des
troupes, y compris les renforts achetés ; acheter des mercenaires ne permet pas
de contourner indéfiniment le choix entre escorte et garnison.

Le siège final vérifie les décisions antérieures : protections, forces préservées,
approvisionnement et aides des partenaires. La première version complète vise
un événement final court, avec deux fronts au maximum.

Après une défaite, réparer et retenter reste possible. Après la victoire, les
attaques cessent et le monde reste consultable. Lumière, routes rouvertes et
réactions des ports montrent le résultat. L’archive mentionne partenaires aidés,
territoires conservés et pertes, sans classer uniquement selon la vitesse.

## Pourquoi revenir, et pourquoi ne pas punir l’absence

Motifs recherchés : revoir un port qui se transforme, exploiter une route découverte,
voir la conséquence d’un accord, résoudre un dilemme militaire et approcher
l’étape suivante du phare. Chaque session laisse un objectif que le joueur peut nommer.

La cible initiale est une session de cinq à dix minutes et une campagne de quelques
heures actives, réparties librement. Ces durées servent à tester le rythme ; elles
n’imposent pas un calendrier et ne garantissent pas une longévité commerciale.
Les décisions arrivent immédiatement, sans plusieurs heures d’améliorations
obligatoires avant le premier enjeu.

Des réserves de préparation peuvent se remplir hors ligne jusqu’à un plafond.
Une absence ne fait avancer ni la marée stratégique ni une série de sièges.
Une résolution engagée est sauvegardée exactement une fois ; aucune nouvelle
offensive ne s’engage sans une nouvelle décision du joueur.

Attendre ne donne pas les pièces uniques, les accords ou une armée illimitée.
Plafonds par époque, places de garnison, accès et engagement des forces portent
les contraintes stratégiques. Si le stock hors ligne supprime les choix, réduire
cet avantage ou l’enlever plutôt que faire croître les ennemis pendant les absences.

Cette règle remplace la proposition précédente fondée surtout sur l’âge réel du
monde et une attaque maximale entre visites. L’horloge convient à la production
passive ; elle est un mauvais moteur par défaut pour notre difficulté solo.

Pas de série de connexions nécessaire à la progression. Les notifications, si elles
sont ajoutées plus tard, restent facultatives. Finir une campagne est un succès,
pas un problème à masquer avec cent niveaux supplémentaires.

## Rejouabilité et mises à jour

Rejouer change la disposition des sites, une pénurie de départ, un passage exposé
et le comportement prioritaire de l’adversaire. Le joueur tente une autre combinaison
d’alliances et de conquêtes. Valider d’abord une carte écrite à la main ; la
génération de variantes vient après une première campagne plaisante.

Les peuples présents peuvent ensuite apporter des styles distincts. Les récompenses
durables sont des variantes, des éléments visuels et des découvertes de récit ;
éviter une puissance cumulative qui rend la prochaine campagne triviale.

Une mise à jour peut apporter un scénario différent, mais la première campagne
se rejoue sans l’attendre. Écrire et équilibrer des chapitres coûte du travail
même sans hébergement.

Conserver un identifiant et une version de campagne. Les mises à jour préservent
parties en cours et archives ; les nouveaux paramètres s’appliquent aux nouveaux
mondes. Une ancienne version hors ligne applique ses propres règles. La victoire
et la clôture de campagne ne dépendent pas de l’envoi du score ; les statistiques
publiables alimentent ensuite les classements lors d’une connexion.

## Classements partagés et récompenses

La demande de comparaison entre joueurs fait partie du produit. La partie reste
solo ; seuls les résultats nécessaires au classement sont échangés. Les campagnes
et les archives restent utilisables sans connexion. La publication requiert un
accès réseau et l’authentification Game Center du joueur.

### Quatre tableaux de référence

| Classement | Mesure proposée | Période |
| --- | --- | --- |
| Général | Prestige : objectifs accomplis, découvertes et étapes du phare, sans compter deux fois le même objectif | Durable, publication par instantané hebdomadaire |
| Offensif / meilleur attaquant | Valeur militaire des forces ennemies détruites en attaque | Hebdomadaire |
| Défensif | Valeur militaire des forces ennemies détruites en défense et objectifs protégés | Hebdomadaire |
| Meilleur pilleur | Butin réellement rapporté, converti selon une valeur commune des trois ressources | Hebdomadaire |

« Offensif » et « meilleur attaquant » désignent ici la même catégorie. Les séparer
avec deux noms pour le même score ajouterait un doublon. Si une cinquième catégorie
est ajoutée, préférer un « conquérant » mesurant des positions distinctes prises,
avec une règle qui empêche de gagner des points en perdant puis reprenant le même site.

Les formules et pondérations restent à tester. Aucun point pour les troupes
amies perdues, les échanges commerciaux ou un butin affiché mais non récupéré.
Limiter les points des rencontres répétées pour éviter que le meilleur score
provienne uniquement du pillage du même adversaire faible.

### Service recommandé : Game Center

Game Center fournit l’identité, les classements et leurs interfaces. Apple permet
des classements récurrents ; une durée et un intervalle de sept jours correspondent
à une compétition hebdomadaire. Cette recommandation évite un service personnel
d’hébergement des tableaux pour la première version. Elle ne constitue pas une
estimation du coût complet de développement ou de publication.

Game Center héberge les scores ; il ne simule pas les villages et ne gère pas
automatiquement nos récompenses de campagne. La récupération d’un rang clos et
l’attribution du cadeau doivent être implémentées dans l’app.

### Peu d’échanges, sans promettre une seule requête réseau

Objectif : une séance de publication hebdomadaire par joueur, aucune publication
après chaque combat. Les compteurs et résultats en attente restent sauvegardés
sur l’appareil. La publication du général utilise son instantané au moment de
cette séance ; le tableau peut donc être en retard sur l’état réel du village.

Avec GameKit, quatre valeurs différentes correspondent à des soumissions de
score distinctes. Une seule séance ne signifie pas un unique appel réseau :
authentification, lecture de la période, scores et récupération des rangs peuvent
demander plusieurs petits échanges. La méthode de soumission d’un score à plusieurs
tableaux réutilise la même valeur ; elle ne suffit pas pour nos quatre mesures.

Si la contrainte devient strictement « un seul envoi contenant tous les compteurs »,
un petit service personnel peut recevoir un paquet hebdomadaire et construire les
tableaux. Il faudra alors assurer identité, validation, stockage, lectures et
exploitation de ce service. Ne pas ajouter cela simplement pour éviter quelques
soumissions de nombres à Game Center.

Les tableaux sont mis en cache avec une date d’actualisation. Leur ouverture ne
déclenche pas un rafraîchissement à chaque navigation. Prévoir des reprises après
échec, espacées et limitées ; marquer séparément les scores confirmés pour ne pas
recommencer ceux déjà acceptés. Un joueur hors ligne n’émet aucune requête et ne
disparaît pas de sa campagne.

### Clôture hebdomadaire : la contrainte à ne pas masquer

Apple demande de soumettre les scores à l’occurrence en cours, pas à une période
déjà terminée. Un résultat de dimanche envoyé lundi ne peut donc pas être promis
dans le tableau clos du dimanche. Il ne faut pas non plus le créditer arbitrairement
à la nouvelle semaine. Les scores non publiés n’apparaissent pas au classement.

La première version peut classer un **instantané hebdomadaire de la campagne** :
le joueur publie les points acquis dans la période une fois, avant la clôture
affichée. L’écran indique la date de publication et précise que les actions
ultérieures ne modifient pas cette entrée. Définir la fenêtre de publication avant
implémentation ; ne pas publier silencieusement dès lundi puis laisser croire
que les combats du reste de la semaine sont inclus. Les anciens points non
publiés restent dans l’historique local, sans être crédités à une autre période.

Si le classement doit couvrir toutes les actions jusqu’à la clôture, il faudra
permettre plusieurs publications ou accepter que seul l’instantané envoyé soit
pris en compte. On ne peut pas avoir simultanément une publication très tôt dans
la semaine, zéro mise à jour ensuite et un résultat final exact de toute l’activité.

Une campagne déjà développée donne mécaniquement plus de moyens qu’un nouveau
refuge. Un classement de volume n’est donc pas une mesure pure d’habileté. Comparer
au minimum des règles et difficultés compatibles ; envisager des ligues d’époque
quand le nombre de participants le permettra.

Évolution possible, après validation de la campagne : une **épreuve hebdomadaire
commune**, avec même départ, règles, difficulté et nombre limité de marées.
Elle réutilise les champs et les unités mais n’importe pas l’armée ou les stocks
d’une ancienne campagne. Le joueur publie un résultat finalisé avant clôture.
Ce mode donne une comparaison de performance plus équitable ; il n’est pas
indispensable pour livrer les premiers tableaux de progression.

iOS ne garantit pas une exécution de fond à une heure choisie. Utiliser la connexion
au premier plan comme chemin fiable ; ne pas promettre un envoi automatique dimanche
soir lorsque l’app n’est jamais rouverte. Une tâche de fond serait une opportunité
supplémentaire, pas la garantie de participation.

### Récompenses et intégrité

Commencer par des pavillons, titres, emblèmes ou variantes visuelles du phare.
Une récompense de participation reconnaît une publication valide ; un meilleur
rang peut donner une distinction plus rare. Éviter une prime militaire permanente qui
donne aux gagnants un avantage croissant dans la compétition suivante.

Attribuer le cadeau de rang après clôture et lecture du résultat publié, pas selon
une position provisoire de la semaine. Conserver l’identité du joueur, la période,
la catégorie et la récompense déjà accordée. Ne jamais attribuer deux fois un
cadeau après relance ou nouvelle lecture du même tableau. La disponibilité et
le rattrapage des anciennes occurrences doivent être vérifiés avant de promettre
la récupération de récompenses après une longue absence.

Game Center authentifie l’auteur de l’envoi, mais ne prouve pas que notre jeu a
calculé correctement les points. Un jeu calculé entièrement sur l’appareil ne
garantit pas un classement inviolable. Contrôles de cohérence, comptage unique
des combats, identification des règles et exclusion des modes de test réduisent
les abus ordinaires ; ils ne remplacent pas une validation autoritaire.

Si les récompenses ont ensuite une forte valeur ou si une compétition stricte
devient centrale, prévoir un service qui valide les résultats, par exemple en
rejouant un journal d’actions d’une épreuve déterministe. Un seul petit paquet
peut suffire à cette validation, mais le stockage et le calcul restent à construire
et à exploiter. Ne pas promettre une protection absolue par une simple signature
produite dans l’app.

## Périmètre de validation avant une grande refonte

**Un premier scénario jouable d’environ vingt minutes :**

- un port, trois types de parcelles améliorables et un seul peuple à deux unités ;
- des ressources issues des parcelles et un recrutement qui les consomme ;
- cinq sites, un avant-poste et un partenaire commercial ;
- une route sûre, une route dangereuse et un passage qui change avec la marée ;
- garnison et escorte à choisir, un contrat et une attaque annoncée ;
- les plans du phare et sa première étape avec une conséquence visible.

Les essais commencent avec des réserves suffisantes pour rencontrer les décisions,
sans dépendre du remplissage hors ligne. Inclure une défaite suivie d’une reprise.
Ne pas construire la campagne entière avant d’avoir vu des personnes comprendre
et apprécier cette tranche de jeu.

Ordre de réalisation :

1. Formaliser la résolution d’une marée, l’engagement et le retour des forces.
2. Faire fonctionner ensemble contrat, avant-poste et défense sur une petite carte.
   Prévisualiser coûts, accès, dangers et forces mobilisées.
3. Donner un effet à la première étape du phare et montrer la reprise après défaite.
4. Observer les essais et corriger les décisions dominantes ou incompréhensibles.
5. Étendre ensuite aux trois époques, aux autres partenaires, au siège final et
   aux variantes de campagne.

Écarter au départ : multijoueur, serveurs payants, dizaines d’époques, multiples
villes complètes, douze marchandises, combats 3D et nouveau contenu chaque semaine.
La simulation locale réduit les coûts de service ; elle ne rend pas gratuits
la direction artistique, l’équilibrage et les tests.

## Comment décider si le concept mérite de continuer

Faire découvrir la tranche de jeu à environ dix personnes intéressées par la
stratégie mobile, sans guider chaque action. C’est une étude qualitative initiale,
pas une mesure représentative de rétention ou de marché.

Observer :

- savent-elles expliquer l’objectif et trouver la prochaine action ?
- comprennent-elles pourquoi leur convoi ou leur défense a réussi ou échoué ?
- choisissent-elles des solutions différentes pour des raisons cohérentes ?
- une défaite leur donne-t-elle envie d’adapter leur stratégie ou de fermer l’app ?
- veulent-elles poursuivre pour un objectif précis et reviennent-elles réellement
  lorsque la suite leur est accessible ?

Recueillir action observée et raison donnée. « Le thème est joli » et « je reviendrais
peut-être » ne valident pas la boucle. Une incompréhension d’interface ne condamne
pas le concept avant un essai corrigé.

Si la répartition des forces n’intéresse pas, simplifier le combat et approfondir
les routes. Si le commerce est une corvée, réduire les livraisons répétées et
renforcer les accords uniques. Si le jeu fonctionne seulement grâce aux délais,
revoir les décisions avant d’allonger la campagne.

## Vérifications lors de l’implémentation

- Résolutions, récompenses et dégâts appliqués une seule fois après relance.
- Conservation des engagements, retours, marées et états de routes.
- Aucune troupe simultanément en escorte, expédition et garnison.
- Offres réalisables, marchandises réservées et plafonds présentés avant engagement ;
  aucun arbitrage commercial sans limite.
- Difficulté liée à des événements visibles ; aucune attaque rétroactive dans une
  ancienne sauvegarde, aucune aggravation militaire due à une absence.
- Reconstruction possible avec les moyens restants.
- Victoire unique, arrêt des attaques et conservation de l’archive.
- Migration des sauvegardes actuelles à définir avant activation.
- Sauvegarde des compteurs OFF/DEF/pillage et résultats finalisés, sans doublon
  après relance ou restauration.
- Publication avant clôture, panne réseau, succès partiel, changement de compte,
  changement de semaine et absence prolongée dans les classements.
- Aucune récompense de rang provisoire ou déjà attribuée ; aucun résultat de test
  accepté comme résultat normal.
- Cibles, phases, coûts et conséquences utilisables avec VoiceOver et le grand texte,
  sans dépendre uniquement d’une couleur.

Le présent changement de document n’active aucun de ces comportements dans l’app.

## Sources et portée de la recommandation

- [InnoGames — Forge of Empires](https://www.innogames.com/games/forge-of-empires/) :
  progression à travers les époques et transformation de la ville.
- [InnoGames — chapitres d’Elvenar](https://support.innogames.com/kb/Elvenar/en_DK/articles/459) :
  progression par chapitres. Trois étapes est notre choix de périmètre.
- [Travian — World Wonder](https://support.travian.com/en/articles/103) :
  objectif de fin de monde, ressources et coordination de défense.
- [Travian — Natars et progression](https://support.travian.com/en/articles/225-natars-villages-troops-and-game-progress) :
  attaques dans des situations spécifiques ; ne pas en déduire que tous les
  ennemis attaquent simplement avec le temps.
- [Thronefall — description du développeur sur Steam](https://store.steampowered.com/app/2239150/Thronefall/) :
  rythme de construction et défense, inspiration de clarté plutôt que d’action.
- [Apple — critères de mise en avant](https://developer.apple.com/app-store/getting-featured/) :
  mécaniques, conception visuelle, contrôles, rejouabilité, performances et valeur ;
  aucune recette ne garantit une sélection.
- [Apple — Game Center](https://developer.apple.com/game-center/) : identité,
  classements et intégration via GameKit.
- [Apple — configuration des classements](https://developer.apple.com/help/app-store-connect/configure-game-center/manage-leaderboards/) :
  tableaux classiques et récurrents, durée et fréquence configurables.
- [Apple — classements récurrents](https://developer.apple.com/documentation/gamekit/creating-recurring-leaderboards?changes=_3) :
  soumission dans la période active et lecture d’occurrences précédentes.
- [Apple — soumettre et lire les scores](https://developer.apple.com/documentation/gamekit/encourage-progress-and-competition-with-leaderboards) :
  une valeur soumise à un ou plusieurs tableaux et chargement des entrées.
- [Apple — exécution en arrière-plan](https://developer.apple.com/documentation/backgroundtasks/choosing-background-strategies-for-your-app?changes=_5) :
  le système choisit le moment d’exécution des tâches de rafraîchissement.

Scénario, marées, contrats, époques et rythme sont nos choix de conception.
Ces sources décrivent des références ; elles ne prouvent pas que cette combinaison
fidélisera notre public.
