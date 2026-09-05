param([string]$Only = "*")
# Preview every TikZ figure on its own oversized page, then report failures.
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot
$figs = Get-ChildItem tikz\*.tex | Where-Object { $_.BaseName -like $Only }
$fail = @()
foreach ($f in $figs) {
    $n = $f.BaseName
    $out = & lualatex -interaction=nonstopmode -jobname="preview_$n" "\def\FIG{$n}\input{tikztest}" 2>&1
    $errs = $out | Select-String -Pattern '^! ' | Select-Object -First 3
    $miss = (Select-String -Path "preview_$n.log" -Pattern 'Missing character' -ErrorAction SilentlyContinue).Count
    $over = (Select-String -Path "preview_$n.log" -Pattern 'Overfull \\hbox' -ErrorAction SilentlyContinue).Count
    $ok = Test-Path "preview_$n.pdf"
    $status = if ($errs -or -not $ok) { "FAIL" } elseif ($miss -gt 0) { "GLYPH" } else { "ok" }
    if ($status -ne "ok") { $fail += $n }
    "{0,-6} {1,-24} missing={2} overfull={3}" -f $status, $n, $miss, $over
    if ($errs) { $errs | ForEach-Object { "        $_" } }
}
""
if ($fail) { "FAILED: $($fail -join ', ')" } else { "all figures built cleanly" }
Pop-Location
