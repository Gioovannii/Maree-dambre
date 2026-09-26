# Les Marées d’Ambre — Village et monde

## Prototype actuel

- Prologue et peuples : histoire d’introduction, puis choix entre les Sauniers (+10 % de bois), la Garde de Nacre (+1 défense automatique de base) et le Pacte des Roseaux (+10 % d’ambre). Aucun malus ; les sauvegardes existantes gardent leur village et découvrent le choix au prochain lancement.

Ouvrir `MareesAmbre.xcodeproj` et choisir le schéma **MareesAmbre**, iOS 27. Un seul simulateur à la fois est conseillé sur le Mac de développement de 8 Go ; les vérifications précédentes ont rencontré de longs délais CoreSimulator.

- **Village** : deux cartes sélectionnables sur la même scène 2,5D. **Ressources** affiche 10 champs de forêt, vivres et ambre ; **Centre-ville** affiche 12 lots urbains, dont la Maison des Veilleurs. Chaque champ n’accepte que son producteur adapté au terrain. Le centre propose une tour de garde (statistique de défense automatique) et un entrepôt (+500 de capacité). Les cartes sont cadrées de près et se parcourent par glissement. La disposition SwiftUI s’adapte à la largeur disponible, de l’écran extérieur au grand écran d’un iPhone Duo pliable.
- **Production continue** : chaque bâtiment produit à l’heure. Les fractions s’accumulent et sont sauvegardées ; une ressource est ajoutée dès que sa fraction atteint une unité. Les stocks progressent hors ligne sans limite de durée, jusqu’à leur plafond naturel.
- **Monde** : 200 × 200 cases réellement générées, déplacement au doigt, zoom par pincement ou boutons, sélection et coordonnées. Le Canvas ne dessine que les cases visibles, sans créer 40 000 vues. Les coordonnées et les boutons de capitales offrent une alternative accessible aux gestes.
- **Trois bots** : capitales présentes dès le départ, niveaux et territoires affichés. Toutes les six heures, y compris hors ligne, chaque bot tente une extension terrestre adjacente ; limite de 64 cases et niveau 10. Aucune extension sur le village joueur ou un autre territoire.
- **Persistance** : instantané local `village.v2.<graine>` ; anciennes sauvegardes `archipelago.v1` conservées sans migration. Même graine hebdomadaire UTC, mêmes conditions de départ. Aucun changement pendant l’absence.

La carte du monde est explorable, mais les expéditions, la fondation de nouveaux villages, l’entraînement des troupes et les combats contre les bots ne sont pas encore implémentés. Les bots sont des règles locales déterministes, pas un modèle IA ni un service en ligne. Le défi reste sans objectif final ni classement.

## Architecture ajoutée

`VillageState` porte construction, dépenses, production fractionnaire et horodatages. La production est calculée à partir du temps réel écoulé, y compris à la réouverture. Elle n’est pas plafonnée par une durée hors ligne ; la réserve commence à 300 et augmente de 500 par entrepôt. Les bots progressent toutes les six heures, également pendant une absence. `WorldMap` génère 40 000 terrains à partir d’une graine. `SettlementLayout` stocke les coordonnées de la scène indépendamment de SwiftUI pour permettre un futur rendu sur un plan RealityKit. `VillageSession` actualise et sauvegarde périodiquement tant que l’app est active, ainsi qu’au changement de scène. L’iOS suspend l’app en arrière-plan : au retour, le temps écoulé est rattrapé depuis la sauvegarde, sans processus qui tourne clandestinement.

L’affichage conserve les ressources entières et leurs fractions dans la sauvegarde. Les stocks ne gagnent une unité que lorsque la fraction cumulée atteint un entier. Les anciennes sauvegardes sont migrées jusqu’à la version 6 : les producteurs sont déplacés vers leur carte lorsque des emplacements adaptés sont libres et le choix de peuple est ajouté sans perdre le village existant.

## Contrôles

`sh Scripts/check-domain.sh` vérifie le déterminisme, les constructions invalides, les dépenses, la production fractionnaire à une demi-heure et une heure, les bots après six heures et trente jours, la sérialisation et l’absence de collecte en double.

Builds iOS et simulateur validés dans la copie de préparation. Le contrôle visuel complet (gestes, VoiceOver, tailles de texte extrêmes et iPad) n’est pas une suite UI automatisée et reste à compléter.

---

## Notes historiques du premier prototype

# Les Marées d’Ambre

Prototype iOS solo, natif et hors ligne. Ouvrir `MareesAmbre.xcodeproj`, choisir le schéma **MareesAmbre**, puis un simulateur iOS 27. Pour un appareil physique, choisir son équipe de signature et un identifiant de bundle personnel.

