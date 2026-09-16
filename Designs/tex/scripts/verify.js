// Verify a converted document against its markdown source.
//   node Designs/tex/scripts/verify.js P
const fs = require('fs');
const { execFileSync } = require('child_process');

const DOCS = {
  P: { md: 'Designs/P_RF_PHYSICS_AND_PLANT.md',
       pdf: 'Designs/tex/docP-rf-physics/P_rf_physics_and_plant.pdf',
       tex: 'Designs/tex/docP-rf-physics/body.tex',
       startAt: '## Document Scope and Provenance',
       facts: ['476.3', '2.85', '712', '3.73', 'robinson', 'synchrotron', 'klystron',
               'comb filter', 'woofer', 'enerpro', 'perveance', 'detuning angle',
               'i/q', 'detuning', 'beam loading', 'dsp1610', 'schwarz', 'mcintosh'] },
  T: { md: 'Designs/T_TUNER_CONTROL_SYSTEM_ANALYSIS.md',
       pdf: 'Designs/tex/docT-tuner-control/T_tuner_control_analysis.pdf',
       tex: 'Designs/tex/docT-tuner-control/body.tex',
       startAt: '# Part I — What and Why',
       facts: ['1746-hstp1', 'steppermotor', 'dmc-4143', 'load angle',
               'iqa', 'subiqphaseerr', 'dmov', 'rdbd', 'loop_on', 'park',
               'phase offset', 'home', 'detun'] },
};
const key = process.argv[2];
const d = DOCS[key];
if (!d) throw new Error('usage: verify.js <P|T>');

const md = fs.readFileSync(d.md, 'utf8');
const body = md.slice(md.indexOf(d.startAt));
const tex = fs.readFileSync(d.tex, 'utf8');
const pdf = execFileSync('pdftotext', [d.pdf, '-'], { encoding: 'utf8', maxBuffer: 6e7 });
const P = pdf.replace(/\s+/g, ' ').toLowerCase();
const norm = s => s.replace(/\s+/g, ' ').toLowerCase();

const heads = [...body.matchAll(/^#{2,3}\s+(?:\d+(?:\.\d+)*\.?\s+)?(.+)$/gm)]
  .map(m => m[1].replace(/[`*⚠]/g, '').trim())
  .filter(h => h && !/^Appendix|^Part /i.test(h));
const missing = heads.filter(h => {
  const k = norm(h.replace(/\s*[—(:].*$/, '')).slice(0, 22);
  return k.length > 8 && !P.includes(k);
});
const missFacts = d.facts.filter(f => !P.includes(norm(f)));

// equations: markdown ```math blocks + $$..$$  vs  LaTeX display math
const mdMath = (body.match(/```math/g) || []).length + (body.match(/\$\$/g) || []).length / 2;
const texMath = (tex.match(/\\\[/g) || []).length;
const eqTagsMd = new Set([...body.matchAll(/\(Eq\.\s*([\d.]+[a-z]?)\)/g)].map(m => m[1]));
const eqTagsPdf = new Set([...pdf.matchAll(/\(Eq\.\s*([\d.]+[a-z]?)\)/g)].map(m => m[1]));
const lostTags = [...eqTagsMd].filter(x => !eqTagsPdf.has(x));

console.log(`=== Doc ${key} ===`);
console.log(`headings ${heads.length}, missing ${missing.length}`);
missing.forEach(h => console.log('   MISSING: ' + h));
console.log(`key facts ${d.facts.length}, missing ${missFacts.length}`);
missFacts.forEach(f => console.log('   MISSING: ' + f));
console.log(`display equations: markdown ${mdMath} -> latex ${texMath}`);
console.log(`equation tags: markdown ${eqTagsMd.size}, in pdf ${eqTagsPdf.size}, lost ${lostTags.length}`);
if (lostTags.length) console.log('   LOST: ' + lostTags.join(', '));
console.log(`tables: md rows ${(body.match(/^\|.*\|\s*$/gm) || []).length}, ` +
            `latex longtables ${(tex.match(/\\begin\{longtable\}/g) || []).length}`);
console.log(`figures in pdf ${(pdf.match(/^Figure \d+:/gm) || []).length}`);
console.log(`words: md ${norm(body.replace(/```[\s\S]*?```/g, '')).split(' ').length} -> pdf ${P.split(' ').length}`);
