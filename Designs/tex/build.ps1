param([switch]$Clean, [string]$Doc = "L_legacy_system_architecture")
# Build a SPEAR3 design document to PDF and fail loudly on the errors that
# matter -- in particular any character LuaLaTeX has silently dropped.
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot

if ($Clean) {
    Remove-Item "$Doc.aux","$Doc.log","$Doc.out","$Doc.toc","$Doc.lof","$Doc.pdf" -ErrorAction SilentlyContinue
    Remove-Item preview_*.* -ErrorAction SilentlyContinue
}

# three passes: references, then TOC/LOF, then page numbers.
# --synctex=1 writes the .synctex.gz that lets a PDF viewer jump back to the
# source line (and the editor jump forward to the page).
1..3 | ForEach-Object {
    $null = & lualatex -interaction=nonstopmode --synctex=1 "$Doc.tex" 2>&1
}

$log = Get-Content "$Doc.log" -Raw
$errors  = [regex]::Matches($log, '(?m)^! .*$')      | ForEach-Object { $_.Value } | Select-Object -Unique
$missing = [regex]::Matches($log, 'Missing character: There is no (.) \(U\+([0-9A-F]+)\)')
$undef   = [regex]::Matches($log, '(?m)^LaTeX Warning: (Reference|Citation) .*$') | ForEach-Object { $_.Value }
$overfull = ([regex]::Matches($log, 'Overfull \\hbox \((\d+)')  | ForEach-Object { [int]$_.Groups[1].Value } | Where-Object { $_ -gt 20 })

$pages = if ($log -match 'Output written on .*\((\d+) pages') { $Matches[1] } else { "?" }

"=== $Doc ==="
"pages                : $pages"
"errors               : $($errors.Count)"
"dropped characters   : $($missing.Count)"
"unresolved refs      : $($undef.Count)"
"overfull >20pt       : $($overfull.Count)"

if ($errors)  { ""; "ERRORS:";  $errors  | Select-Object -First 12 | ForEach-Object { "  $_" } }
if ($missing.Count) {
    ""; "DROPPED CHARACTERS (add a \newunicodechar mapping in preamble.tex):"
    $missing | ForEach-Object { "U+$($_.Groups[2].Value) $($_.Groups[1].Value)" } |
        Group-Object | Sort-Object Count -Descending | Select-Object -First 20 |
        ForEach-Object { "  $($_.Count)x  $($_.Name)" }
}
if ($undef) { ""; "UNRESOLVED:"; $undef | Select-Object -First 10 | ForEach-Object { "  $_" } }

Pop-Location
if ($errors -or $missing.Count) { exit 1 }
