# SPEAR3 RF System design documents (LaTeX)

LaTeX is the **single source of truth** for these documents. The Markdown
originals were removed once conversion was verified; their history remains in
git.

| Doc | Main file | Body | Figure prefix |
|---|---|---|---|
| **Doc 0** — System Design Report (upgrade) | `0_system_design_report.tex` | `body-doc0.tex` | `tikz/fig0-*` |
| **Doc L** — Legacy System Architecture | `L_legacy_system_architecture.tex` | `body.tex` | `tikz/fig-*` |

Both share `preamble.tex`, so a change there affects both — rebuild both
before committing preamble edits.

## Build

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1          # Doc L (default)
powershell -ExecutionPolicy Bypass -File build.ps1 -Clean   # from scratch
powershell -ExecutionPolicy Bypass -File build.ps1 -Doc 0_system_design_report
```

`build.ps1` runs LuaLaTeX three times and then **fails the build** on any
LaTeX error or any silently dropped character. Read the summary it prints; a
clean build reports zero for both.

Preview a single diagram while working on it:

```powershell
powershell -ExecutionPolicy Bypass -File preview-figs.ps1                     # all
powershell -ExecutionPolicy Bypass -File preview-figs.ps1 -Only fig-vxi-crate # one
```

`tikztest.tex` is the harness that script uses. It is a tool, not a build
artifact — do not delete it when clearing `.aux`/`.log` files.

Measure a diagram's natural size, so the `\adjustbox` caps on the rotated page
are set from measurement rather than guesswork:

```powershell
lualatex -interaction=nonstopmode "\def\FIG{fig-system-overview}\input{figsize}"
```

It prints `width=`, `height=`, `\textwidth` and `\textheight` to the log.

## PDF ↔ source synchronisation

The build passes `--synctex=1`, and `.vscode/settings.json` configures LaTeX
Workshop to match. In the VS Code PDF tab:

- **Ctrl+click in the PDF** jumps to the line in the `.tex` that produced it.
- **Ctrl+Alt+J in the editor** jumps to that spot in the PDF.

`body.tex`, `body-doc0.tex` and every `tikz/*.tex` carry a `% !TeX root =`
comment so the extension knows which document they belong to. Keep that line at
the top when adding a new figure file.

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
| `0_system_design_report.tex` | Doc 0: title block, front matter, `\input{body-doc0}` |
| `body-doc0.tex` | Doc 0 text. **Edit this** for content changes. |
| `L_legacy_system_architecture.tex` | Doc L: title block, front matter, `\input{body}` |
| `body.tex` | Doc L text. **Edit this** for content changes. |
| `preamble.tex` | Shared preamble for all documents in this set |
| `tikz/` | Hand-authored block diagrams, one file per figure |
| `figures/photos/` | Photographs, copied here with LaTeX-safe names |
| `figures/generated/` | Data plots built by `scripts/` (git-ignored) |
| `scripts/` | Generation of data-derived plots — see its README |

## LuaLaTeX is required

Not a preference. `preamble.tex` maps every non-ASCII character used in these
documents to a LaTeX construct via `newunicodechar`. Without those mappings
LuaLaTeX **drops unmapped glyphs silently** — an unmapped `µ` turns
"\qty{8}{\micro\farad}" written as literal `8 μF` into "8 F", with no error.
That is why `build.ps1` treats a single dropped character as a build failure.

When adding text containing a new symbol, build and check the "dropped
characters" count. If it is non-zero, add the mapping to `preamble.tex`.

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
paragraph). Long file paths must be wrapped in `\fpath{...}` so they can break;
a bare `\texttt{}` path will overflow the page.

**Cross-references.** Sections are auto-numbered; the `§n.m` references in the
prose match because the numbering was preserved through the conversion. New
cross-references should use `\Cref{}` with a label rather than a literal
number.
