// Doc I: Markdown -> LaTeX, stage 2 (postprocess pandoc output).
const fs = require('fs');
let t = fs.readFileSync('.tmp_docI_raw.tex', 'utf8');
const B = JSON.parse(fs.readFileSync('.tmp_docI_blocks.json', 'utf8'));

// Figure identities, in document order. Captions are written here, not in the art.
const FIGS = [
  ['fig-signal-flow', 'Legacy interlock signal flow. Three fault sources feed five actors. The hardware paths across the top are independent of software; the EPICS alarm tree at the bottom is the single software trip wire into the SNL state machine. The RF MPS PLC acts on three paths: \\textbf{Path A} de-energises a relay and removes the hardware permit at the Fast Interlock Chassis; \\textbf{Path B} clears the Remote I/O permit bit, setting \\texttt{STN:MPS:LTCH} to MAJOR in the alarm tree; \\textbf{Path C} drives VXI Slot 5, which asserts RF\\_FAULT on the backplane as a redundant RF cut.'],
  ['fig-fastic-trip', 'Fast Interlock Chassis trip mechanism. Pure analog comparators with no CPU in the path.'],
  ['fig-cascade', 'Cascade following an RF drive cut. Secondary trips follow the primary event and can reach the HVPS faster than the SNL shutdown does.'],
  ['fig-mps-plc-io', 'RF MPS PLC (Allen-Bradley PLC-5 with 1771 I/O) inputs and outputs.'],
  ['fig-hvps-enable-chain', 'HVPS enable chain executed by the \\texttt{HVPSONSUB()} macro in \\texttt{rf\\_states.st}.'],
  ['fig-hvps-alarm-tree', 'HVPS alarm aggregation. Three summary records, each collecting its inputs on a spine. \\texttt{HVPSSTN:SUMY:LTCH} is itself an input to both of the others (as \\textsc{inpi} and \\textsc{inpd} respectively), so a single latched HVPS fault reaches the station trip wire through \\texttt{HVPSOFF:SUMY:STAT}. Its own \\textsc{inpe} is a further two-input record, \\texttt{HVPS:TEMP:LTCH} and \\texttt{HVPSOIL:TEMP:LTCH}. \\texttt{HVPS:SUMY:LTCH} is a readiness summary and is \\emph{not} a trip path.'],
  ['fig-snl-tripwire', 'The single SNL trip wire: every fault source converges on \\texttt{STNOFF:SUMY:STAT.SEVR}.'],
  ['fig-permit-layers', 'Permit layers. The machine permit and personnel permit chains are separate all the way down.'],
];
if (FIGS.length !== B.diagrams.length) {
  throw new Error(`have ${B.diagrams.length} diagrams but ${FIGS.length} names`);
}

// --- 1. unwrap \hypertarget{a}{% \section{...}\label{b}} --------------------
// The closing brace must be matched, not assumed, or we get "Too many }'s".
function unwrapHypertargets(s) {
  let out = '', i = 0;
  for (;;) {
    const k = s.indexOf('\\hypertarget{', i);
    if (k < 0) { out += s.slice(i); break; }
    out += s.slice(i, k);
    let j = s.indexOf('{', k + '\\hypertarget'.length);   // first arg
    let d = 0, p = j;
    for (; p < s.length; p++) { if (s[p] === '{') d++; else if (s[p] === '}') { d--; if (!d) break; } }
    const second = s.indexOf('{', p + 1);                  // second arg
    d = 0; let q = second;
    for (; q < s.length; q++) { if (s[q] === '{') d++; else if (s[q] === '}') { d--; if (!d) break; } }
    out += s.slice(second + 1, q).replace(/^%\r?\n/, '').trim() + '\n';
    i = q + 1;
  }
  return out;
}
t = unwrapHypertargets(t);

// --- 2. markers -------------------------------------------------------------
t = t.replace(/ZZUNNUMBERED\s*\n+\\section\{([^}]*)\}\\label\{([^}]*)\}/,
  (a, title, lab) => `\\section*{${title}}\\label{${lab}}\n\\addcontentsline{toc}{section}{${title}}`);

let firstAppendix = true;
t = t.replace(/ZZAPPENDIX\\textbar\s*([A-C])\s*\n+/g, () => {
  const s = firstAppendix ? '\\appendix\n\n' : '';
  firstAppendix = false;
  return s;
});

t = t.replace(/ZZFIG\\textbar\s*(\d+)/g, (a, n) => {
  const [name, cap] = FIGS[+n];
  return `\\begin{figure}[tbp]\n\\centering\n\\begin{fitpicture}\\input{tikz/${name}}\\end{fitpicture}\n` +
         `\\caption{${cap}}\\label{fig:${name.replace(/^fig-/, '')}}\n\\end{figure}`;
});

t = t.replace(/ZZTIMELINE\\textbar\s*(\d+)/g, (a, n) => renderTimeline(B.timelines[+n]));
t = t.replace(/ZZLIT\\textbar\s*(\d+)/g, (a, n) => {
  const { lang, body } = B.literals[+n];
  const env = lang ? 'codeblock' : 'sigblock';
  return `\\begin{${env}}\n${body}\n\\end{${env}}`;
});

