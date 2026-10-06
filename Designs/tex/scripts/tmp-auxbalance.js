// throwaway: report .aux lines whose braces do not balance
const fs = require('fs');
const file = process.argv[2];
const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
lines.forEach((line, i) => {
  let depth = 0;
  for (let k = 0; k < line.length; k++) {
    if (line[k] === '\\') { k++; continue; }
    if (line[k] === '{') depth++;
    else if (line[k] === '}') depth--;
  }
  if (depth !== 0) console.log(`${i + 1}\t${depth > 0 ? '+' : ''}${depth}\t${line.slice(0, 160)}`);
});
