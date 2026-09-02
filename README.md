# BaseTemplate — Socle de développement multi-langage

Template de démarrage réutilisable pour tous les projets, avec une compatibilité maximale
couvrant les langages les plus utilisés au monde : **Python, JavaScript/TypeScript, Java,
C#/.NET, C/C++, Go, Rust, PHP, Ruby, Swift, Kotlin et Dart/Flutter**.
Il fournit les fondations professionnelles communes : structure MVC, tests unitaires,
qualité de code automatisée, débogage F5 et extensions VSCode recommandées.

## 🚀 Démarrage rapide (en quelques clics)

Pour créer un nouveau projet à partir de ce template :

1. **Copiez** ce dossier `BaseTemplate` vers l'emplacement de votre nouveau projet et
   renommez-le (Explorateur Windows : clic droit → Copier / Coller, puis renommer).
2. **Ouvrez** le dossier copié dans VSCode (`Fichier > Ouvrir le dossier...`).
3. Une notification VSCode propose d'installer les **extensions recommandées** →
   cliquez sur **Installer tout** (ou **Install All**).
4. Ouvrez un terminal (`` Ctrl+` ``) et initialisez git :
    ```powershell
    git init; git add -A; git commit -m "chore: état initial du template"
    ```
5. Ajoutez votre code au projet (fichiers `.py`, `.js`, `.java`, etc. dans `src/model`,
   `src/view`, `src/controller`...), ou lancez d'abord un script `scripts/init-<langage>.ps1`
   (liste complète plus bas) pour générer le squelette du langage choisi.
6. **Palette de commandes** (`Ctrl+Maj+P`) → tapez `Run Task` → choisissez
   **🚀 Template : détecter le langage et épurer le projet**.
   Le script affiche _"Le template détecte que le langage principal de ce projet est : X"_
   → répondez `o` pour confirmer. Le template est alors automatiquement épuré (scripts,
   extensions, débogage F5, tâches, `.gitignore`, pre-commit, CI, Dev Container) pour ne
   garder que ce qui concerne votre langage.
7. Dans le panneau **Run and Debug** (`Ctrl+Maj+D`), choisissez la configuration de débogage
   restante puis appuyez sur **F5**.
8. Ouvrez le panneau **Testing** (icône éprouvette) pour voir/exécuter les tests unitaires.

C'est prêt : vos développeurs n'ont qu'à copier le dossier, ouvrir VSCode, cliquer sur
« Installer tout », lancer la tâche d'épuration et répondre « o ».

## Structure

```
BaseTemplate/
├── .vscode/            # Config partagée VSCode (extensions, debug, tasks, settings)
├── src/
│   ├── model/          # Données, logique métier
│   ├── view/           # Présentation / UI
│   └── controller/     # Orchestration entre model et view
├── tests/
│   ├── unit/           # Tests unitaires
│   └── integration/    # Tests d'intégration
├── scripts/            # Scripts d'amorçage par langage
├── .editorconfig
├── .gitignore
└── .pre-commit-config.yaml
```

Le pattern MVC est matérialisé par les 3 dossiers `src/model`, `src/view`, `src/controller`.
Adaptez les noms de fichiers internes selon le langage (ex. `user_model.py`, `UserController.ts`,
`user_model.dart`), mais conservez cette séparation dans tous les projets dérivés.

## Démarrer un nouveau projet à partir de ce template (détails)

> Voir le **🚀 Démarrage rapide** ci-dessus pour la procédure en quelques clics. Cette section
> détaille chaque étape et les options avancées.

1. Copiez/clonez ce dossier vers le nouveau projet, puis committez cet état initial
   (`git init; git add -A; git commit -m "chore: état initial du template"`).
2. Ajoutez votre code (et/ou lancez le script `scripts/init-<langage>.ps1` correspondant,
   voir liste ci-dessous).
3. Lancez `scripts/setup-project.ps1` (ou la tâche VSCode **🚀 Template : détecter le langage
   et épurer le projet**) : il détecte automatiquement le(s) langage(s)
   principal(aux) du projet (fichiers marqueurs + extensions de fichiers), affiche
   _"Le template détecte que le langage principal de ce projet est : X"_ et demande
   confirmation. Une fois confirmé, il **épure** le template (scripts `init-*.ps1`,
   `.vscode/extensions.json`, `launch.json`, `tasks.json`, `settings.json`, `.gitignore`,
   `.pre-commit-config.yaml`, CI GitHub Actions, Dev Container) pour ne garder que ce qui
   concerne le(s) langage(s) confirmé(s). Si vous répondez non, il propose le candidat
   suivant ; si plusieurs langages ont un poids comparable (ex. HTML + JavaScript), il les
   traite comme un projet multi-langage.
    - `scripts/setup-project.ps1 -DryRun` : simule l'épuration sans rien modifier.
    - Nécessite un dépôt git avec au moins un commit (sécurité de réversibilité) ; utilisez
      `-Force` pour l'ignorer.
4. Scripts d'initialisation disponibles (à lancer avant ou après l'étape 3) :
    - `scripts/init-python.ps1` → crée `.venv`, installe `pytest`/`ruff`/`pre-commit`
    - `scripts/init-node.ps1` → `package.json`, `eslint`, `prettier`, `vitest`
    - `scripts/init-cpp.ps1` → `CMakeLists.txt` + configuration du build
    - `scripts/init-dart.ps1` → `pubspec.yaml` + dépendances
    - `scripts/init-java.ps1` → squelette Maven
    - `scripts/init-dotnet.ps1` → projet .NET console + projet de tests xUnit
    - `scripts/init-go.ps1` → module Go (`go.mod`)
    - `scripts/init-rust.ps1` → projet Cargo
    - `scripts/init-php.ps1` → `composer.json` + PHPUnit
    - `scripts/init-ruby.ps1` → `Gemfile` + RSpec/Rubocop
    - `scripts/init-swift.ps1` → package Swift (SPM)
    - `scripts/init-kotlin.ps1` → projet Gradle Kotlin
5. Ouvrez le dossier dans VSCode : les extensions recommandées (`.vscode/extensions.json`)
   sont proposées automatiquement à l'installation.

## Tests unitaires

- **Python** : `pytest` (déjà activé dans `.vscode/settings.json` via
  `python.testing.pytestEnabled`). Les tests apparaissent dans le panneau **Testing** de VSCode
  avec exécution/débogage individuel par test (icônes ▶ dans l'éditeur).
- **Node/JS/TS** : installez l'extension `vitest.explorer` ou `orta.vscode-jest` (déjà dans les
  recommandations) → détection et affichage automatique dans le panneau **Testing**.
- **C++** : `matepek.vscode-catch2-test-adapter` détecte les tests CTest/Catch2/GoogleTest et
  les affiche dans le panneau **Testing**.
- **Dart/Flutter** : l'extension `dart-code.dart-code` affiche nativement les tests dans le
  panneau **Testing**.
- **Java** : `vscjava.vscode-java-test` (inclus dans le pack Java) détecte JUnit/TestNG et les
  affiche dans le panneau **Testing**.
- **C#/.NET** : `ms-dotnettools.csdevkit` détecte automatiquement les tests xUnit/NUnit/MSTest.
- **Go** : l'extension `golang.go` affiche les `_test.go` dans le panneau **Testing** avec
  CodeLens « run test » / « debug test ».
- **Rust** : `rust-lang.rust-analyzer` affiche les `#[test]` dans le panneau **Testing** et via
  CodeLens.
- **PHP** : PHPUnit est détecté par `bmewburn.vscode-intelephense-client` combiné à l'extension
  PHPUnit si besoin d'une intégration plus poussée du panneau Testing.
- **Ruby** : RSpec s'exécute via la tâche `ruby: test (rspec)` ; `shopify.ruby-lsp` fournit le
  support éditeur.
- **Swift** : `swiftlang.swift-vscode` détecte les tests XCTest/Swift Testing dans le panneau
  **Testing**.
- **Kotlin** : `fwcd.kotlin` + Gradle affichent les tests JUnit dans le panneau **Testing**.

Dans tous les cas, ouvrez l'onglet **Testing** (icône éprouvette) dans la barre latérale de
VSCode pour l'affichage graphique (arborescence des tests, statut réussite/échec, couverture).

## Qualité de code automatique

- **Formatage à l'enregistrement** : activé dans `.vscode/settings.json` (`editor.formatOnSave`,
  `source.fixAll`, `source.organizeImports`) pour tous les langages configurés.
