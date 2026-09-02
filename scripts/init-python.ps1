# Initialise un projet Python dans ce template (venv + outillage de base)
$ErrorActionPreference = "Stop"

Write-Host "==> Création de l'environnement virtuel (.venv)" -ForegroundColor Cyan
python -m venv .venv

Write-Host "==> Activation de l'environnement virtuel" -ForegroundColor Cyan
& .\.venv\Scripts\Activate.ps1

Write-Host "==> Installation des dépendances de développement" -ForegroundColor Cyan
python -m pip install --upgrade pip
pip install pytest pytest-cov ruff pre-commit

if (-not (Test-Path "requirements.txt")) {
    New-Item -ItemType File -Path "requirements.txt" | Out-Null
}
"pytest`npytest-cov`nruff`npre-commit" | Out-File -Encoding utf8 requirements-dev.txt

if (-not (Test-Path "pyproject.toml")) {
    @"
[tool.ruff]
line-length = 100

[tool.pytest.ini_options]
testpaths = ["tests"]
"@ | Out-File -Encoding utf8 pyproject.toml
}

Write-Host "==> Activation du hook pre-commit" -ForegroundColor Cyan
pre-commit install

Write-Host "Terminé. Pensez à décommenter le bloc Python dans .pre-commit-config.yaml" -ForegroundColor Green
