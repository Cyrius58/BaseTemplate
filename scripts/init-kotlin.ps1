# Initialise un projet Kotlin (Gradle) dans ce template
$ErrorActionPreference = "Stop"

if (-not (Test-Path "build.gradle.kts")) {
    Write-Host "==> Initialisation du projet Gradle (Kotlin)" -ForegroundColor Cyan
    gradle init --type kotlin-application --dsl kotlin --test-framework kotlintest --project-name app --package com.example.app --no-interactive
}

Write-Host "Terminé. Adaptez build.gradle.kts selon vos besoins." -ForegroundColor Green
