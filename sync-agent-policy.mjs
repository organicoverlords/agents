#!/usr/bin/env node
// Single source of truth for shared agent policy.
//   node sync-agent-policy.mjs          -> read-only drift check
//   node sync-agent-policy.mjs --apply  -> write only the generated block
import fs from "node:fs";
import path from "node:path";

const HERE = path.dirname(new URL(import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, "$1"));
const SOURCE = path.join(HERE, "SHARED-AGENT-POLICY.md");
const BEGIN = "<!-- SHARED-AGENT-POLICY:BEGIN -->";
const END = "<!-- SHARED-AGENT-POLICY:END -->";
const NOTE = `<!-- Generated from ${SOURCE}. Do not edit between these markers; edit the source and run sync-agent-policy.mjs. -->`;

const DEFAULT_TARGETS = [
  "C:/Users/Lauri/Documents/Unreal Projects/p3/AGENTS.md",
  "C:/Users/Lauri/Desktop/TinyLab/AGENTS.md",
  "C:/Users/Lauri/Desktop/lowvram3d-repo/AGENTS.md",
  "C:/Users/Lauri/Desktop/lowvram3d-studio-p0a-worktree/AGENTS.md",
  "C:/Users/Lauri/Desktop/AGENTS.md",
  "C:/Users/Lauri/Desktop/tiny3d/AGENTS.md",
  "C:/Users/Lauri/Desktop/regression-research/AGENTS.md",
  // global harness homes
  "C:/Users/Lauri/.codex/AGENTS.md",
  "C:/Users/Lauri/.config/opencode/AGENTS.md",
  "C:/Users/Lauri/.traycer/agent-selection-guide.md",
];
const TARGETS = process.env.POLICY_SYNC_TARGETS
  ? process.env.POLICY_SYNC_TARGETS.split(path.delimiter).filter(Boolean)
  : DEFAULT_TARGETS;

const body = fs.readFileSync(SOURCE, "utf-8").trim();
const block = `${BEGIN}\n${NOTE}\n## Shared agent policy\n\n${body}\n${END}`;
const apply = process.argv.includes("--apply");
const explicitCheck = process.argv.includes("--check");
if (apply && explicitCheck) {
  console.error("POLICY_SYNC_MODE_CONFLICT=--apply+--check");
  process.exit(2);
}
const check = !apply;

// The block is the one artifact every repo must carry, so it gets the same kind of
// mechanical limit the repos apply to AGENTS.md. lowvram3d-studio caps AGENTS.md at
// 12000 bytes; a block anywhere near that leaves no room for a repo's own section and
// is a sign the policy is growing by accretion again. Trim the source, do not raise this.
const MAX_BLOCK_BYTES = 8000;
const blockBytes = Buffer.byteLength(block, "utf-8");
if (blockBytes > MAX_BLOCK_BYTES) {
  console.error(`POLICY_BLOCK_TOO_LARGE_BYTES=${blockBytes} max=${MAX_BLOCK_BYTES}`);
  console.error("Trim SHARED-AGENT-POLICY.md. Detail belongs in a doc with one owner, not here.");
  process.exit(1);
}
console.log(`policy block ${blockBytes} / ${MAX_BLOCK_BYTES} bytes`);

let changed = 0, drifted = [], missing = [], malformed = [];
for (const target of TARGETS) {
  if (!fs.existsSync(target)) { missing.push(target); continue; }
  const original = fs.readFileSync(target, "utf-8");
  const eol = original.includes("\r\n") ? "\r\n" : "\n";
  const targetBlock = block.split("\n").join(eol);
  const start = original.indexOf(BEGIN);
  const stop = original.indexOf(END);

  let next;
  if (start !== -1 && stop !== -1 && stop > start) {
    next = original.slice(0, start) + targetBlock + original.slice(stop + END.length);
  } else if (start !== -1 || stop !== -1) {
    malformed.push(target);
    continue;
  } else {
    // Insert after the first heading without normalizing any existing byte.
    const heading = original.match(/^# .*?(?:\r?\n|$)/m);
    const at = heading ? heading.index + heading[0].length : 0;
    next = original.slice(0, at) + eol + targetBlock + eol + original.slice(at);
  }

  if (next === original) continue;
  if (check) { drifted.push(target); continue; }
  fs.writeFileSync(target, next);
  console.log("updated  " + target);
  changed++;
}

for (const m of missing) console.log("MISSING  " + m);
for (const m of malformed) console.log("MALFORMED  " + m);
if (check) {
  if (drifted.length || missing.length || malformed.length) {
    drifted.forEach((d) => console.log("DRIFTED  " + d));
    console.log(`\n${drifted.length} drifted, ${missing.length} missing, ${malformed.length} malformed`);
    process.exit(1);
  }
  console.log(`all ${TARGETS.length} targets match the source`);
} else {
  if (missing.length || malformed.length) process.exit(1);
  console.log(`\n${changed} updated, ${TARGETS.length - changed - missing.length} already current`);
}
