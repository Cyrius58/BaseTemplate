# Initialise un projet Rust (Cargo) dans ce template
$ErrorActionPreference = "Stop"

if (-not (Test-Path "Cargo.toml")) {
    Write-Host "==> Initialisation du projet Cargo" -ForegroundColor Cyan
    cargo init --name app .
}

Write-Host "Terminé. Pensez à décommenter le bloc cargo-fmt dans .pre-commit-config.yaml" -ForegroundColor Green
