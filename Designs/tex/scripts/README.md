# Figure generation scripts

Most diagrams in these documents are hand-authored TikZ and live in
`../tikz/`. They are plain text, diff cleanly, and need no build step beyond
LaTeX itself — that is the right home for block diagrams, signal flows and
rack layouts.

This folder is for the other kind of figure: **plots derived from data**.
Nothing here is required to build Doc L, which currently has no data plots.
The convention is set up so that when one is needed, it is reproducible.

## Convention

```
scripts/
  data/            measured or exported data, committed as CSV
  make-figures.ps1 regenerates everything into ../figures/generated/
  <name>.tex       a standalone pgfplots figure reading from data/
```

Rules:

1. **Commit the data.** A plot whose input is not in the repository cannot be
   checked or regenerated. CSV, one header row, SI units in the column names.
2. **Prefer pgfplots over an external toolchain.** It reads the CSV directly at
   compile time, so the figure always matches the committed data, fonts match
   the surrounding text automatically, and there is no binary artifact to keep
   in sync. There is no Python on this machine; do not introduce a dependency
   on one without saying so here.
3. **Generated output goes to `../figures/generated/`** and is git-ignored.
   Never edit anything in that folder by hand.
4. If a plot genuinely needs a real programming language, add the script here,
   have it write a PDF into `../figures/generated/`, and call it from
   `make-figures.ps1` so one command still rebuilds everything.

## Reading data in a figure

```latex
\pgfplotstableread[col sep=comma]{scripts/data/ripple.csv}\ripple
\begin{tikzpicture}
  \begin{axis}[xlabel={Time (\unit{\milli\second})},
               ylabel={Cathode voltage (\unit{\kilo\volt})},
               width=0.8\linewidth, height=0.32\textheight]
    \addplot table[x=t_ms, y=v_kv] {\ripple};
  \end{axis}
\end{tikzpicture}
```

Size plots with `width` and `height` the same way photographs are sized in
`preamble.tex`: roughly a third of a page, never more than half.
