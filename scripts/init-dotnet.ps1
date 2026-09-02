# Initialise un projet C# / .NET dans ce template
$ErrorActionPreference = "Stop"

if (-not (Get-ChildItem -Filter "*.csproj" -ErrorAction SilentlyContinue)) {
    Write-Host "==> Création du projet .NET (console)" -ForegroundColor Cyan
    dotnet new console -n app -o .
    dotnet new xunit -n app.Tests -o tests
}

Write-Host "==> Restauration des dépendances" -ForegroundColor Cyan
dotnet restore

Write-Host "Terminé. Pensez à décommenter le bloc dotnet-format dans .pre-commit-config.yaml" -ForegroundColor Green
