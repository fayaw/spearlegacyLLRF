const fs = require('fs');
const { execFileSync } = require('child_process');
const md = fs.readFileSync('Designs/I_INTERLOCK_ARCHITECTURE.md', 'utf8');
const pdf = execFileSync('pdftotext',
  ['Designs/tex/docI-interlock-architecture/I_interlock_architecture.pdf', '-'],
  { encoding: 'utf8', maxBuffer: 6e7 });
const P = pdf.replace(/\s+/g, ' ').toLowerCase();
const norm = s => s.replace(/\s+/g, ' ').toLowerCase();

// drop the TOC block from the markdown before harvesting headings
const bodyMd = md.slice(md.indexOf('## Background'));
const heads = [...bodyMd.matchAll(/^###\s+(?:\d+\.\d+\s+)?(.+)$/gm)].map(m => m[1].trim());
const missing = heads.filter(h => {
  const k = norm(h.replace(/[`*]/g, '').replace(/\s*[—(].*$/, '')).slice(0, 22);
  return k.length > 8 && !P.includes(k);
});

const FACTS = ['340-308', '340-307', 'arcltdstt', 'arccurstt', 'hisbuf', 'devp2rfaim',
  'rf_states.st', 's_go_off', 'stnoff:sumy:stat', 'gob1208pne', '1747-dcm', 'ab-6008',
  'remote i/o', 'triplvl', 'bats', 'fistat', 'aimhist.dat', 'ross', 'crowbar',
  'slot 5', 'slot 12', 'orbit interlock', 'hvpsonsub', 'fault:num', 'danfysik'];
const missFacts = FACTS.filter(f => !P.includes(norm(f)));

console.log(`subsection headings ${heads.length}, missing ${missing.length}`);
missing.forEach(h => console.log('   MISSING: ' + h));
console.log(`key facts ${FACTS.length}, missing ${missFacts.length}`);
missFacts.forEach(f => console.log('   MISSING: ' + f));

const tables = (bodyMd.match(/^\|.*\|\s*$/gm) || []).length;
console.log(`\nmarkdown table rows ${tables}`);
console.log(`figures in pdf      ${(pdf.match(/^Figure \d+:/gm) || []).length}`);
console.log(`timelines rendered  ${(fs.readFileSync('Designs/tex/docI-interlock-architecture/body.tex','utf8').match(/\\begin\{timeline\}/g)||[]).length}`);
const mdW = norm(bodyMd.replace(/```[\s\S]*?```/g, '')).split(' ').length;
console.log(`markdown words ${mdW}  ->  pdf words ${P.split(' ').length}`);
