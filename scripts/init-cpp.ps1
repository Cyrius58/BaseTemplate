# Initialise un projet C++ (CMake) dans ce template
$ErrorActionPreference = "Stop"

if (-not (Test-Path "CMakeLists.txt")) {
@"
cmake_minimum_required(VERSION 3.20)
project(app)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(app src/main.cpp)

enable_testing()
add_subdirectory(tests)
"@ | Out-File -Encoding utf8 CMakeLists.txt
    Write-Host "==> CMakeLists.txt créé" -ForegroundColor Cyan
}

Write-Host "==> Configuration du projet" -ForegroundColor Cyan
cmake -S . -B build

Write-Host "Terminé. Adaptez CMakeLists.txt et tests/CMakeLists.txt selon vos besoins." -ForegroundColor Green
