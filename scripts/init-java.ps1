# Initialise un projet Java (Maven) dans ce template
$ErrorActionPreference = "Stop"

if (-not (Test-Path "pom.xml")) {
    Write-Host "==> Génération du squelette Maven" -ForegroundColor Cyan
    mvn -q archetype:generate "-DgroupId=com.example.app" "-DartifactId=app" "-DarchetypeArtifactId=maven-archetype-quickstart" "-DinteractiveMode=false"
}

Write-Host "Terminé. Adaptez pom.xml (JUnit, plugins) et décommentez le bloc Java dans .pre-commit-config.yaml" -ForegroundColor Green
