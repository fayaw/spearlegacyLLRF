const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const repo = path.resolve(__dirname, '../../..');
const directory = path.join(repo, 'Designs/tex/docL-legacy-architecture');
const job = 'L_legacy_system_architecture';
const sourceOnly = process.argv.includes('--source-only');
const failures = [];
const read = filename => fs.readFileSync(filename, 'utf8');
const active = text => text.replace(/\\begin\{comment\}[\s\S]*?\\end\{comment\}/g, '')
  .replace(/(?<!\\)%[^\r\n]*/g, '');
const body = active(read(path.join(directory, 'body.tex')));
const main = active(read(path.join(directory, `${job}.tex`)));
const figureFiles = [...body.matchAll(/\\input\{(tikz\/[^}]+)\}/g)]
  .map(match => path.join(directory, `${match[1]}.tex`));
const figures = figureFiles.map(filename => active(read(filename))).join('\n');
const content = `${body}\n${figures}`;
const check = (condition, message) => { if (!condition) failures.push(message); };
const values = (text, expression) => [...text.matchAll(expression)].map(match => match[1]);

function unique(items, description) {
  const seen = new Set();
  for (const item of items) {
    check(!seen.has(item), `Duplicate ${description}: ${item}`);
    seen.add(item);
  }
  return seen;
}

function bracedArgument(text, offset) {
  let cursor = offset;
  while (/\s/.test(text[cursor] || '')) cursor++;
  if (text[cursor] !== '{') throw new Error(`Expected TeX argument at ${cursor}`);
  const start = ++cursor;
  let depth = 1;
  for (; cursor < text.length; cursor++) {
    if (text[cursor] === '\\') cursor++;
    else if (text[cursor] === '{') depth++;
    else if (text[cursor] === '}' && --depth === 0) {
      return { value: text.slice(start, cursor), end: cursor + 1 };
    }
  }
  throw new Error(`Unclosed TeX argument at ${offset}`);
}

const macroLabels = [];
const macroImages = [];
for (const match of body.matchAll(/\\(photofig|widefig|smallfig|tallfig|tallpairfig|pairfig)\b/g)) {
  const count = match[1] === 'tallpairfig' ? 8 : match[1] === 'pairfig' ? 6 : 3;
  const argumentsList = [];
  let cursor = match.index + match[0].length;
  for (let argumentIndex = 0; argumentIndex < count; argumentIndex++) {
    const argument = bracedArgument(body, cursor);
    argumentsList.push(argument.value);
    cursor = argument.end;
  }
  macroImages.push(argumentsList[0]);
  macroLabels.push(argumentsList[2]);
  if (count > 3) {
    macroImages.push(argumentsList[3]);
    macroLabels.push(argumentsList[5]);
  }
  if (count === 8) macroLabels.push(argumentsList[7]);
}

const labels = unique([...values(content, /\\label\{([^}]+)\}/g), ...macroLabels], 'label');
labels.add('LastPage');
const referenced = new Set();
const noteReference = (target, message) => {
  if (!target || target.includes('#')) return;
  check(labels.has(target), `${message}: ${target}`);
  referenced.add(target);
};
for (const match of `${main}\n${content}`.matchAll(/\\(?:[Cc]ref(?:range)?|ref|pageref|autoref)\*?((?:\{[^}]*\})+)/g)) {
  for (const group of match[1].matchAll(/\{([^}]*)\}/g)) {
    for (const label of group[1].split(',')) noteReference(label.trim(), 'Missing label');
  }
}
for (const target of values(content, /\\hyperref\[([^\]]+)\]/g)) {
  noteReference(target, 'Missing hyperref label');
}
for (const label of labels) {
  if (label.startsWith('fig:')) check(referenced.has(label), `Figure never called out in the text: ${label}`);
}
const anchors = new Set(values(`${main}\n${content}`, /\\hypertarget\{([^}]+)\}/g));
for (const target of values(content, /\\hyperlink\{([^}]+)\}/g)) {
  if (!target.includes('#')) check(anchors.has(target), `Missing hyperlink destination: ${target}`);
}
for (const prefix of ['R']) {
  const definitions = unique(values(content, new RegExp(`\\\\${prefix}DEF\\{(\\d+)\\}`, 'g')), `${prefix} reference`);
  const citations = values(content, new RegExp(`\\\\${prefix}\\{(\\d+)\\}`, 'g'));
  for (const citation of citations) check(definitions.has(citation), `Undefined citation: ${prefix}${citation}`);
  console.log(`${prefix} references: ${definitions.size}`);
}
check(!/\\W(DEF)?\{\d+\}/.test(content), 'Obsolete [Wn] web reference remains');

const items = unique(values(body, /^(O\d+)\s*&/gm), 'open item');
const tags = unique(values(body, /\\openitem\{(O\d+)\}/g), 'open-item tag');
const backlinks = unique(values(body, /\\openpage\{(O\d+)\}/g), 'open-item backlink');
for (const item of new Set([...items, ...tags, ...backlinks])) {
  check(items.has(item) && tags.has(item) && backlinks.has(item), `Incomplete open-item linkage: ${item}`);
}
check(items.size > 0, 'Open Items register is empty');
check([...items].every((item, index) => item === `O${index + 1}`), 'Open Items must be numbered consecutively from O1');
check(!/\bG\d+\b/.test(content), 'Obsolete G-numbered open-item reference remains');
console.log(`Open items: ${items.size}; tags: ${tags.size}; backlinks: ${backlinks.size}`);
check(body.indexOf('\\label{sec:open-items}') < body.indexOf('\\part{'), 'Open Items must precede the main body');
check(!/Documentation Gaps and Items Requiring Field Verification/.test(body), 'Obsolete gap heading remains');
check(!/\.md\b/.test(content), 'Active text still cites a Markdown note');

