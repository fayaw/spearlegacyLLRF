# Regenerate every data-derived figure into ../figures/generated/.
# Hand-authored TikZ diagrams in ../tikz/ are NOT built here; LaTeX inputs
# those directly.  Doc L currently has no data plots, so this is a no-op --
# it exists so the convention is in place when the first one is added.
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot

$outDir = Join-Path $PSScriptRoot "..\figures\generated"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$figs = Get-ChildItem *.tex -ErrorAction SilentlyContinue
if (-not $figs) { "no generated figures defined yet"; Pop-Location; return }

foreach ($f in $figs) {
    "building $($f.Name)"
    & lualatex -interaction=nonstopmode -output-directory="$outDir" $f.FullName | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "failed: $($f.Name)" }
}
Get-ChildItem $outDir -Include *.aux,*.log -Recurse | Remove-Item -Force
"done -> $outDir"
Pop-Location
