// Markdown -> LaTeX for the SPEAR3 design documents.
//   node Designs/tex/scripts/md2tex.js P
//   node Designs/tex/scripts/md2tex.js T
// Runs preprocess -> pandoc -> postprocess in one pass.  Structural directives
// are handed to pandoc as plain-text "ZZKIND|n" lines, because pandoc escapes
// backslashes in its input and would mangle a real macro.  Pandoc renders "|"
// as \textbar, which the postprocessor matches.
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const PANDOC = 'C:\\Users\\fywang\\AppData\\Local\\Pandoc\\pandoc.exe';

const DOCS = {
  P: {
    md: 'Designs/P_RF_PHYSICS_AND_PLANT.md',
    dir: 'Designs/tex/docP-rf-physics',
    root: 'P_rf_physics_and_plant.tex',
    startAt: '## Document Scope and Provenance',
    unnumbered: ['Document Scope and Provenance'],
    figs: [
      ['fig-plant-overview', 'The SPEAR3 RF plant as a control system: the klystron and cavity chain is the plant, the LLRF processor is the controller, and the beam is the principal disturbance.'],
      ['fig-beam-loading-phasor', 'Beam loading phasor diagram in steady state at \\qty{500}{\\milli\\ampere}. The cavity is detuned so that the generator sees a real load: the reactive part of the beam-induced voltage is cancelled by the detuning angle $\\psi$.'],
      ['fig-comb-response', 'Comb filter response. The peaks sit at multiples of the revolution frequency, one per coupled-bunch mode; between them the gain returns towards unity, so the filter adds no broadband noise. Drawn from the digital comb magnitude with pole radius $K=0.98$ and comb gain 30 to show the characteristic shape --- these are not fitted SPEAR3 values.'],
      ['fig-disturbance-spectrum', 'Disturbance spectrum and the loop assigned to each band. Loop bandwidths are separated by roughly a decade so that adjacent loops do not interact.'],
    ],
  },
  T: {
    md: 'Designs/T_TUNER_CONTROL_SYSTEM_ANALYSIS.md',
    dir: 'Designs/tex/docT-tuner-control',
    root: 'T_tuner_control_analysis.tex',
    startAt: '# Part I — What and Why',
    unnumbered: [],
    figs: [
      ['fig-tuner-loops', 'The dual-loop tuner architecture: an inner phase-regulation loop closed on the load angle error, and an outer voltage-regulation loop that biases its setpoint. On SPEAR3 only the inner loop is active.'],
      ['fig-signal-chain', 'Tuner signal chain from the cavity probe and forward coupler through the IQA modules to the stepper motor record.'],
      ['fig-loop-states', 'SNL tuner loop state machine. Five states; motion is commanded only from \\texttt{loop\\_on}.'],
      ['fig-loop-timing', 'Timing of one tuner loop cycle at \\qty{2}{\\hertz}, from measurement through move command to the position check.'],
    ],
  },
};

const key = process.argv[2];
const doc = DOCS[key];
if (!doc) throw new Error(`usage: md2tex.js <${Object.keys(DOCS).join('|')}>`);

// ---------------------------------------------------------------- preprocess
let md = fs.readFileSync(doc.md, 'utf8');
const cut = md.indexOf(doc.startAt);
if (cut < 0) throw new Error(`start marker not found: ${doc.startAt}`);
md = md.slice(cut);

// GitHub ```math fences are display equations; make them $$ so that pandoc's
// tex_math_dollars turns them into real LaTeX rather than a verbatim block.
let mathBlocks = 0;
md = md.replace(/```math\r?\n([\s\S]*?)```/g, (a, body) => {
  mathBlocks++;
  return `$$\n${body.trim()}\n$$`;
});

// classify the remaining fenced blocks
const diagrams = [], literals = [];
md = md.replace(/```(\w*)\r?\n([\s\S]*?)```/g, (a, lang, raw) => {
  const body = raw.replace(/\s+$/, '');
  if (/[\u2500-\u257F]/.test(body)) {
    diagrams.push(body);
    return `\n\nZZFIG|${diagrams.length - 1}\n\n`;
  }
  literals.push({ lang, body });
  return `\n\nZZLIT|${literals.length - 1}\n\n`;
});

