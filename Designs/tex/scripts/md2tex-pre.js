// Doc I: Markdown -> LaTeX, stage 1 (preprocess).
// Structural directives are passed to pandoc as plain-text "ZZKIND|..." lines,
// because pandoc escapes backslashes in its input and would mangle real macros.
const fs = require('fs');

let md = fs.readFileSync('Designs/I_INTERLOCK_ARCHITECTURE.md', 'utf8');

// --- strip front matter that LaTeX owns: title block, revision history, TOC ---
const revStart = md.indexOf('## Revision History');
const bgStart = md.indexOf('## Background');
if (revStart < 0 || bgStart < 0) throw new Error('front matter markers not found');
const frontMatter = md.slice(0, bgStart);
md = md.slice(bgStart);
fs.writeFileSync('.tmp_docI_front.md', frontMatter);

// --- classify and replace fenced blocks -------------------------------------
const diagrams = [], timelines = [], literals = [];
md = md.replace(/```(\w*)\r?\n([\s\S]*?)```/g, (all, lang, bodyRaw) => {
  const body = bodyRaw.replace(/\s+$/, '');
  const isTimeline = /^\s*t\s*[=<>≈]/m.test(body) && body.split('\n').length > 8;
  const isArt = /[\u2500-\u257F]/.test(body);
  if (isTimeline) {
    timelines.push(body);
    return `\n\nZZTIMELINE|${timelines.length - 1}\n\n`;
  }
  if (isArt) {
    diagrams.push(body);
    return `\n\nZZFIG|${diagrams.length - 1}\n\n`;
  }
  literals.push({ lang, body });
  return `\n\nZZLIT|${literals.length - 1}\n\n`;
});

// --- headings ----------------------------------------------------------------
// "## Part IV — Title"  -> section (auto-numbers 1..10 == Part I..X)
// "### 4.6 Title"       -> subsection (auto-numbers 4.6)
// "## Background"       -> unnumbered
// "## Appendix A — T"   -> appendix section
const parts = [], appendices = [];
md = md.replace(/^##\s+Part\s+([IVX]+)\s*[—-]\s*(.+)$/gm, (a, roman, title) => {
  parts.push(title.trim());
  return `## ${title.trim()}`;
});
md = md.replace(/^##\s+Appendix\s+([A-C])\s*[—-]\s*(.+)$/gm, (a, letter, title) => {
  appendices.push({ letter, title: title.trim() });
  return `ZZAPPENDIX|${letter}\n\n## ${title.trim()}`;
});
md = md.replace(/^##\s+Background\s*$/m, 'ZZUNNUMBERED\n\n## Background');
// strip the manual "N.M " number from subsection titles; LaTeX regenerates it
md = md.replace(/^###\s+(\d+\.\d+)\s+(.+)$/gm, (a, num, title) => `### ${title.trim()}`);
md = md.replace(/^####\s+(\d+\.\d+\.\d+)\s+(.+)$/gm, (a, num, title) => `#### ${title.trim()}`);

// Promote every heading one level so that, with --top-level-division=section,
// the ten Parts land on \section and auto-number 1..10 == Part I..X.
md = md.replace(/^(#{2,4})\s+/gm, (a, h) => h.slice(1) + ' ');

fs.writeFileSync('.tmp_docI_pre.md', md);
fs.writeFileSync('.tmp_docI_blocks.json', JSON.stringify(
  { diagrams, timelines, literals, parts, appendices }, null, 1));

console.log(`parts       ${parts.length}  -> ${parts.join(' | ')}`);
console.log(`appendices  ${appendices.length}`);
console.log(`diagrams    ${diagrams.length}`);
console.log(`timelines   ${timelines.length}`);
console.log(`literals    ${literals.length}`);
console.log(`\nwrote .tmp_docI_pre.md (${Math.round(md.length / 1024)} KB)`);
