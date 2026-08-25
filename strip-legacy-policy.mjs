import fs from "node:fs";
const targets = process.argv.slice(2);
for (const t of targets) {
  const raw = fs.readFileSync(t, "utf-8");
  const eol = raw.includes("\r\n") ? "\r\n" : "\n";
  let lines = raw.split(/\r?\n/);
  const removed = [];
  const keep = [];
  let skippingSection = false;
  for (let i = 0; i < lines.length; i++) {
    const l = lines[i];
    if (skippingSection) {
      if (/^##\s/.test(l)) skippingSection = false; else { removed.push(l); continue; }
    }
    if (l.includes("EXECUTION_CONTINUITY_20260820")) { removed.push(l); continue; }
    if (/^>\s*\*\*Highest priority in this file/.test(l)) { removed.push(l); continue; }
    if (/^##\s+Execution continuity/i.test(l)) { removed.push(l); skippingSection = true; continue; }
    keep.push(l);
  }
  const next = keep.join("\n").replace(/\n{3,}/g, "\n\n").trimEnd() + "\n";
  fs.writeFileSync(t, next.split("\n").join(eol));
  console.log(`\n### ${t}  — removed ${removed.filter(l=>l.trim()).length} non-blank lines`);
  removed.filter(l => l.trim()).forEach(l => console.log("  - " + l.slice(0, 120)));
}
