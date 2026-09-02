# Met à jour les gestionnaires de version / toolchains + outils de lint-format-precommit
# N'installe que ce qui est présent dans le projet (détection par fichier marqueur).
$ErrorActionPreference = "Continue"

Write-Host "==> Mise à jour des hooks pre-commit" -ForegroundColor Cyan
if (Get-Command pre-commit -ErrorAction SilentlyContinue) { pre-commit autoupdate }

if (Test-Path "requirements-dev.txt") {
    Write-Host "==> Python : mise à jour ruff/pytest" -ForegroundColor Cyan
    pip install --upgrade ruff pytest pytest-cov pre-commit pyupgrade
}

if (Test-Path "package.json") {
    Write-Host "==> Node : mise à jour des dépendances de dev (npm-check-updates recommandé)" -ForegroundColor Cyan
    npm outdated
    Write-Host "    -> npx npm-check-updates -u   puis   npm install" -ForegroundColor DarkGray
}

if (Get-Command rustup -ErrorAction SilentlyContinue) {
    Write-Host "==> Rust : mise à jour du toolchain" -ForegroundColor Cyan
    rustup update
}

if (Get-Command go -ErrorAction SilentlyContinue) {
    Write-Host "==> Go : vérifiez la version sur https://go.dev/dl et mettez à jour go.mod (directive 'go')" -ForegroundColor Cyan
}

if (Test-Path "Gemfile") {
    Write-Host "==> Ruby : mise à jour des gems" -ForegroundColor Cyan
    bundle update
}

if (Test-Path "composer.json") {
    Write-Host "==> PHP : mise à jour des dépendances Composer" -ForegroundColor Cyan
    composer update
}

if (Test-Path "pubspec.yaml") {
    Write-Host "==> Dart : mise à jour des dépendances" -ForegroundColor Cyan
    dart pub upgrade
}

Write-Host "`nTerminé. Mettez ensuite à jour .tool-versions puis lancez scripts/migrate-code.ps1." -ForegroundColor Green
