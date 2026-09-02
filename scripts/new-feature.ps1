# Génère les fichiers Model/View/Controller (+ test) d'une nouvelle fonctionnalité.
# Usage : scripts/new-feature.ps1 -Name Utilisateur -Lang python
param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][ValidateSet("python", "node", "java", "dotnet", "go", "rust", "php", "ruby", "dart", "cpp")][string]$Lang
)
$ErrorActionPreference = "Stop"

$map = @{
    "python" = @{ ext = "py";   model = "{0}_model.py";      view = "{0}_view.py";      controller = "{0}_controller.py";      test = "test_{0}.py" }
    "node"   = @{ ext = "js";   model = "{0}.model.js";      view = "{0}.view.js";      controller = "{0}.controller.js";      test = "{0}.test.js" }
    "java"   = @{ ext = "java"; model = "{0}Model.java";     view = "{0}View.java";     controller = "{0}Controller.java";     test = "{0}Test.java" }
    "dotnet" = @{ ext = "cs";   model = "{0}Model.cs";       view = "{0}View.cs";       controller = "{0}Controller.cs";       test = "{0}Tests.cs" }
    "go"     = @{ ext = "go";   model = "{0}_model.go";      view = "{0}_view.go";      controller = "{0}_controller.go";      test = "{0}_test.go" }
    "rust"   = @{ ext = "rs";   model = "{0}_model.rs";      view = "{0}_view.rs";      controller = "{0}_controller.rs";      test = "{0}_test.rs" }
    "php"    = @{ ext = "php";  model = "{0}Model.php";      view = "{0}View.php";      controller = "{0}Controller.php";      test = "{0}Test.php" }
    "ruby"   = @{ ext = "rb";   model = "{0}_model.rb";      view = "{0}_view.rb";      controller = "{0}_controller.rb";      test = "{0}_spec.rb" }
    "dart"   = @{ ext = "dart"; model = "{0}_model.dart";    view = "{0}_view.dart";    controller = "{0}_controller.dart";    test = "{0}_test.dart" }
    "cpp"    = @{ ext = "cpp";  model = "{0}Model.cpp";      view = "{0}View.cpp";      controller = "{0}Controller.cpp";      test = "{0}Test.cpp" }
}

$slug = $Name.Substring(0, 1).ToLower() + $Name.Substring(1)
$conf = $map[$Lang]

$targets = @(
    @{ dir = "src/model";      file = ($conf.model      -f $slug) }
    @{ dir = "src/view";       file = ($conf.view       -f $slug) }
    @{ dir = "src/controller"; file = ($conf.controller -f $slug) }
    @{ dir = "tests/unit";     file = ($conf.test       -f $slug) }
)

foreach ($t in $targets) {
    $path = Join-Path $t.dir $t.file
    if (Test-Path $path) {
        Write-Host "Déjà existant, ignoré : $path" -ForegroundColor Yellow
        continue
    }
    "// TODO: implémenter $Name (générateur scripts/new-feature.ps1)" | Out-File -Encoding utf8 $path
    Write-Host "Créé : $path" -ForegroundColor Green
}
