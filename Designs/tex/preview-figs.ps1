param([string]$Only = "*", [string]$Doc = "*")
# Preview every TikZ figure on its own oversized page, then report failures.
# Runs lualatex from each document's own folder so ../common and tikz/ resolve.
$ErrorActionPreference = "Stop"
$fail = @()
foreach ($d in Get-ChildItem $PSScriptRoot -Directory -Filter "doc$Doc") {
    if (-not (Test-Path (Join-Path $d.FullName "tikz"))) { continue }
    Push-Location $d.FullName
    $figs = Get-ChildItem tikz\*.tex | Where-Object { $_.BaseName -like $Only }
    foreach ($f in $figs) {
        $n = $f.BaseName
        $out = & lualatex -interaction=nonstopmode -jobname="preview_$n" "\def\FIG{$n}\input{../common/tikztest}" 2>&1
        $errs = $out | Select-String -Pattern '^! ' | Select-Object -First 3
        $miss = (Select-String -Path "preview_$n.log" -Pattern 'Missing character' -ErrorAction SilentlyContinue).Count
        $over = (Select-String -Path "preview_$n.log" -Pattern 'Overfull \\hbox' -ErrorAction SilentlyContinue).Count
        $ok = Test-Path "preview_$n.pdf"
        $status = if ($errs -or -not $ok) { "FAIL" } elseif ($miss -gt 0) { "GLYPH" } else { "ok" }
        if ($status -ne "ok") { $fail += "$($d.Name)/$n" }
        "{0,-6} {1,-26} {2,-24} missing={3} overfull={4}" -f $status, $d.Name, $n, $miss, $over
        if ($errs) { $errs | ForEach-Object { "        $_" } }
    }
    Pop-Location
}
""
if ($fail) { "FAILED: $($fail -join ', ')" } else { "all figures built cleanly" }
