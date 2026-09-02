# Initialise un projet Go dans ce template
$ErrorActionPreference = "Stop"

if (-not (Test-Path "go.mod")) {
    Write-Host "==> Initialisation du module Go" -ForegroundColor Cyan
    go mod init app
}

Write-Host "Terminé. Pensez à décommenter le bloc Go dans .pre-commit-config.yaml" -ForegroundColor Green
