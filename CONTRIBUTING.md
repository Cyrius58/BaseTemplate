# Contribuer

## Mise en route

1. Lancez le script `scripts/init-<langage>.ps1` correspondant au langage du projet.
2. Installez les hooks : `pip install pre-commit && pre-commit install`.
3. Ouvrez le dossier dans VSCode et installez les extensions recommandées proposées.

## Convention de commits

Ce projet suit [Conventional Commits](https://www.conventionalcommits.org/fr/) :
`type(scope): description` (ex. `feat(auth): ajoute la connexion OAuth`).
Types courants : `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.

## Avant de proposer une modification

- Ajoutez/mettez à jour les tests unitaires correspondants (`tests/unit`, `tests/integration`).
- Vérifiez que `pre-commit run --all-files` passe.
- Mettez à jour `CHANGELOG.md` dans la section `[Non publié]`.
- Respectez la séparation MVC (`src/model`, `src/view`, `src/controller`).

## Nouvelle fonctionnalité

Utilisez `scripts/new-feature.ps1 -Name <NomFonctionnalite> -Lang <python|node|java|dotnet|go|rust|php|ruby|dart|cpp>`
pour générer les fichiers Model/View/Controller/Test de base.
