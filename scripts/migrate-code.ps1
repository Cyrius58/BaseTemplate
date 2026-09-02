# Applique les migrations/codemods automatiques officiels quand une version de langage évolue.
# N'agit que sur les langages détectés dans le projet (fichier marqueur présent).
$ErrorActionPreference = "Continue"

if ((Test-Path "requirements-dev.txt") -or (Get-ChildItem -Filter "*.py" -Recurse -ErrorAction SilentlyContinue)) {
    Write-Host "==> Python : pyupgrade + ruff --fix" -ForegroundColor Cyan
    if (Get-Command pyupgrade -ErrorAction SilentlyContinue) {
        Get-ChildItem -Recurse -Filter "*.py" | ForEach-Object { pyupgrade --py312-plus $_.FullName }
    }
    if (Get-Command ruff -ErrorAction SilentlyContinue) { ruff check --fix . }
}

if (Test-Path "package.json") {
    Write-Host "==> Node/JS/TS : eslint --fix" -ForegroundColor Cyan
    npx eslint . --fix
}

if (Test-Path "pubspec.yaml") {
    Write-Host "==> Dart/Flutter : dart fix --apply" -ForegroundColor Cyan
    dart fix --apply
}

if (Get-ChildItem -Filter "*.go" -Recurse -ErrorAction SilentlyContinue) {
    Write-Host "==> Go : go fix" -ForegroundColor Cyan
    go fix ./...
}

if (Test-Path "Cargo.toml") {
    Write-Host "==> Rust : cargo fix (édition/lints)" -ForegroundColor Cyan
    cargo fix --allow-dirty --allow-staged
}

if ((Test-Path "*.csproj") -or (Get-ChildItem -Filter "*.csproj" -Recurse -ErrorAction SilentlyContinue)) {
    Write-Host "==> C# : dotnet format" -ForegroundColor Cyan
    dotnet format
}

if (Test-Path "Gemfile") {
    Write-Host "==> Ruby : rubocop -A (auto-correction)" -ForegroundColor Cyan
    bundle exec rubocop -A
}

if (Test-Path "composer.json") {
    Write-Host "==> PHP : envisagez Rector (https://github.com/rectorphp/rector) pour les migrations de version majeure" -ForegroundColor Cyan
}

Write-Host "`nTerminé. Relisez les diffs générés avant de committer (les codemods peuvent nécessiter une relecture)." -ForegroundColor Green
