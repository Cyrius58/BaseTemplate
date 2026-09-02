# Initialise un projet Ruby (Bundler) dans ce template
$ErrorActionPreference = "Stop"

if (-not (Test-Path "Gemfile")) {
@"
source "https://rubygems.org"

gem "rspec"
gem "rubocop"
"@ | Out-File -Encoding utf8 Gemfile
    Write-Host "==> Gemfile créé" -ForegroundColor Cyan
}

Write-Host "==> Installation des gems" -ForegroundColor Cyan
bundle install

if (-not (Test-Path "spec")) {
    bundle exec rspec --init
}

Write-Host "Terminé. Pensez à décommenter le bloc rubocop dans .pre-commit-config.yaml" -ForegroundColor Green
