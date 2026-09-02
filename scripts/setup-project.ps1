<#
  DÃ©tecte le(s) langage(s) principal(aux) du projet dÃ©rivÃ© de ce template, demande confirmation,
  puis Ã©pure le template (scripts, .vscode/*, .gitignore, pre-commit, CI, Dev Container) pour ne
  garder que ce qui concerne le(s) langage(s) confirmÃ©(s).

  Usage :
    scripts/setup-project.ps1               # dÃ©tection interactive + Ã©puration
    scripts/setup-project.ps1 -DryRun        # affiche ce qui serait fait, sans rien modifier
    scripts/setup-project.ps1 -Force         # ignore la vÃ©rification "dÃ©pÃ´t git versionnÃ©"

  SÃ©curitÃ© : par dÃ©faut, le script refuse de s'exÃ©cuter si le dossier n'est pas un dÃ©pÃ´t git
  avec au moins un commit, afin que l'Ã©puration reste rÃ©versible via git.
#>
param(
    [switch]$DryRun,
    [switch]$Force
)
$ErrorActionPreference = "Stop"
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { } # affichage correct des accents
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

# ==============================================================================================
# 0. Garde-fou : le dossier doit Ãªtre versionnÃ© (sauf -Force) pour garantir la rÃ©versibilitÃ©
# ==============================================================================================
if (-not $Force) {
    $isGitRepo = (Test-Path ".git") -and ((git rev-parse --is-inside-work-tree 2>$null) -eq "true")
    $hasCommit = $false
    if ($isGitRepo) {
        git rev-parse HEAD *> $null
        $hasCommit = ($LASTEXITCODE -eq 0)
    }
    if (-not $isGitRepo -or -not $hasCommit) {
        Write-Host "Ce dossier n'est pas encore un dÃ©pÃ´t git avec un commit." -ForegroundColor Red
        Write-Host "L'Ã©puration supprime des fichiers : faites d'abord un commit pour rester en sÃ©curitÃ© :" -ForegroundColor Yellow
        Write-Host "    git init; git add -A; git commit -m `"chore: Ã©tat initial du template`"" -ForegroundColor Yellow
        Write-Host "(ou relancez avec -Force pour ignorer cette vÃ©rification)" -ForegroundColor Yellow
        exit 1
    }
}

# ==============================================================================================
# 1. RÃ©fÃ©rentiel des langages connus du template
# ==============================================================================================
$Languages = [ordered]@{
    python = @{ label = "Python" }
    node   = @{ label = "Node.js / JavaScript / TypeScript" }
    web    = @{ label = "Web (HTML/CSS statique)" }
    java   = @{ label = "Java" }
    kotlin = @{ label = "Kotlin" }
    dotnet = @{ label = "C# / .NET" }
    go     = @{ label = "Go" }
    rust   = @{ label = "Rust" }
    php    = @{ label = "PHP" }
    ruby   = @{ label = "Ruby" }
    dart   = @{ label = "Dart / Flutter" }
    cpp    = @{ label = "C / C++" }
    swift  = @{ label = "Swift" }
}

$MarkerFiles = @{
    python = @("requirements.txt", "requirements-dev.txt", "pyproject.toml", "Pipfile", "setup.py")
    node   = @("package.json")
    web    = @("index.html")
    java   = @("pom.xml", "build.gradle")
    kotlin = @("build.gradle.kts")
    go     = @("go.mod")
    rust   = @("Cargo.toml")
    php    = @("composer.json")
    ruby   = @("Gemfile")
    dart   = @("pubspec.yaml")
    cpp    = @("CMakeLists.txt")
    swift  = @("Package.swift")
}
$MarkerGlobs = @{
    dotnet = @("*.csproj", "*.sln")
}

$ExtensionsByLang = @{
    python = @(".py")
    node   = @(".js", ".jsx", ".ts", ".tsx")
    web    = @(".html", ".css")
    java   = @(".java")
    kotlin = @(".kt", ".kts")
    dotnet = @(".cs")
    go     = @(".go")
    rust   = @(".rs")
    php    = @(".php")
    ruby   = @(".rb")
    dart   = @(".dart")
    cpp    = @(".cpp", ".cc", ".cxx", ".h", ".hpp", ".c")
    swift  = @(".swift")
}

$ExcludeDirPattern = '\\(\.git|node_modules|\.venv|venv|dist|build|target|bin|obj|\.dart_tool|vendor|\.gradle|\.pub-cache|out|CMakeFiles)(\\|$)'

# ==============================================================================================
# 2. DÃ©tection : scores par fichiers marqueurs (poids fort) + comptage d'extensions (secondaire)
# ==============================================================================================
function Get-LanguageScores {
    $scores = @{}
    foreach ($key in $Languages.Keys) { $scores[$key] = 0 }

    foreach ($key in $MarkerFiles.Keys) {
        foreach ($f in $MarkerFiles[$key]) {
            if (Test-Path $f) { $scores[$key] += 1000 }
        }
    }
    foreach ($key in $MarkerGlobs.Keys) {
        foreach ($pattern in $MarkerGlobs[$key]) {
            if (Get-ChildItem -Path . -Filter $pattern -Recurse -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -notmatch $ExcludeDirPattern } | Select-Object -First 1) {
                $scores[$key] += 1000
            }
        }
    }

    $allFiles = Get-ChildItem -Path . -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch $ExcludeDirPattern }
    foreach ($key in $ExtensionsByLang.Keys) {
        $count = ($allFiles | Where-Object { $ExtensionsByLang[$key] -contains $_.Extension.ToLower() } | Measure-Object).Count
        $scores[$key] += $count
    }
    return $scores
}

# ==============================================================================================
# 3. Boucle de confirmation interactive
# ==============================================================================================
$scores = Get-LanguageScores
$candidates = $scores.GetEnumerator() | Where-Object { $_.Value -gt 0 } | Sort-Object Value -Descending

$confirmed = $null
while ($candidates -and $candidates.Count -gt 0) {
    $maxScore = $candidates[0].Value
    $group = @($candidates | Where-Object { $_.Value -ge ($maxScore * 0.6) })
    $remaining = @($candidates | Where-Object { $group.Key -notcontains $_.Key })

    $labels = ($group | ForEach-Object { $Languages[$_.Key].label }) -join ", "
    if ($group.Count -eq 1) {
        Write-Host "`nLe template dÃ©tecte que le langage principal de ce projet est : $labels" -ForegroundColor Cyan
    }
    else {
        Write-Host "`nLe template dÃ©tecte que ce projet est multi-langage : $labels" -ForegroundColor Cyan
    }
    $resp = Read-Host "Confirmez-vous ? (o/n)"

    if ($resp -match '^(o|oui|y|yes)$') {
        $confirmed = @($group | ForEach-Object { $_.Key })
        break
    }
    Write-Host "OK, ignorÃ©. Recherche d'un autre candidat..." -ForegroundColor DarkGray
    $candidates = $remaining
}

if (-not $confirmed) {
    Write-Host "`nAucun langage confirmÃ©. Aucune modification effectuÃ©e." -ForegroundColor Yellow
    exit 0
}

$confirmedLabels = ($confirmed | ForEach-Object { $Languages[$_].label }) -join ", "
Write-Host "`n==> Ã‰puration du template pour : $confirmedLabels" -ForegroundColor Green
if ($DryRun) { Write-Host "(mode -DryRun : aucune Ã©criture ne sera effectuÃ©e)" -ForegroundColor Yellow }

# ==============================================================================================
# 4. Fonctions d'Ã©puration
# ==============================================================================================
function Write-File($path, $content) {
    if ($DryRun) { Write-Host "  [DryRun] Ã©crirait : $path" -ForegroundColor DarkGray; return }
    Set-Content -Path $path -Value $content -Encoding utf8 -NoNewline
}
function Remove-FileIfExists($path) {
    if (-not (Test-Path $path)) { return }
    if ($DryRun) { Write-Host "  [DryRun] supprimerait : $path" -ForegroundColor DarkGray; return }
    Remove-Item $path -Force
    Write-Host "  SupprimÃ© : $path" -ForegroundColor DarkGray
}

# Supprime les blocs dÃ©limitÃ©s par des lignes d'en-tÃªte "# ---- Titre ----" / "// ==== Titre ===="
# non couverts par $Keep (dÃ©terminÃ© via $KeyOf). Les lignes hors bloc sont toujours conservÃ©es.
function Remove-MarkedBlocks($lines, [regex]$headerRegex, [scriptblock]$keyOf, $keep) {
    $result = New-Object System.Collections.Generic.List[string]
    $i = 0; $n = $lines.Count
    while ($i -lt $n) {
        $line = $lines[$i]
        $m = $headerRegex.Match($line)
        if ($m.Success) {
            $title = $m.Groups[1].Value.Trim()
            $key = & $keyOf $title
            $j = $i + 1
            while ($j -lt $n -and -not $headerRegex.IsMatch($lines[$j])) { $j++ }
            if ($null -eq $key -or $keep -contains $key) {
                for ($k = $i; $k -lt $j; $k++) { $result.Add($lines[$k]) }
            }
            $i = $j
        }
        else {
            $result.Add($line); $i++
        }
    }
    return $result
}

# ---- scripts/init-*.ps1 : ne garder que ceux du/des langage(s) confirmÃ©(s) ----
function Update-InitScripts($keep) {
    $map = @{
        python = "init-python.ps1"; node = "init-node.ps1"; java = "init-java.ps1"
        dotnet = "init-dotnet.ps1"; go = "init-go.ps1"; rust = "init-rust.ps1"
        php = "init-php.ps1"; ruby = "init-ruby.ps1"; dart = "init-dart.ps1"
        cpp = "init-cpp.ps1"; swift = "init-swift.ps1"; kotlin = "init-kotlin.ps1"
    }
    foreach ($kv in $map.GetEnumerator()) {
        if ($keep -notcontains $kv.Key) { Remove-FileIfExists "scripts/$($kv.Value)" }
    }
}

# ---- .vscode/extensions.json ----
function Update-Extensions($keep) {
    $general = @(
        "editorconfig.editorconfig", "eamodio.gitlens", "streetsidesoftware.code-spell-checker",
        "usernamehw.errorlens", "yzhang.markdown-all-in-one", "ryanluker.vscode-coverage-gutters"
    )
    $byLang = @{
        python = @("ms-python.python", "ms-python.vscode-pylance", "ms-python.debugpy", "charliermarsh.ruff")
        node   = @("dbaeumer.vscode-eslint", "esbenp.prettier-vscode", "vitest.explorer", "orta.vscode-jest")
        web    = @("esbenp.prettier-vscode", "ritwickdey.liveserver")
        cpp    = @("ms-vscode.cpptools-extension-pack", "ms-vscode.cmake-tools", "matepek.vscode-catch2-test-adapter")
        dart   = @("dart-code.dart-code", "dart-code.flutter")
        java   = @("vscjava.vscode-java-pack", "redhat.java", "vscjava.vscode-java-test", "vscjava.vscode-java-debug", "vscjava.vscode-maven", "vscjava.vscode-gradle")
        kotlin = @("fwcd.kotlin")
        dotnet = @("ms-dotnettools.csdevkit", "ms-dotnettools.csharp")
        go     = @("golang.go")
        rust   = @("rust-lang.rust-analyzer", "vadimcn.vscode-lldb")
        php    = @("bmewburn.vscode-intelephense-client", "xdebug.php-debug")
        ruby   = @("shopify.ruby-lsp")
        swift  = @("swiftlang.swift-vscode")
    }
    $ids = New-Object System.Collections.Generic.List[string]
    $ids.AddRange([string[]]$general)
    foreach ($k in $keep) { if ($byLang.ContainsKey($k)) { $ids.AddRange([string[]]$byLang[$k]) } }
    $ids.Add("ms-azuretools.vscode-docker")
    $unique = [System.Collections.Generic.List[string]]::new()
    foreach ($id in $ids) { if (-not $unique.Contains($id)) { $unique.Add($id) } }

    $obj = [ordered]@{ recommendations = $unique }
    $json = "// Extensions recommandees - epurees par scripts/setup-project.ps1 pour : $confirmedLabels`n"
    $json += ($obj | ConvertTo-Json -Depth 5)
    Write-File ".vscode/extensions.json" $json
}

# ---- .vscode/launch.json ----
function Update-Launch($keep) {
    $all = @(
        @{ key = "python"; cfg = [ordered]@{ name = "Python: Fichier courant"; type = "debugpy"; request = "launch"; program = '${file}'; console = "integratedTerminal"; justMyCode = $true } }
        @{ key = "python"; cfg = [ordered]@{ name = "Python: Module (src)"; type = "debugpy"; request = "launch"; module = "src"; console = "integratedTerminal"; justMyCode = $true } }
        @{ key = "node"; cfg = [ordered]@{ name = "Node.js: Fichier courant"; type = "node"; request = "launch"; program = '${file}'; console = "integratedTerminal"; skipFiles = @("<node_internals>/**") } }
        @{ key = "node"; cfg = [ordered]@{ name = "Node.js: npm start"; type = "node"; request = "launch"; runtimeExecutable = "npm"; runtimeArgs = @("run", "start"); console = "integratedTerminal" } }
        @{ key = "cpp"; cfg = [ordered]@{ name = "C++ (gdb): Lancer"; type = "cppdbg"; request = "launch"; program = '${workspaceFolder}/build/app'; args = @(); stopAtEntry = $false; cwd = '${workspaceFolder}'; environment = @(); externalConsole = $false; MIMode = "gdb"; preLaunchTask = "cpp: build (cmake)" } }
        @{ key = "dart"; cfg = [ordered]@{ name = "Dart/Flutter: Lancer"; type = "dart"; request = "launch"; program = "lib/main.dart" } }
        @{ key = "web"; cfg = [ordered]@{ name = "Chrome: Lancer page web"; type = "chrome"; request = "launch"; url = "http://localhost:5500"; webRoot = '${workspaceFolder}/src' } }
        @{ key = "java"; cfg = [ordered]@{ name = "Java: Lancer"; type = "java"; request = "launch"; mainClass = '${file}' } }
        @{ key = "dotnet"; cfg = [ordered]@{ name = "C# (.NET): Lancer"; type = "coreclr"; request = "launch"; program = '${workspaceFolder}/bin/Debug/net8.0/app.dll'; args = @(); cwd = '${workspaceFolder}'; console = "integratedTerminal"; preLaunchTask = "dotnet: build" } }
        @{ key = "go"; cfg = [ordered]@{ name = "Go: Lancer"; type = "go"; request = "launch"; mode = "auto"; program = '${workspaceFolder}' } }
        @{ key = "rust"; cfg = [ordered]@{ name = "Rust (lldb): Lancer"; type = "lldb"; request = "launch"; program = '${workspaceFolder}/target/debug/app'; args = @(); cwd = '${workspaceFolder}'; preLaunchTask = "rust: build (cargo)" } }
        @{ key = "php"; cfg = [ordered]@{ name = "PHP: Ã‰couter Xdebug"; type = "php"; request = "launch"; port = 9003 } }
        @{ key = "ruby"; cfg = [ordered]@{ name = "Ruby: Lancer"; type = "rdbg"; request = "launch"; script = '${file}'; askParameters = $false } }
        @{ key = "kotlin"; cfg = [ordered]@{ name = "Kotlin: Lancer"; type = "java"; request = "launch"; mainClass = "MainKt" } }
        @{ key = "swift"; cfg = [ordered]@{ name = "Swift: Lancer"; type = "swift"; request = "launch"; program = '${workspaceFolder}/.build/debug/app'; args = @(); cwd = '${workspaceFolder}' } }
    )
    $kept = @($all | Where-Object { $keep -contains $_.key } | ForEach-Object { $_.cfg })
    $obj = [ordered]@{ version = "0.2.0"; configurations = $kept }
    $json = "// Configurations de debogage - epurees par scripts/setup-project.ps1 pour : $confirmedLabels`n"
    $json += ($obj | ConvertTo-Json -Depth 8)
    Write-File ".vscode/launch.json" $json
}

# ---- .vscode/tasks.json ----
function Update-Tasks($keep) {
    $alwaysKeep = @(
        [ordered]@{ label = "versions: vérifier"; type = "shell"; command = "powershell"; args = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", '${workspaceFolder}/scripts/check-versions.ps1'); problemMatcher = @(); presentation = [ordered]@{ reveal = "silent"; panel = "dedicated" }; runOptions = [ordered]@{ runOn = "folderOpen" } }
        [ordered]@{ label = "versions: mettre à jour les outils"; type = "shell"; command = "powershell"; args = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", '${workspaceFolder}/scripts/update-tooling.ps1'); problemMatcher = @() }
        [ordered]@{ label = "versions: migrer le code (codemods)"; type = "shell"; command = "powershell"; args = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", '${workspaceFolder}/scripts/migrate-code.ps1'); problemMatcher = @() }
    )
    $byLang = @{
        python = @(
            [ordered]@{ label = "python: test (pytest)"; type = "shell"; command = "pytest"; args = @("-v"); group = [ordered]@{ kind = "test"; isDefault = $true }; problemMatcher = @() }
            [ordered]@{ label = "python: install deps"; type = "shell"; command = "pip install -r requirements-dev.txt"; problemMatcher = @() }
        )
        node   = @(
            [ordered]@{ label = "node: install deps"; type = "shell"; command = "npm install"; problemMatcher = @() }
            [ordered]@{ label = "node: test"; type = "shell"; command = "npm test"; group = "test"; problemMatcher = @() }
            [ordered]@{ label = "node: build"; type = "shell"; command = "npm run build"; group = "build"; problemMatcher = @() }
        )
        cpp    = @(
            [ordered]@{ label = "cpp: configure (cmake)"; type = "shell"; command = "cmake -S . -B build"; problemMatcher = @() }
            [ordered]@{ label = "cpp: build (cmake)"; type = "shell"; command = "cmake --build build"; group = [ordered]@{ kind = "build"; isDefault = $true }; problemMatcher = @('$gcc') }
            [ordered]@{ label = "cpp: test (ctest)"; type = "shell"; command = "ctest --test-dir build --output-on-failure"; group = "test"; problemMatcher = @() }
        )
        dart   = @( [ordered]@{ label = "dart: test"; type = "shell"; command = "dart test"; group = "test"; problemMatcher = @() } )
        java   = @(
            [ordered]@{ label = "java: build (maven)"; type = "shell"; command = "mvn -q compile"; group = [ordered]@{ kind = "build"; isDefault = $true }; problemMatcher = @() }
            [ordered]@{ label = "java: test (maven)"; type = "shell"; command = "mvn -q test"; group = "test"; problemMatcher = @() }
        )
        dotnet = @(
            [ordered]@{ label = "dotnet: build"; type = "shell"; command = "dotnet build"; group = [ordered]@{ kind = "build"; isDefault = $true }; problemMatcher = @('$msCompile') }
            [ordered]@{ label = "dotnet: test"; type = "shell"; command = "dotnet test"; group = "test"; problemMatcher = @() }
        )
        go     = @(
            [ordered]@{ label = "go: build"; type = "shell"; command = "go build ./..."; group = [ordered]@{ kind = "build"; isDefault = $true }; problemMatcher = @() }
            [ordered]@{ label = "go: test"; type = "shell"; command = "go test ./..."; group = "test"; problemMatcher = @() }
        )
        rust   = @(
            [ordered]@{ label = "rust: build (cargo)"; type = "shell"; command = "cargo build"; group = [ordered]@{ kind = "build"; isDefault = $true }; problemMatcher = @('$rustc') }
            [ordered]@{ label = "rust: test (cargo)"; type = "shell"; command = "cargo test"; group = "test"; problemMatcher = @() }
        )
        php    = @(
            [ordered]@{ label = "php: install deps (composer)"; type = "shell"; command = "composer install"; problemMatcher = @() }
            [ordered]@{ label = "php: test (phpunit)"; type = "shell"; command = "vendor/bin/phpunit"; group = "test"; problemMatcher = @() }
        )
        ruby   = @(
            [ordered]@{ label = "ruby: install deps (bundler)"; type = "shell"; command = "bundle install"; problemMatcher = @() }
            [ordered]@{ label = "ruby: test (rspec)"; type = "shell"; command = "bundle exec rspec"; group = "test"; problemMatcher = @() }
        )
        swift  = @(
            [ordered]@{ label = "swift: build"; type = "shell"; command = "swift build"; group = [ordered]@{ kind = "build"; isDefault = $true }; problemMatcher = @() }
            [ordered]@{ label = "swift: test"; type = "shell"; command = "swift test"; group = "test"; problemMatcher = @() }
        )
    }
    $tasks = New-Object System.Collections.Generic.List[object]
    $tasks.AddRange([object[]]$alwaysKeep)
    foreach ($k in $keep) { if ($byLang.ContainsKey($k)) { $tasks.AddRange([object[]]$byLang[$k]) } }
    $tasks.Add([ordered]@{ label = "pre-commit: lancer sur tous les fichiers"; type = "shell"; command = "pre-commit run --all-files"; problemMatcher = @() })

    $obj = [ordered]@{ version = "2.0.0"; tasks = $tasks }
    $json = "// Taches VSCode - epurees par scripts/setup-project.ps1 pour : $confirmedLabels`n"
    $json += ($obj | ConvertTo-Json -Depth 8)
    Write-File ".vscode/tasks.json" $json
}

# ---- .vscode/settings.json, .gitignore, .pre-commit-config.yaml, ci.yml : suppression par blocs ----
function Update-TextBlocks($path, [regex]$headerRegex, $titleToKey, $keep) {
    if (-not (Test-Path $path)) { return }
    $lines = Get-Content $path
    $keyOf = { param($title) return $titleToKey[$title] }
    $result = Remove-MarkedBlocks $lines $headerRegex $keyOf $keep
    Write-File $path (($result -join "`n") + "`n")
}

function Update-Settings($keep) {
    $titleToKey = @{
        "Python" = "python"; "JavaScript / TypeScript" = "node"; "C / C++" = "cpp"; "Dart" = "dart"
        "Java" = "java"; "C# / .NET" = "dotnet"; "Go" = "go"; "Rust" = "rust"; "PHP" = "php"
        "Ruby" = "ruby"; "Kotlin" = "kotlin"
        "Formatage / qualitÃ© de code automatique Ã  l'enregistrement" = $null
        "Fichiers/dossiers masquÃ©s dans l'explorateur" = $null
    }
    Update-TextBlocks ".vscode/settings.json" '^\s*//\s*====\s*(.+?)\s*====\s*$' $titleToKey $keep
}

