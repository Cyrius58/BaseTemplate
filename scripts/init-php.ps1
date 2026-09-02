# Initialise un projet PHP (Composer) dans ce template
$ErrorActionPreference = "Stop"

if (-not (Test-Path "composer.json")) {
    Write-Host "==> Initialisation Composer" -ForegroundColor Cyan
    composer init --no-interaction --name="example/app"
}

Write-Host "==> Installation de PHPUnit" -ForegroundColor Cyan
composer require --dev phpunit/phpunit

Write-Host "Terminé. Pensez à décommenter le bloc php-cs-fixer dans .pre-commit-config.yaml" -ForegroundColor Green