- **Hooks Git (pre-commit)** : `.pre-commit-config.yaml` exécute automatiquement le linting/formatage
  avant chaque commit. Installation : `pip install pre-commit && pre-commit install`.
- **Tâches VSCode** (`Ctrl+Maj+P` → `Run Task`) : build, tests et installation des dépendances
  par langage sont définis dans `.vscode/tasks.json`.

## Lancement avec F5

`.vscode/launch.json` contient une configuration de débogage prête à l'emploi par langage :
Python, Node.js, C++ (gdb), Java, C#/.NET, Go, Rust (lldb), PHP (Xdebug), Ruby, Swift, Kotlin
et page web via Chrome. Sélectionnez la configuration adaptée dans le menu déroulant du panneau
**Run and Debug**, puis F5 la relance automatiquement à chaque fois (VSCode mémorise la dernière
configuration choisie par workspace).

## Gestion des versions de langage

Le fichier [.tool-versions](.tool-versions) centralise la version cible de chaque langage/outil
du projet (format inspiré d'asdf). Trois scripts s'appuient dessus :

- **`scripts/check-versions.ps1`** — compare les versions installées sur la machine à celles
  déclarées dans `.tool-versions` et affiche un rapport (`OK` / `À METTRE À JOUR` / `NON INSTALLÉ`).
  Une tâche VSCode du même nom s'exécute **automatiquement à l'ouverture du dossier**
  (`.vscode/tasks.json`, `runOptions.runOn: folderOpen`) pour détecter tout de suite un
  décalage de version.
- **`scripts/update-tooling.ps1`** — met à jour les toolchains et outils de lint/format déjà
  présents dans le projet (pre-commit, ruff, rustup, gems, paquets npm/composer/pub...).
- **`scripts/migrate-code.ps1`** — applique les codemods/migrations automatiques officiels
  quand une version de langage évolue (`pyupgrade` + `ruff --fix`, `eslint --fix`, `dart fix
--apply`, `go fix`, `cargo fix`, `dotnet format`, `rubocop -A`). Relisez toujours le diff
  généré avant de committer.

Workflow recommandé en cas de montée de version d'un langage :

1. Mettre à jour la ligne correspondante dans `.tool-versions`.
2. Installer la nouvelle version du langage sur la machine (gestionnaire de version dédié :
   `pyenv`, `nvm`, `rustup`, `sdkman`, etc.).
3. Lancer la tâche **`versions: mettre à jour les outils`** puis **`versions: migrer le code
(codemods)`** (`Ctrl+Maj+P` → `Run Task`).
4. Relancer les tests (`Testing` panel) pour valider la migration.

## Recommandations complémentaires

- **Convention de commits** : ce projet suit [Conventional Commits](https://www.conventionalcommits.org/fr/)
  (voir [CONTRIBUTING.md](CONTRIBUTING.md)) pour un historique lisible et compatible avec la
  génération automatique de changelog.
- **Versionnement et changelog automatiques (optionnel)** : [.github/workflows/release-please.yml](.github/workflows/release-please.yml)
  (avec [release-please-config.json](release-please-config.json) /
  [.release-please-manifest.json](.release-please-manifest.json)) ouvre automatiquement une PR
  de release (version + `CHANGELOG.md`) à partir des commits Conventional Commits sur `main`.
  **Déclenché manuellement uniquement** (`workflow_dispatch`) tant que ce dépôt reste un
  template — décommentez le déclencheur `push` dans le fichier une fois un vrai projet démarré.
  Une fois activé, laissez l'outil gérer `CHANGELOG.md` plutôt que de l'éditer à la main.
- **Code de conduite** : [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) (basé sur le Contributor
  Covenant) à adapter avec un contact réel.
- **CI (intégration continue)** : [.github/workflows/ci.yml](.github/workflows/ci.yml) détecte
  automatiquement le(s) langage(s) présent(s) dans le projet (fichier marqueur : `requirements-dev.txt`,
  `package.json`, `pom.xml`, `*.csproj`, `go.mod`, `Cargo.toml`, `composer.json`, `Gemfile`,
  `pubspec.yaml`, `CMakeLists.txt`) et lance l'installation + les tests correspondants à chaque
  push/PR.
- **Mises à jour de dépendances** : [.github/dependabot.yml](.github/dependabot.yml) surveille
  chaque écosystème (npm, pip, Maven, NuGet, Go, Cargo, Composer, Bundler, pub, GitHub Actions,
  Dev Containers). **Désactivé par défaut** (`open-pull-requests-limit: 0` sur chaque bloc) tant
  que ce dépôt reste un template non développé — retirez cette ligne sur les écosystèmes réels
  d'un projet dérivé et supprimez les blocs non utilisés.
- **Modèles GitHub** : templates d'issues (`.github/ISSUE_TEMPLATE/`) et de pull request
  (`.github/PULL_REQUEST_TEMPLATE.md`) prêts à l'emploi, ainsi qu'un [.github/CODEOWNERS](.github/CODEOWNERS)
  à adapter avec votre identifiant GitHub.
- **Environnement reproductible** : [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json)
  fournit un conteneur de développement (image `universal` + Rust/PHP/.NET/Go) utilisable via
  l'extension _Dev Containers_ — élimine les problèmes « ça marche sur ma machine ».
- **Décisions d'architecture** : [docs/](docs/README.md) et [docs/adr/](docs/adr/0001-record-architecture-decisions.md)
  contiennent un gabarit d'Architecture Decision Record (ADR) à dupliquer pour tout choix
  technique structurant.
- **Analyse de sécurité statique** : [.github/workflows/codeql.yml](.github/workflows/codeql.yml)
  lance CodeQL sur les langages présents (à ajuster dans la matrice `language`). **Déclenché
  manuellement uniquement** (`workflow_dispatch`) tant que le dépôt reste un template sans code
  source réel — CodeQL échoue sinon, faute de fichiers à analyser/compiler. Une fois ce template
  copié vers un vrai projet (et épuré via `setup-project.ps1`), décommentez les déclencheurs
  `push`/`pull_request`/`schedule` dans le fichier.
- **Alternative cross-plateforme aux scripts PowerShell** : [Taskfile.yml](Taskfile.yml) (outil
  [go-task](https://taskfile.dev/)) permet d'exécuter les mêmes actions (`task check-versions`,
  `task update-tooling`, `task migrate-code`, `task new-feature -- -Name X -Lang python`,
  `task precommit`) depuis macOS/Linux, ou si vous installez PowerShell 7 (`pwsh`).
- **Nouvelle fonctionnalité** : `scripts/new-feature.ps1 -Name <Nom> -Lang <langage>` génère les
  fichiers Model/View/Controller/Test de base dans l'arborescence MVC.
- **Changelog** : [CHANGELOG.md](CHANGELOG.md) (format Keep a Changelog) à tenir à jour à chaque
  modification notable.
- **Licence** : [LICENSE](LICENSE) (propriétaire / tous droits réservés par défaut — à adapter
  selon le projet dérivé).
- **Sécurité** : [SECURITY.md](SECURITY.md) décrit la politique de signalement des
  vulnérabilités. Le hook `gitleaks` (actif par défaut dans `.pre-commit-config.yaml`) bloque
  tout commit contenant une clé/API secret détectable. Pensez aussi à activer
  _Secret Scanning_/_CodeQL_ sur le dépôt distant.
- **Variables sensibles** : copiez [.env.example](.env.example) en `.env` (ignoré par git) pour
  vos valeurs réelles ; ne committez jamais de secrets en clair.
- **Orthographe/relecture** : [cspell.json](cspell.json) configure `streetsidesoftware.code-spell-checker`
  avec un dictionnaire technique de base (à enrichir par projet).
- **Cohérence multi-plateforme** : [.gitattributes](.gitattributes) normalise les fins de ligne
  et exclut `scripts/` des statistiques de langage GitHub.
- **Couverture de code** : l'extension `ryanluker.vscode-coverage-gutters` (déjà recommandée)
  affiche la couverture directement dans l'éditeur à partir des rapports `lcov`/`coverage.xml`.
