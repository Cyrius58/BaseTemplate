# Initialise un projet Dart / Flutter dans ce template
$ErrorActionPreference = "Stop"

if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "==> Création du projet Dart" -ForegroundColor Cyan
    dart create -t console .
}

Write-Host "==> Récupération des dépendances" -ForegroundColor Cyan
dart pub get

Write-Host "Terminé. Pensez à décommenter le bloc Dart dans .pre-commit-config.yaml" -ForegroundColor Green
