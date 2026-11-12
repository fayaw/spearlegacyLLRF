# Scripts

Node scripts that support the LaTeX documents. There is no Python on this
machine's toolchain; do not introduce a dependency on one without saying so
here.

## Doc W generator

[docw-gen.js](docw-gen.js) builds the tables of Doc W (station wiring
reference) from the data files in `../docW-station-wiring/data/`:

```powershell
node Designs/tex/scripts/docw-gen.js                          # from the repository root
powershell -ExecutionPolicy Bypass -File Designs/tex/build.ps1 -Doc W   # runs it, then builds
```

It reads nine CSV files (RFC 4180, UTF-8, CRLF or LF):

| File | Holds | Table in Doc W |
|---|---|---|
| `drawings.csv` | Every drawing PDF in the drawing folders, with status and errata | `tab:drawings`, `tab:drawing-summary` |
| `errata.csv` | Errors found in the drawings (E1, E2, ...) | `tab:errata` |
| `checks.csv` | Field checks (FC1, FC2, ...) and the open items each replaces | `tab:checks` |
| `devices.csv` | Units by location, with the integration step that brings in or retires each | `tab:units-legacy`, `tab:units-planned` |
| `trunks.csv` | Links between buildings, numbered as in the station overview figure | `tab:trunks` |
| `connections.csv` | Connector pins, with a verification level V0 to V3 | `tab:panel-j2`, `tab:panel-j3` |
| `cables.csv` | Cables, fibers and the B118 junction box, read from both ends | `tab:cable-j15`, `tab:cable-j2`, `tab:fibers`, `tab:jbox` |
| `plcmodules.csv` | The I/O modules of the RF MPS PLC-5 | `tab:plc-modules` |
| `plcio.csv` | Every point of those modules: terminal, signal, far end, cross-connects, EPICS record or program symbol | `tab:plcio-tc`, `tab:plcio-ai`, `tab:plcio-di`, `tab:plcio-do` |

It checks the data and stops (exit code 1) on an error:

- unique identifiers; known statuses; every erratum a drawing names exists, and
  every drawing an erratum names lists it; every PLC-5 point names a known module,
  and the errata and field checks it cites exist;
- every revision keeps its leading zero (`01`, not `1`). A spreadsheet program
  drops it when it saves the file, so edit the CSV files in a text editor;
- every file in the register exists; copies of one drawing are byte-identical,
  unless the notes say "same pages" (compared page by page);
- every drawing PDF in the scanned folders is registered (reported as a warning
  until it is);
- integration steps I0 to I8, verification levels V0 to V3.

It also scans the `body.tex` of Docs 0, C, I, L, M, P and T for each drawing's
number and file name to fill the "Cited in" column, and writes
`../docW-station-wiring/generated/*.tex` plus `stats.tex`, which defines the
counts used in the text (`\WDrawings`, `\WVerified`, ...). Never edit the
generated files; they are kept in git so that the editor's build-on-save works
from a fresh clone.

The numbers in Doc W's station overview figure are drawn by hand in
`../docW-station-wiring/tikz/fig-station-overview.tex`; a change to
`trunks.csv` needs the same change there.

## Doc L release check

From the repository root:

```powershell
& ./Designs/tex/build.ps1 -Doc L -Clean
node Designs/tex/scripts/verify-docL.js
```

[verify-docL.js](verify-docL.js) checks original-source paths, citation and
label integrity, Open Items backlinks, referenced images, the six SNL RCS
head inventories, and all horizontal/vertical overflow diagnostics. Use
`--source-only` while editing, before rebuilding. The checker does not replace
engineering review or the field-verification records listed in Doc L.

