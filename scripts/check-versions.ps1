# Vérifie les versions installées des langages/outils par rapport à .tool-versions
# Ne bloque jamais : affiche un rapport (OK / à mettre à jour / non installé).
$ErrorActionPreference = "Continue"

$toolVersionsPath = Join-Path (Join-Path $PSScriptRoot "..") ".tool-versions"
if (-not (Test-Path $toolVersionsPath)) {
    Write-Host "Fichier .tool-versions introuvable." -ForegroundColor Yellow
    exit 0
}

# Le terminal intégré peut conserver un PATH ancien après l'installation d'un outil.
try {
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}
catch {
    Write-Host "Impossible de recharger le PATH Windows ; utilisation du PATH courant." -ForegroundColor DarkYellow
}

# Commande de version + regex d'extraction par outil
$checks = @{
    "python" = @{ cmd = "python --version"; regex = "(\d+\.\d+)" }
    "node"   = @{ cmd = "node --version"; regex = "v(\d+)" }
    "java"   = @{ cmd = "java -version"; regex = '"(\d+)' }
    "dotnet" = @{ cmd = "dotnet --version"; regex = "(\d+\.\d+)" }
    "go"     = @{ cmd = "go version"; regex = "go(\d+\.\d+)" }
    "rust"   = @{ cmd = "rustc --version"; regex = "(\d+\.\d+)" }
    "php"    = @{ cmd = "php --version"; regex = "(\d+\.\d+)" }
    "ruby"   = @{ cmd = "ruby --version"; regex = "(\d+\.\d+)" }
    "swift"  = @{ cmd = "swift --version"; regex = "(\d+\.\d+)" }
    "kotlin" = @{ cmd = "kotlinc -version"; regex = "(\d+\.\d+)" }
    "dart"   = @{ cmd = "dart --version"; regex = "(\d+\.\d+)" }
}

Write-Host "==> Vérification des versions (référence : .tool-versions)`n" -ForegroundColor Cyan

Get-Content $toolVersionsPath | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }

    $parts = $line -split "\s+"
    $tool = $parts[0]
    $expected = $parts[1]

    if (-not $checks.ContainsKey($tool)) { return }
    $check = $checks[$tool]

    $cmdParts = $check.cmd -split " "
    $command = Get-Command $cmdParts[0] -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        Write-Host ("  [NON INSTALLE] {0,-8} (commande '{1}' introuvable)" -f $tool, $check.cmd) -ForegroundColor DarkGray
        return
    }

    try {
        $arguments = @()
        if ($cmdParts.Length -gt 1) { $arguments = $cmdParts[1..($cmdParts.Length - 1)] }
        $output = & $command.Source $arguments 2>&1 | Out-String
        if ($output -match $check.regex) {
            $installed = $Matches[1]
            $installedVersionText = $installed -replace "[^0-9.]", ""
            $expectedVersionText = $expected -replace "[^0-9.]", ""
            if ($installedVersionText -notmatch "\.") { $installedVersionText += ".0" }
            if ($expectedVersionText -notmatch "\.") { $expectedVersionText += ".0" }
            $installedVersion = [version]$installedVersionText
            $expectedVersion = [version]$expectedVersionText

            if ($installedVersion -lt $expectedVersion) {
                Write-Host ("  [OBSOLETE]  {0,-8} attendu={1,-8} installé={2}" -f $tool, $expected, $installed) -ForegroundColor Yellow
            }
            elseif ($installedVersion -gt $expectedVersion) {
                Write-Host ("  [PLUS RECENTE] {0,-8} cible={1,-8} installé={2}" -f $tool, $expected, $installed) -ForegroundColor Cyan
            }
            else {
                Write-Host ("  [OK]        {0,-8} attendu={1,-8} installé={2}" -f $tool, $expected, $installed) -ForegroundColor Green
            }
        }
        else {
            Write-Host ("  [?]         {0,-8} version non détectée" -f $tool) -ForegroundColor DarkYellow
        }
    }
    catch {
        Write-Host ("  [ERREUR]      {0,-8} version illisible : {1}" -f $tool, $_.Exception.Message) -ForegroundColor Red
    }
}

Write-Host "`nEn cas de version obsolète : lancez scripts/update-tooling.ps1 puis scripts/migrate-code.ps1." -ForegroundColor Cyan