// Parts (h1) become \part; they group but do not renumber sections
const parts = [];
md = md.replace(/^#\s+Part\s+([IVX]+)\s*[—–-]\s*(.+)$/gm, (a, r, title) => {
  parts.push(title.trim());
  return `ZZPART|${parts.length - 1}`;
});
md = md.replace(/^#\s+Appendices\s*$/gm, '');

// appendices: "Appendix A — Title" or "Appendix A. Title"
const appendices = [];
md = md.replace(/^(#{2,3})\s+Appendix\s+([A-Z])[.\s]*[—–-]?\s*(.+)$/gm, (a, h, letter, title) => {
  appendices.push(letter);
  const marker = appendices.length === 1 ? 'ZZAPPENDIX\n\n' : '';
  return `${marker}${h} ${title.trim()}`;
});

for (const u of doc.unnumbered) {
  md = md.replace(new RegExp(`^(#{2,3})\\s+${u}\\s*$`, 'm'), `ZZUNNUM\n\n$1 ${u}`);
}

// drop the manual "N.", "N.M", "N.M.K" prefixes; LaTeX regenerates them
md = md.replace(/^(#{2,4})\s+\d+(?:\.\d+)*\.?\s+(.+)$/gm, (a, h, title) => `${h} ${title.trim()}`);

// promote one level so that, with --top-level-division=section, h2 -> \section
md = md.replace(/^(#{2,5})\s+/gm, (a, h) => h.slice(1) + ' ');

fs.writeFileSync('.tmp_pre.md', md);

// ------------------------------------------------------------------- pandoc
execFileSync(PANDOC, ['--from=gfm+tex_math_dollars', '--to=latex',
  '--top-level-division=section', '--wrap=preserve',
  '-o', '.tmp_raw.tex', '.tmp_pre.md']);
let t = fs.readFileSync('.tmp_raw.tex', 'utf8');

// --------------------------------------------------------------- postprocess
// \hypertarget{a}{% \section{...}\label{b}} -- the closing brace must be
// matched, not assumed, or the result has unbalanced braces.
function unwrapHypertargets(s) {
  let out = '', i = 0;
  for (;;) {
    const k = s.indexOf('\\hypertarget{', i);
    if (k < 0) { out += s.slice(i); break; }
    out += s.slice(i, k);
    let j = s.indexOf('{', k + '\\hypertarget'.length), d = 0, p = j;
    for (; p < s.length; p++) { if (s[p] === '{') d++; else if (s[p] === '}') { d--; if (!d) break; } }
    const second = s.indexOf('{', p + 1); d = 0; let q = second;
    for (; q < s.length; q++) { if (s[q] === '{') d++; else if (s[q] === '}') { d--; if (!d) break; } }
    out += s.slice(second + 1, q).replace(/^%\r?\n/, '').trim() + '\n';
    i = q + 1;
  }
  return out;
}
t = unwrapHypertargets(t);

t = t.replace(/ZZPART\\textbar\s*(\d+)/g, (a, n) => `\\part{${parts[+n]}}`);
t = t.replace(/ZZUNNUM\s*\n+\\section\{([^}]*)\}\\label\{([^}]*)\}/g,
  (a, title, lab) => `\\section*{${title}}\\label{${lab}}\n\\addcontentsline{toc}{section}{${title}}`);
let firstAppendix = true;
t = t.replace(/ZZAPPENDIX\s*\n*/g, () => {
  const s = firstAppendix ? '\\appendix\n\n' : ''; firstAppendix = false; return s;
});

t = t.replace(/ZZFIG\\textbar\s*(\d+)/g, (a, n) => {
  const [name, cap] = doc.figs[+n] || [`fig-unnamed-${n}`, 'TODO caption'];
  return `\\begin{figure}[tbp]\n\\centering\n\\begin{fitpicture}\\input{tikz/${name}}\\end{fitpicture}\n` +
         `\\caption{${cap}}\\label{fig:${name.replace(/^fig-/, '')}}\n\\end{figure}`;
});
t = t.replace(/ZZLIT\\textbar\s*(\d+)/g, (a, n) => {
  const { lang, body } = literals[+n];
  const env = lang ? 'codeblock' : 'sigblock';
  return `\\begin{${env}}\n${body}\n\\end{${env}}`;
});

// A markdown blockquote that contains a heading becomes \section inside
// \begin{quote}, which LaTeX rejects ("perhaps a missing \item").  Hoist the
// heading out and promote the remaining prose to a callout box.
let hoisted = 0;
t = t.replace(/\\begin\{quote\}([\s\S]*?)\\end\{quote\}/g, (all, inner) => {
  const m = inner.match(/\\(?:sub)*section\{[\s\S]*?\}(?:\\label\{[^}]*\})?/);
  if (!m) return all;
  hoisted++;
  const warn = /⚠/.test(inner);
  const head = m[0].replace(/⚠\s*/, '');
  const rest = inner.replace(m[0], '').trim();
  return `${head}\n\n\\begin{${warn ? 'warnbox' : 'keynote'}}\n${rest}\n\\end{${warn ? 'warnbox' : 'keynote'}}`;
});

// longtables: pandoc emits bare "l" columns for every one, which overflows the
// page.  Convert to proportional Q{} (small, ragged-right, hyphenating).
function splitCells(row) {
  const out = []; let d = 0, cur = '';
  for (let i = 0; i < row.length; i++) {
    const c = row[i];
    if (c === '{') d++; else if (c === '}') d--;
    if (c === '&' && d === 0 && row[i - 1] !== '\\') { out.push(cur); cur = ''; }
    else cur += c;
  }
  out.push(cur); return out;
}
const visible = s => s
  .replace(/\\(textbf|emph|texttt|textit|fpath|textbar|textasciitilde|textless|textgreater)\s*/g, '')
  .replace(/[{}\\]/g, '').trim();

let tableCount = 0;
// Pandoc emits bare l/c/r columns for every longtable, which overflows the
// page.  Match any mix of them, not just all-l.
t = t.replace(/\\begin\{longtable\}\[\]\{@\{\}([lcr]+)@\{\}\}([\s\S]*?)\\end\{longtable\}/g,
  (all, cols, body) => {
    const n = cols.length;
    const rows = body.split(/\\\\\s*\n/)
      .map(r => r.replace(/\\(top|mid|bottom)rule|\\noalign\{\}|\\endhead|\\endlastfoot/g, '').trim())
      .filter(r => r && r.includes('&'));
    const widths = new Array(n).fill(1), tok = new Array(n).fill(1);
    for (const r of rows) {
      const cells = splitCells(r);
      if (cells.length !== n) continue;
      cells.forEach((c, i) => {
        const v = visible(c);
        widths[i] = Math.max(widths[i], Math.min(v.length, 90));
        for (const w of v.split(/[\s/]+/)) tok[i] = Math.max(tok[i], w.length);
      });
    }
    const LINE = 468, CH = 4.7;
    let frac = widths.map(w => w / widths.reduce((a, b) => a + b, 0));
    const floor = tok.map(x => Math.min(0.45, (x * CH) / LINE));
    frac = frac.map((f, i) => Math.max(f, floor[i]));
    const sum = frac.reduce((a, b) => a + b, 0);
    frac = frac.map(f => f / sum);
    const k = (2 * (n - 1) / n).toFixed(2);
    const spec = frac.map(f => `Q{\\dimexpr ${f.toFixed(4)}\\linewidth-${k}\\tabcolsep\\relax}`).join('');
    tableCount++;
    return `\\begin{longtable}[]{@{}${spec}@{}}${body}\\end{longtable}`;
  });

// EPICS PV names and repo paths have no hyphenation points, so a long token
// overflows whatever column it lands in.  Allow breaks at the separators.
function breakLongTexttt(s) {
  let out = '', i = 0; const TAG = '\\texttt{';
  for (;;) {
    const k = s.indexOf(TAG, i);
    if (k < 0) { out += s.slice(i); break; }
    out += s.slice(i, k);
    let d = 0, p = k + TAG.length - 1;
    for (; p < s.length; p++) { if (s[p] === '{') d++; else if (s[p] === '}') { d--; if (!d) break; } }
    const inner = s.slice(k + TAG.length, p);
    const plain = inner.replace(/\\[{}]/g, 'x').replace(/[{}\\]/g, '');
    out += (plain.length >= 14 && /[:/_.,=-]/.test(inner))
      ? TAG + inner.replace(/([:/_.,=-])(?=.)/g, '$1\\allowbreak{}') + '}'
      : TAG + inner + '}';
    i = p + 1;
  }
  return out;
}
t = breakLongTexttt(t);

const header = `% !TeX root = ${doc.root}\n` +
  `% Generated from ${path.basename(doc.md)} by scripts/md2tex.js, then hand-corrected.\n` +
  `% Edit THIS file, not the markdown.\n\n`;
fs.mkdirSync(path.join(doc.dir, 'tikz'), { recursive: true });
fs.writeFileSync(path.join(doc.dir, 'body.tex'), header + t.trim() + '\n');

// placeholder art for any figure not yet drawn, so the document still compiles
let stubs = 0;
for (const [name] of doc.figs) {
  const f = path.join(doc.dir, 'tikz', name + '.tex');
  if (fs.existsSync(f)) continue;
  fs.writeFileSync(f, `% !TeX root = ../${doc.root}\n% PLACEHOLDER -- not yet drawn.\n` +
    `\\begin{tikzpicture}[font=\\scriptsize, x=1mm, y=1mm]\n` +
    `\\node[blk,text width=120mm,minimum height=28mm,align=center,draw=cPwr,fill=cPwr!5]\n` +
    `  {\\textbf{figure not yet drawn}\\\\[2mm]\\texttt{${name}}};\n\\end{tikzpicture}\n`);
  stubs++;
}

console.log(`=== Doc ${key} ===`);
console.log(`  math blocks -> display : ${mathBlocks}`);
console.log(`  parts                  : ${parts.length}`);
console.log(`  appendices             : ${appendices.length}`);
console.log(`  diagrams               : ${diagrams.length} (names configured: ${doc.figs.length})`);
console.log(`  literal blocks         : ${literals.length}`);
console.log(`  longtables rewritten   : ${tableCount}`);
console.log(`  headings hoisted       : ${hoisted}`);
console.log(`  placeholders created   : ${stubs}`);
console.log(`  markers left           : ${(t.match(/ZZ(FIG|LIT|PART|APPENDIX|UNNUM)/g) || []).length}`);
console.log(`  hypertargets left      : ${(t.match(/hypertarget/g) || []).length}`);
console.log(`  body.tex               : ${Math.round(t.length / 1024)} KB`);