const paths = new Set(values(body, /\\fpath\{([^{}\r\n]+)\}/g)
  .map(value => value.replace(/\\allowbreak\{\}/g, '').replace(/\\([_&#% ])/g, '$1')));
let checkedPaths = 0;
for (const filename of paths) {
  if (!/^(?:Designs|hvps|llrf|pps|spear-rf-code-legacy|rfApp|iocBoot|allenBradley|stepper)\//.test(filename)) continue;
  checkedPaths++;
  check(fs.existsSync(path.join(repo, filename)), `Missing or non-root-relative source path: ${filename}`);
}
for (const image of macroImages) {
  check(fs.existsSync(path.join(repo, 'Designs/tex/common/photos', image)), `Missing image: ${image}`);
}
console.log(`Repository paths checked: ${checkedPaths}; TikZ figures: ${figureFiles.length}`);

function rcsHead(relative) {
  const archive = read(path.join(repo, relative));
  const revision = archive.match(/^head\s+([^;]+);/m)?.[1];
  if (!revision) throw new Error(`Missing RCS head: ${relative}`);
  const escaped = revision.replace(/\./g, '\\.');
  const expression = new RegExp(`\\bdesc\\s+@(?:[^@]|@@)*@\\s+${escaped}\\s+log\\s+@(?:[^@]|@@)*@\\s+text\\s+@((?:[^@]|@@)*)@`);
  const text = archive.match(expression)?.[1];
  if (text === undefined) throw new Error(`Cannot extract RCS head: ${relative}`);
  return text.replace(/@@/g, '@');
}

const expectedPrograms = {
  rf_states: [2227, 23, 3], rf_calib: [3345, 28, 1],
  rf_tuner_loop: [555, 5, 1], rf_hvps_loop: [343, 4, 1],
  rf_dac_loop: [290, 4, 1], rf_msgs: [352, 3, 2],
};
let totalLines = 0;
for (const [program, expected] of Object.entries(expectedPrograms)) {
  const original = rcsHead(`spear-rf-code-legacy/rfApp/src/seq/${program}.st,v`);
  const code = original.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/[^\r\n]*/g, '');
  const counts = [original.split(/\r?\n/).length - Number(original.endsWith('\n')),
    values(code, /^\s*state\s+(\w+)\s*\{/gm).length,
    values(code, /^\s*ss\s+(\w+)\s*\{/gm).length];
  check(counts.every((count, index) => count === expected[index]), `SNL inventory changed: ${program}: ${counts}`);
  totalLines += counts[0];
  console.log(`${program}: ${counts[0]} lines, ${counts[1]} states, ${counts[2]} state sets`);
}
check(totalLines === 7112 && body.includes('7,112'), 'SNL total is not reconciled');
const tuner = rcsHead('spear-rf-code-legacy/rfApp/Db/rf_cav.db,v');
for (const field of ['field(ACCL,".5")', 'field(VELO,"3")', 'field(MRES,"400")', 'field(DIST,"0.003175")']) {
  check(tuner.includes(field), `Tuner source default changed: ${field}`);
}
const record = rcsHead('spear-rf-code-legacy/stepper/stepper/steppermotorRecord.dbd,v');
check(record.includes('Seconds to Velocity') && record.includes('Velocity Rotation/Sec'), 'Stepper unit definitions changed');

if (!sourceOnly) {
  const log = read(path.join(directory, `${job}.log`));
  const diagnostics = log.match(/^! .*|Missing character:.*|^.*(?:Reference|Citation).*undefined.*|^Overfull \\[hv]box.*|^LaTeX Warning: Float too large.*|^.*destination.*does not exist.*|^Package hyperref Warning: Token not allowed.*/gm) || [];
  failures.push(...diagnostics);
  check(!/Label\(s\) may have changed|Rerun to get cross-references right/.test(log), 'LaTeX needs another reference pass');
  const pdf = execFileSync('pdftotext', [path.join(directory, `${job}.pdf`), '-'], { encoding: 'utf8', maxBuffer: 3e7 });
  check(!/p\.\s*\?\?/.test(pdf), 'Unresolved page number in PDF');
  // Derived from the title block so a revision/status change cannot silently drift.
  const status = main.match(/\\textbf\{Status\}\s*&\s*(.+?)\s*\\\\/)?.[1];
  check(Boolean(status), 'Front-matter Status row not found');
  if (status) {
    check(pdf.includes(status), `Front-matter status missing from rendered PDF: ${status}`);
    const revision = main.match(/\\textbf\{Revision\}\s*&\s*(.+?)\s*\\\\/)?.[1];
    const subject = main.match(/pdfsubject=\{([^}]*)\}/)?.[1] || '';
    check(subject.includes(revision) && subject.includes(status),
      `pdfsubject "${subject}" disagrees with the title block (${revision}, ${status})`);
  }
  console.log(`PDF pages: ${log.match(/Output written on .*\((\d+) pages/)?.[1] || 'unknown'}`);
}

for (const failure of failures) console.error(`FAIL: ${failure}`);
console.log(`Doc L ${sourceOnly ? 'source' : 'release'} checks: ${failures.length ? 'FAIL' : 'PASS'} (${failures.length} issues)`);
process.exitCode = failures.length ? 1 : 0;