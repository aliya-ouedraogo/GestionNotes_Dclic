# AppNotes — DCLIC Développement Mobile (Niveau Intermédiaire)

Application de gestion de notes développée avec **Flutter** et une base de
données locale **SQLite** (via `sqflite`), réalisée dans le cadre du projet
Semaine 6 de la formation DCLIC.

## Sommaire

1. [Aperçu](#aperçu)
2. [Fonctionnalités](#fonctionnalités)
3. [Installation](#installation)
4. [Utilisation](#utilisation)
5. [Structure du projet](#structure-du-projet)
6. [Diagramme de classes](#diagramme-de-classes)
7. [Choix de conception](#choix-de-conception)
8. [Dépannage](#dépannage)
9. [Pistes d'amélioration futures](#pistes-damélioration-futures)

## Aperçu

L'application permet à un utilisateur de créer un compte local, de se
connecter, puis de gérer ses notes (ajout, modification, suppression,
marquage « terminée ») avec un filtrage par catégorie. Toutes les données
sont stockées uniquement sur l'appareil, sans aucune connexion réseau.

## Fonctionnalités

- Inscription et connexion locales (sans serveur).
- Création, modification et suppression de notes (texte, date, importance).
- Marquage d'une note comme terminée.
- Filtrage des notes : Toutes / Importantes / Terminées.
- Messages d'erreur clairs à chaque étape (champs vides, identifiants
  incorrects, pseudo déjà pris, confirmation de suppression).
- Persistance complète via SQLite : les notes et les comptes restent
  disponibles après fermeture de l'application.

## Installation

1. Installer Flutter (canal stable) : https://docs.flutter.dev/get-started/install
2. Récupérer le projet (dossier `lib/`, `assets/` et `pubspec.yaml`) :
   ```bash
   flutter create appnotes_dclic
   # puis remplacer le dossier lib/, le dossier assets/ et pubspec.yaml
   # générés par ceux fournis dans ce livrable
   ```
3. Installer les dépendances :
   ```bash
   flutter pub get
   ```
4. Lancer l'application sur un émulateur ou un appareil Android connecté :
   ```bash
   flutter run
   ```

## Utilisation

| Écran | Action |
|---|---|
| **Connexion** | Saisir pseudo + mot de passe existants, ou suivre le lien « Pas encore de compte ? S'inscrire ». |
| **Inscription** | Créer un compte (pseudo unique + mot de passe), redirige automatiquement vers la liste des notes. |
| **Liste des notes** | Filtrer via les onglets, ajouter une note avec le bouton `+`, modifier via l'icône crayon, supprimer via l'icône corbeille, cocher le rond pour marquer une note terminée, se déconnecter via l'icône en haut à droite. |
| **Ajout / modification** | Renseigner le texte, choisir une date via le calendrier, cocher « Important » si besoin, puis Enregistrer. |
| **Suppression** | Confirmer ou annuler dans la boîte de dialogue avant suppression définitive. |

## Structure du projet

```
lib/
  main.dart                         Point d'entrée
  modele/
    note.dart                       Modèle de données Note
  services/
    database_helper.dart            Accès SQLite (utilisateurs + notes)
  views/
    couleurs.dart                   Palette reprise des maquettes Figma
    ecran_connexion.dart            Écran de connexion
    ecran_inscription.dart          Écran de création de compte
    ecran_liste_notes.dart          Écran principal (liste, filtres, FAB)
    carte_note.dart                 Carte de note (texte, date, actions)
    dialogue_note.dart              Modale d'ajout / modification
    dialogue_suppression.dart       Modale de confirmation de suppression
assets/
  images/
    icone_message.png               Icône des écrans de connexion/inscription
docs/
  diagramme_classes.png             Ton diagramme de classes (à ajouter)
  screenshots/                      Tes captures d'écran (à ajouter)
```

## Diagramme de classes

![Diagramme de classes](docs/diagramme_classes.png)

*Pour utiliser ton propre diagramme : exporte-le en image (PNG ou JPG)
depuis ton outil, dépose le fichier dans `docs/diagramme_classes.png`
(même nom que ci-dessus, ou adapte le chemin dans la ligne `![...]`) — il
s'affichera alors automatiquement ici, sans rien changer d'autre.*

<details>
<summary>Diagramme Mermaid généré automatiquement (repli, à garder ou supprimer)</summary>

```mermaid
classDiagram
    class Note {
      +int? id
      +String text
      +String date
      +bool important
      +bool done
      +copyWith() Note
      +toMap() Map
      +fromMap(Map) Note
    }

    class DatabaseHelper {
      +instance DatabaseHelper
      -Database _db
      +database Database
      +login(username, password) bool
      +register(username, password) bool
      +insertNote(Note) int
      +updateNote(Note) int
      +deleteNote(id) int
      +getNotes() List~Note~
    }

    class LoginScreen {
      -TextEditingController usernameCtrl
      -TextEditingController passwordCtrl
      +handleLogin()
    }

    class RegisterScreen {
      -TextEditingController usernameCtrl
      -TextEditingController passwordCtrl
      +handleRegister()
    }

    class NotesListScreen {
      -List~Note~ notes
      -NoteFilter filter
      +loadNotes()
      +addNote()
      +editNote(Note)
      +deleteNote(Note)
      +toggleDone(Note, bool)
    }

    class NoteTile {
      +Note note
      +onEdit()
      +onDelete()
      +onToggleDone()
    }

    class AppColors {
      +Color primary
      +Color background
      +Color card
      +Color danger
      +Color textDark
      +Color textMuted
    }

    LoginScreen --> DatabaseHelper : utilise
    RegisterScreen --> DatabaseHelper : utilise
    NotesListScreen --> DatabaseHelper : utilise
    DatabaseHelper --> Note : gère
    NotesListScreen --> NoteTile : affiche *
    NoteTile --> Note : représente
    NotesListScreen ..> Note : crée / modifie via dialogues
    LoginScreen ..> RegisterScreen : navigue vers
    LoginScreen ..> NotesListScreen : navigue vers
    RegisterScreen ..> NotesListScreen : navigue vers
```

</details>

## Captures d'écran

Dépose tes exports dans `docs/screenshots/` avec ces noms (ou adapte les
chemins ci-dessous à tes propres noms de fichiers) :

| Écran | Aperçu |
|---|---|
| Connexion | ![Connexion](docs/screenshots/connexion.png) |
| Inscription | ![Inscription](docs/screenshots/inscription.png) |
| Liste des notes | ![Liste des notes](docs/screenshots/liste_notes.png) |
| Ajout / modification | ![Ajout d'une note](docs/screenshots/ajout_note.png) |
| Suppression | ![Suppression d'une note](docs/screenshots/suppression.png) |



## Choix de conception

- **Base de données locale (SQLite via sqflite)** : deux tables, `users`
  (authentification) et `notes` (id, text, date, important, done). Aucune
  donnée ne quitte l'appareil — logique d'écoconception (pas de requêtes
  réseau, pas de serveur distant à maintenir).
- **Inscription séparée de la connexion** : un compte doit être créé
  explicitement (`DatabaseHelper.register`) ; la connexion ne fait que
  vérifier des identifiants existants, avec un message d'erreur générique
  volontairement peu précis (« pseudo ou mot de passe incorrect ») pour ne
  pas révéler si c'est le pseudo qui est inconnu ou le mot de passe qui est
  faux.
- **Icône de connexion** : `assets/images/icone_message.png` reprend
  l'icône exacte de la maquette Figma (pas une icône Material générée),
  affichée avec `BoxFit.contain` dans un cadre de taille fixe pour que ses
  proportions d'origine soient toujours respectées.
- **Bouton d'ajout rond** : le FAB force `shape: CircleBorder()` — Material
  3 utilise par défaut une forme arrondie non circulaire, qu'il faut donc
  spécifier explicitement pour obtenir un cercle parfait comme la maquette.

## Dépannage

**L'icône de connexion ne s'affiche pas / erreur `Unable to load asset`**
1. Vérifier que `pubspec.yaml` contient bien, sous la clé `flutter:` de
   premier niveau (pas sous `dependencies:`) :
   ```yaml
   flutter:
     uses-material-design: true
     assets:
       - assets/images/
   ```
2. Vérifier que le dossier est à la racine du projet, au même niveau que
   `lib/` et `pubspec.yaml` — pas à l'intérieur de `lib/`.
3. Vérifier le nom exact du fichier en terminal (`ls assets/images` sous
   Mac/Linux, `dir assets\images` sous Windows). Piège fréquent : Windows
   masque les extensions connues, un fichier renommé peut donc s'appeler
   en réalité `icone_message.png.png` sans que ça se voie dans
   l'explorateur.
4. Après toute modification de `pubspec.yaml` ou ajout d'un nouvel asset,
   un hot reload ne suffit pas : lancer `flutter pub get`, puis arrêter
   complètement l'application et refaire `flutter run` (pas seulement
   `r`/`R` dans le terminal).
5. En cas de doute persistant : `flutter clean` puis `flutter pub get` et
   relancer.

## Pistes d'amélioration futures

- Barre de recherche textuelle si le nombre de notes grandit.
- Affichage/masquage du mot de passe complété par un « mot de passe oublié »
  local (question de sécurité) si plusieurs comptes doivent coexister sur un
  même appareil.
- Rappels/notifications locales à l'approche de la date d'une note.
- Rester connecté entre deux lancements (via `shared_preferences`), retiré
  volontairement pour limiter les dépendances du projet.