// --- 3. timelines -> a two-column environment -------------------------------
// Each entry is "t = <time>   <first line>" followed by indented continuation.
function renderTimeline(body) {
  const rows = [];
  // split on \r?\n: JavaScript's "." cannot match a stray \r, so a CRLF line
  // would defeat the trailing (.+)$ below.
  for (const line of body.split(/\r?\n/)) {
    if (!line.trim()) continue;
    // "t = 0 ns        Arc breakdown ..." -- time field, then a run of 2+ spaces
    const m = /^(t\s*[=<>≈≥≤].*?)\s{2,}(.+)$/.exec(line);
    if (m) rows.push({ time: m[1].trim(), lines: [m[2].trim()] });
    else if (rows.length) rows[rows.length - 1].lines.push(line.trim());
    else rows.push({ time: '', lines: [line.trim()] });
  }
  const esc = s => s
    .replace(/\\/g, '\\textbackslash{}')
    .replace(/([&%#_$])/g, '\\$1')
    .replace(/\{/g, '\\{').replace(/\}/g, '\\}')
    .replace(/\^/g, '\\textasciicircum{}').replace(/~/g, '\\textasciitilde{}')
    // the preamble maps these to "--"/"---", which do not ligature in \ttfamily
    .replace(/–/g, '\\textendash{}').replace(/—/g, '\\textemdash{}');
  const out = rows.map(r => {
    const body = r.lines.map(l => esc(l).replace(/^→\s*/, '$\\rightarrow$~'))
      .join('\\newline\n      ');
    return `  \\tlrow{${esc(r.time)}}{${body}}`;
  });
  return `\\begin{timeline}\n${out.join('\n')}\n\\end{timeline}`;
}

// --- 4. longtables: bare l columns -> proportional P{} ----------------------
// A tabular puts \tabcolsep on both sides of every column; with @{} at the
// edges the overhead is 2(n-1)\tabcolsep, so charge each column 2(n-1)/n.
function splitCells(row) {
  const out = []; let d = 0, cur = '';
  for (let i = 0; i < row.length; i++) {
    const c = row[i];
    if (c === '{') d++; else if (c === '}') d--;
    if (c === '&' && d === 0 && row[i - 1] !== '\\') { out.push(cur); cur = ''; }
    else cur += c;
  }
  out.push(cur);
  return out;
}
const visible = s => s
  .replace(/\\(textbf|emph|texttt|textit|fpath|textbar|textasciitilde|textless|textgreater)\s*/g, '')
  .replace(/[{}\\]/g, '').trim();

let tableCount = 0;
t = t.replace(/\\begin\{longtable\}\[\]\{@\{\}(l+)@\{\}\}([\s\S]*?)\\end\{longtable\}/g,
  (all, cols, body) => {
    const n = cols.length;
    const rows = body.split(/\\\\\s*\n/)
      .map(r => r.replace(/\\(top|mid|bottom)rule|\\noalign\{\}|\\end(head|lastfoot)|\\endhead|\\endlastfoot/g, '').trim())
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
    const LINE = 468;                 // \linewidth in pt for this class
    const CH = 4.7;                   // pt per character at \small
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

// --- 5. let long \texttt identifiers wrap -----------------------------------
// EPICS PV names and repo paths have no hyphenation points, so a 27-character
// token overflows whatever column it lands in.  Allow a break after ':' and '/'.
function breakLongTexttt(s) {
  let out = '', i = 0;
  const TAG = '\\texttt{';
  for (;;) {
    const k = s.indexOf(TAG, i);
    if (k < 0) { out += s.slice(i); break; }
    out += s.slice(i, k);
    let d = 0, p = k + TAG.length - 1;
    for (; p < s.length; p++) { if (s[p] === '{') d++; else if (s[p] === '}') { d--; if (!d) break; } }
    const inner = s.slice(k + TAG.length, p);
    const plain = inner.replace(/\\[{}]/g, 'x').replace(/[{}\\]/g, '');
    out += (plain.length >= 14 && /[:/_.-]/.test(inner))
      ? TAG + inner.replace(/([:/_.-])(?=.)/g, '$1\\allowbreak{}') + '}'
      : TAG + inner + '}';
    i = p + 1;
  }
  return out;
}
t = breakLongTexttt(t);

// --- 6. header --------------------------------------------------------------
t = '% !TeX root = I_interlock_architecture.tex\n' +
    '% Doc I body. Generated from I_INTERLOCK_ARCHITECTURE.md, then hand-corrected.\n' +
    '% Edit THIS file, not the markdown.\n\n' + t.trim() + '\n';

fs.writeFileSync('Designs/tex/docI-interlock-architecture/body.tex', t);
console.log(`longtables rewritten : ${tableCount}`);
console.log(`figures              : ${FIGS.length}`);
console.log(`timelines            : ${B.timelines.length}`);
console.log(`literal blocks       : ${B.literals.length}`);
console.log(`markers left         : ${(t.match(/ZZ(FIG|TIMELINE|LIT|APPENDIX|UNNUMBERED)/g) || []).length}`);
console.log(`hypertargets left    : ${(t.match(/hypertarget/g) || []).length}`);
console.log(`wrote body.tex       : ${Math.round(t.length / 1024)} KB`);