function Update-Gitignore($keep) {
    $titleToKey = @{
        "GÃ©nÃ©ral / OS" = $null; "VSCode (garder la config partagÃ©e, ignorer le local)" = $null
        "Rapports de tests / couverture" = $null
        "Python" = "python"; "Node / Web" = "node"; "C / C++" = "cpp"; "Dart / Flutter" = "dart"
        "Java / Kotlin (Maven / Gradle)" = "java"; "C# / .NET" = "dotnet"; "Go" = "go"
        "Rust" = "rust"; "PHP" = "php"; "Ruby" = "ruby"; "Swift" = "swift"
    }
    # "Node / Web" et "Java / Kotlin" doivent rester si node/web ou java/kotlin est gardÃ©
    if ($keep -contains "web" -and $keep -notcontains "node") { $keep = $keep + "node" }
    if ($keep -contains "kotlin" -and $keep -notcontains "java") { $keep = $keep + "java" }
    Update-TextBlocks ".gitignore" '^#\s*====\s*(.+?)\s*====\s*$' $titleToKey $keep
}

function Update-PreCommit($keep) {
    $titleToKey = @{
        "Hooks gÃ©nÃ©riques (toujours actifs)" = $null; "DÃ©tection de secrets (toujours actif)" = $null
        "Validation du message de commit (Conventional Commits)" = $null
        "Python" = "python"; "JavaScript / TypeScript" = "node"; "C / C++" = "cpp"; "Dart" = "dart"
        "Java / Kotlin" = "java"; "C# / .NET" = "dotnet"; "Go" = "go"; "Rust" = "rust"
        "PHP" = "php"; "Ruby" = "ruby"; "Swift" = "swift"
    }
    if ($keep -contains "kotlin" -and $keep -notcontains "java") { $keep = $keep + "java" }
    if (-not (Test-Path ".pre-commit-config.yaml")) { return }
    $lines = Get-Content ".pre-commit-config.yaml"
    $headerRegex = [regex]'^\s*#\s*----\s*(.+?)\s*----\s*$'
    $keyOf = { param($title) return $titleToKey[$title] }
    $result = Remove-MarkedBlocks $lines $headerRegex $keyOf $keep

    # DÃ©commente le(s) bloc(s) du/des langage(s) confirmÃ©(s) (hors les 3 blocs toujours actifs)
    $langTitles = @{
        python = "Python"; node = "JavaScript / TypeScript"; cpp = "C / C++"; dart = "Dart"
        java = "Java / Kotlin"; dotnet = "C# / .NET"; go = "Go"; rust = "Rust"
        php = "PHP"; ruby = "Ruby"; swift = "Swift"
    }
    $out = New-Object System.Collections.Generic.List[string]
    $inTargetBlock = $false
    foreach ($line in $result) {
        if ($line -match '^\s*#\s*----\s*(.+?)\s*----\s*$') {
            $title = $Matches[1].Trim()
            $inTargetBlock = ($langTitles.Values -contains $title) -and ($keep -contains ($langTitles.GetEnumerator() | Where-Object { $_.Value -eq $title } | Select-Object -First 1 -ExpandProperty Key))
            $out.Add($line)
            continue
        }
        if ($inTargetBlock -and $line -match '^(\s*)#\s?(.*)$') {
            $out.Add($Matches[1] + $Matches[2])
        }
        else {
            $out.Add($line)
        }
    }
    Write-File ".pre-commit-config.yaml" (($out -join "`n") + "`n")
}

