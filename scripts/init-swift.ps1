# Initialise un projet Swift (Swift Package Manager) dans ce template
$ErrorActionPreference = "Stop"

if (-not (Test-Path "Package.swift")) {
    Write-Host "==> Initialisation du package Swift" -ForegroundColor Cyan
    swift package init --type executable --name app
}

Write-Host "Terminé. Pensez à décommenter le bloc swift-format dans .pre-commit-config.yaml" -ForegroundColor Green