## Périmètre jouable

Cinq îles sélectionnables, faction **Ligue des Veilleurs**, bois / ambre / vivres, détail de chaque île et amélioration du port. Une amélioration dépense des ressources et avance le tour. Aucune horloge de production, attaque ou perte pendant une absence. Les stocks initiaux permettent deux améliorations ; la collecte, les expéditions et la conquête restent à créer. Aucun achat, backend, package externe, service de classement ou IA.

La semaine ISO en UTC définit la graine commune et une légère variation de la carte. Les règles et stocks de départ sont identiques à graine égale. C’est la fondation d’un défi hebdomadaire, sans objectif, score ni classement pour l’instant. La semaine est fixée à l’ouverture de la session ; le prochain lancement après une nouvelle semaine ouvre une sauvegarde distincte. Les anciennes sauvegardes ne sont pas effacées, mais leur consultation n’est pas encore exposée. L’horloge locale n’est pas une garantie anti-triche.

## Architecture

- `MareesAmbre/Domain` : types valeur Codable, règles et graine ; aucune dépendance SwiftUI.
- `MareesAmbre/Features` : état `@MainActor @Observable`, vues et carte.
- `MareesAmbre/Persistence` : petit instantané JSON versionné dans UserDefaults, séparé par graine. Suffisant pour ce prototype, sans synchronisation ni garantie de sauvegarde après désinstallation.
- `Tests/DomainChecks.swift` : exécutable de contrôle des invariants, sans bibliothèque externe.

## Carte native et piste MapKit

| Solution | Atouts | Limites pour ce jeu |
| --- | --- | --- |
| SwiftUI Shape / Canvas — retenu | Carte fictive hors ligne, style libre, boutons accessibles, pas de tuiles réseau | Zoom et grandes cartes à implémenter si nécessaires |
| SpriteKit — évolution possible | Caméra, nombreuses cases et effets animés | Surcouche SwiftUI nécessaire pour détails et accessibilité |
| MapKit — piste comparative | Pan/zoom, annotations, cartographie géographique | Coordonnées terrestres et fond réel peu adaptés à une grille fictive ; disponibilité du fond hors ligne non garantie |

La logique stocke uniquement positions normalisées et identifiants d’îles. Un futur rendu MapKit peut projeter ces positions dans une petite région et renvoyer le même identifiant de sélection, sans déplacer les règles dans la carte. Aucun rendu MapKit n’est implémenté à ce stade ; une comparaison interactive serait une étape séparée si la direction géographique est retenue.

## Interface et accessibilité

Palette marine/ambre, typographie système, détails sous la carte sur iPhone et à droite sur écran large. Défilement en portrait et paysage, mise en colonne aux tailles de texte d’accessibilité, boutons d’au moins 44 points, sélection indiquée par contour et VoiceOver, alternative textuelle aux îles. Aucune animation imposée. VoiceOver, tailles extrêmes et rotations restent à valider manuellement sur appareils.

## Vérification

Environnement observé : **Xcode 27.1 (27A9269)**, SDK iOS 27.1, compilateur Swift 6.4, mode langage Swift 6. Cible iPhone et iPad, iOS minimum 27.0.

```sh
xcodebuild -project MareesAmbre.xcodeproj -scheme MareesAmbre -configuration Debug -destination 'generic/platform=iOS' -derivedDataPath /tmp/MareesAmbreDerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project MareesAmbre.xcodeproj -scheme MareesAmbre -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/MareesAmbreDerivedData CODE_SIGNING_ALLOWED=NO build
sh Scripts/check-domain.sh
```

Le sandbox Codex bloque le serveur de macros Swift ; le build doit y être autorisé hors sandbox. L’avertissement d’extraction des métadonnées App Intents est attendu en l’absence d’App Intents. Aucune icône de distribution ni configuration App Store n’est fournie.

## Suite possible

Définir une boucle de récolte / exploration et un objectif hebdomadaire fini avant d’ajouter des services. Game Center et un conseiller Apple on-device resteraient des adaptateurs facultatifs, sans dépendance du moteur ni du jeu hors ligne.

Dernière vérification : build Debug iOS Simulator réussi avec Xcode 27.1 et contrôles du domaine PASS. Le dépôt local initial ne possède pas de remote GitHub ; aucun push ne sera effectué.

Limite de vérification : le simulateur iPad Pro 11 pouces iOS 27 est passé à l’état Booted, mais la commande d’installation est restée en attente sans résultat lors de cette session. Le rendu iPad n’est donc pas validé. La compilation universelle iPhone/iPad a bien réussi.
