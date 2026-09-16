# SPEAR3 RF System design documents (LaTeX)

LaTeX is the **single source of truth** for these documents. The Markdown
originals were removed once conversion was verified; their history remains in
git.

| Doc | Folder | Main file |
|---|---|---|
| **Doc 0** — System Design Report (upgrade) | `doc0-system-design/` | `0_system_design_report.tex` |
| **Doc I** — Legacy Interlock Architecture | `docI-interlock-architecture/` | `I_interlock_architecture.tex` |
| **Doc L** — Legacy System Architecture | `docL-legacy-architecture/` | `L_legacy_system_architecture.tex` |
| **Doc P** — RF Physics, Control Theory and Plant | `docP-rf-physics/` | `P_rf_physics_and_plant.tex` |
| **Doc T** — Tuner Control System Analysis | `docT-tuner-control/` | `T_tuner_control_analysis.tex` |

Each document folder holds its own `body.tex` and its own `tikz/`, so figure
names need no document prefix. Everything shared lives in `common/`. A change
to `common/preamble.tex` affects every document — rebuild them all before
committing one.

## Build

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1 -Doc L          # Doc L
powershell -ExecutionPolicy Bypass -File build.ps1 -Doc 0 -Clean   # Doc 0, from scratch
powershell -ExecutionPolicy Bypass -File build.ps1 -Doc I          # Doc I
powershell -ExecutionPolicy Bypass -File build.ps1 -Doc P          # Doc P
powershell -ExecutionPolicy Bypass -File build.ps1 -Doc T          # Doc T
```

## Converting a Markdown document

`scripts/md2tex.js` runs preprocess → pandoc → postprocess in one pass, and
`scripts/verify.js` checks the result against the source (headings, key facts,
equation count, equation tags, table and figure counts):

```powershell
node scripts/md2tex.js P
node scripts/verify.js P
```

Add a document by extending the `DOCS` table at the top of each script. The
converter writes a visible “figure not yet drawn” placeholder for any figure it
has a name for but no `tikz/` file, so a half-finished conversion still builds
and the gaps are obvious.

`build.ps1` runs LuaLaTeX three times and then **fails the build** on any
LaTeX error or any silently dropped character. Read the summary it prints; a
clean build reports zero for both.

Preview a single diagram while working on it:

```powershell
powershell -ExecutionPolicy Bypass -File preview-figs.ps1                       # all, both docs
powershell -ExecutionPolicy Bypass -File preview-figs.ps1 -Only fig-vxi-crate   # one
powershell -ExecutionPolicy Bypass -File preview-figs.ps1 -Doc 0*              # one document
```

`common/tikztest.tex` is the harness that script uses. It is a tool, not a
build artifact — do not delete it when clearing `.aux`/`.log` files.

Measure a diagram's natural size, so the `\adjustbox` caps on the rotated page
are set from measurement rather than guesswork — run this from the document's
own folder:

```powershell
lualatex -interaction=nonstopmode "\def\FIG{fig-system-overview}\input{../common/figsize}"
```

It prints `width=`, `height=`, `\textwidth` and `\textheight` to the log.

## PDF ↔ source synchronisation

The build passes `--synctex=1`, and `.vscode/settings.json` configures LaTeX
Workshop to match. In the VS Code PDF tab:

- **Ctrl+click in the PDF** jumps to the line in the `.tex` that produced it.
- **Ctrl+Alt+J in the editor** jumps to that spot in the PDF.

`body.tex` and every `tikz/*.tex` carry a `% !TeX root =` comment so the
extension knows which document they belong to. Keep that line at the top when
adding a new figure file.

If the build fails with `I can't write on file ...pdf`, the PDF is open in
something that locks it. Close it, or use a viewer that does not lock.

## Revision history

The revision history lives at the top of `body.tex` inside a
`\begin{comment}` block. It is deliberately **not rendered** — it belongs with
the source, not in a document sent to a reviewer. Add a row when making a
substantive change; leave historical rows frozen, since they record what was
true at the time.

## Layout

| Path | Contents |
|---|---|
| `common/preamble.tex` | Shared preamble for every document in this set |
| `common/tikztest.tex` | Single-figure preview harness (a tool, not an artifact) |
| `common/figsize.tex` | Reports a figure's natural size (a tool, not an artifact) |
| `common/photos/` | Photographs, copied here with LaTeX-safe names, shared across documents |
| `common/generated/` | Data plots built by `scripts/` (git-ignored) |
| `<doc>/` — main `.tex` | Title block and front matter; `\input{../common/preamble}` and `\input{body}` |
| `<doc>/body.tex` | The document text. **Edit this** for content changes. |
| `<doc>/tikz/` | That document's hand-authored block diagrams, one file per figure |
| `scripts/` | Generation of data-derived plots — see its README |

## Adding a document

1. Create `docX-short-name/` with `X_full_name.tex`, `body.tex` and `tikz/`.
2. In the main file, `\input{../common/preamble}` then `\input{body}`.
3. Add an entry to the `$docs` table at the top of `build.ps1`.
4. Add the main file to `latex-workshop.latex.search.rootFiles.include` in
   `.vscode/settings.json`, and put `% !TeX root =` at the top of `body.tex`
   and every `tikz/*.tex`.

## LuaLaTeX is required

Not a preference. `common/preamble.tex` maps every non-ASCII character used in
these documents to a LaTeX construct via `newunicodechar`. Without those
mappings LuaLaTeX **drops unmapped glyphs silently** — an unmapped `µ` turns
"\qty{8}{\micro\farad}" written as literal `8 μF` into "8 F", with no error.
That is why `build.ps1` treats a single dropped character as a build failure.

When adding text containing a new symbol, build and check the "dropped
characters" count. If it is non-zero, add the mapping to `common/preamble.tex`.

## Conventions

**Units.** Use `siunitx`: `\qty{2750}{\kilo\voltampere}`,
`\qtyrange{19}{22}{\ampere}`. Do not hand-type unit strings — that is how the
repository accumulated inconsistent values in the first place. `\voltampere`
is declared locally.

**Figures.** Size photographs with the semantic macros, never raw
`\includegraphics`:

| Macro | Size | Use for |
|---|---|---|
| `\photofig{file}{caption}{label}` | ~1/3 page | default for photographs |
| `\widefig{...}` | ~1/2 page | detailed schematics and screenshots |
| `\smallfig{...}` | ~1/4 page | low-resolution sources |
| `\pairfig{...}` | two at ~1/4 page | related photographs side by side |

All cap height as well as width, so no figure can blow up a page whatever its
aspect ratio. Wrap TikZ diagrams in `fitpicture`, which shrinks a drawing to
the text width only if it would otherwise overflow.

**Figure placement.** Each `\part` begins on a fresh page, and `placeins`
puts a float barrier at every `\section`, so a figure cannot drift out of the
section that discusses it. Use `[tbp]` for TikZ figures — **not** `[htbp]`.
With `h` allowed, LaTeX will place a tall drawing inline at the foot of a page
and let it run off (this produced a 311 pt overfull `\vbox`).

A drawing too wide for the text block goes in a `sidewaysfigure` with
`\adjustbox{max width=\textheight,max height=\textwidth}`, which rotates the
figure *and its caption* onto a normal portrait page. Do not use `landscape`:
it rotates the page, and a caption set at full text width then runs off it.

**Captions belong in `\caption{}`, not inside the drawing.** A note typeset
inside a TikZ picture does not appear in the List of Figures, is not
searchable as caption text, and scales with the figure.

**References.** Doc L keeps its established `[Rn]` numbering rather than
BibTeX, because the numbers are cited across the whole document set. `\R{5}`
is a hyperlink to the defining row in Appendix A; `\RDEF{5}` is that row.
Same for `\W{n}` / `\WDEF{n}` for web references. Transcriptions of source
documents are **not** cited: the originals are in the repository, so cite
those directly. Doc 0 has no reference appendix; it cites sources inline.

**Tables.** Use the `P{width}` column type (left-aligned, hyphenating
paragraph), or `Q{width}` for the same thing at `\small` in dense tables. Do
**not** wrap a `longtable` in `{\small ...}` — the group breaks longtable's
page-breaking `\write` and produces a baffling "Undefined control sequence"
during `\shipout`. Long file paths must be wrapped in `\fpath{...}` so they can
break; a bare `\texttt{}` path will overflow the page. `\fpath` must never
appear in a `\caption{}`: captions are written to the `.lof`, and the
`\nolinkurl` inside `\fpath` is not robust in a moving argument.

**Cross-references.** Sections are auto-numbered; the `§n.m` references in the
prose match because the numbering was preserved through the conversion. New
cross-references should use `\Cref{}` with a label rather than a literal
number.