function Update-Ci($keep) {
    if ($keep -contains "web" -and $keep -notcontains "node") { $keep = $keep + "node" }
    $titleToKey = @{
        "Python" = "python"; "Node / Web" = "node"; "Java" = "java"; "C# / .NET" = "dotnet"
        "Go" = "go"; "Rust" = "rust"; "PHP" = "php"; "Ruby" = "ruby"; "Dart / Flutter" = "dart"
        "C / C++" = "cpp"
    }
    Update-TextBlocks ".github/workflows/ci.yml" '^\s*#\s*----\s*(.+?)\s*----\s*$' $titleToKey $keep
}

function Update-CodeQL($keep) {
    $map = @{ python = "python"; node = "javascript-typescript"; java = "java-kotlin"; kotlin = "java-kotlin"; dotnet = "csharp"; go = "go"; cpp = "cpp"; ruby = "ruby"; swift = "swift" }
    $kept = [System.Collections.Generic.List[string]]::new()
    foreach ($k in $keep) { if ($map.ContainsKey($k) -and -not $kept.Contains($map[$k])) { $kept.Add($map[$k]) } }
    if ($kept.Count -eq 0) {
        Remove-FileIfExists ".github/workflows/codeql.yml"
        Write-Host "  (CodeQL ne supporte aucun des langages confirmÃ©s : workflow supprimÃ©)" -ForegroundColor DarkGray
        return
    }
    if (-not (Test-Path ".github/workflows/codeql.yml")) { return }
    $content = Get-Content ".github/workflows/codeql.yml" -Raw
    $list = ($kept | ForEach-Object { "            `"$_`"," }) -join "`n"
    $list = $list.TrimEnd(",")
    $newContent = $content -replace '(?s)language:\s*\[\s*.*?\s*\]', "language:`n          [`n$list`n          ]"
    Write-File ".github/workflows/codeql.yml" $newContent
}

function Update-DevContainer($keep) {
    $path = ".devcontainer/devcontainer.json"
    if (-not (Test-Path $path)) { return }
    $data = Get-Content $path -Raw | ConvertFrom-Json
    $featureMap = @{
        rust = "ghcr.io/devcontainers/features/rust:1"; php = "ghcr.io/devcontainers/features/php:1"
        dotnet = "ghcr.io/devcontainers/features/dotnet:2"; go = "ghcr.io/devcontainers/features/go:1"
    }
    $features = [ordered]@{}
    foreach ($k in $keep) { if ($featureMap.ContainsKey($k)) { $features[$featureMap[$k]] = @{} } }

    $extMap = @{
        python = @("ms-python.python", "ms-python.vscode-pylance", "charliermarsh.ruff")
        node = @("dbaeumer.vscode-eslint", "esbenp.prettier-vscode")
        web = @("esbenp.prettier-vscode")
        go = @("golang.go"); rust = @("rust-lang.rust-analyzer"); dotnet = @("ms-dotnettools.csharp")
        java = @("vscjava.vscode-java-pack"); php = @("bmewburn.vscode-intelephense-client")
    }
    $exts = [System.Collections.Generic.List[string]]::new()
    $exts.Add("editorconfig.editorconfig")
    foreach ($k in $keep) { if ($extMap.ContainsKey($k)) { foreach ($e in $extMap[$k]) { if (-not $exts.Contains($e)) { $exts.Add($e) } } } }

    $obj = [ordered]@{
        name              = $data.name
        image             = $data.image
        features          = $features
        customizations    = [ordered]@{ vscode = [ordered]@{ extensions = $exts } }
        postCreateCommand = $data.postCreateCommand
    }
    Write-File $path ($obj | ConvertTo-Json -Depth 6)
}

function Add-ChangelogEntry($labels) {
    $path = "CHANGELOG.md"
    if (-not (Test-Path $path)) { return }
    $content = Get-Content $path -Raw
    $date = Get-Date -Format "yyyy-MM-dd"
    $entry = "- Epuration du template ($date) pour le(s) langage(s) : $labels (scripts/setup-project.ps1)`n"
    $newContent = $content -replace '(### ModifiÃ©\r?\n)', "`$1$entry"
    Write-File $path $newContent
}

# ==============================================================================================
# 5. ExÃ©cution
# ==============================================================================================
Update-InitScripts $confirmed
Update-Extensions $confirmed
Update-Launch $confirmed
Update-Tasks $confirmed
Update-Settings $confirmed
Update-Gitignore $confirmed
Update-PreCommit $confirmed
Update-Ci $confirmed
Update-CodeQL $confirmed
Update-DevContainer $confirmed
Add-ChangelogEntry $confirmedLabels

Write-Host "`n==> Ã‰puration terminÃ©e pour : $confirmedLabels" -ForegroundColor Green
Write-Host "VÃ©rifiez le diff (git diff), relisez CHANGELOG.md, puis committez." -ForegroundColor Cyan
