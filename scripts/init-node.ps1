# Initialise un projet Node.js / Web dans ce template
$ErrorActionPreference = "Stop"

if (-not (Test-Path "package.json")) {
    Write-Host "==> Initialisation package.json" -ForegroundColor Cyan
    npm init -y
}

Write-Host "==> Installation des outils de développement (eslint, prettier, vitest)" -ForegroundColor Cyan
npm install -D eslint prettier vitest

Write-Host "Terminé. Pensez à décommenter le bloc Prettier/ESLint dans .pre-commit-config.yaml" -ForegroundColor Green
