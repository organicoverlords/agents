#!/usr/bin/env node
// Single source of truth for shared agent policy.
//   node sync-agent-policy.mjs                   -> read-only local drift check
//   node sync-agent-policy.mjs --apply           -> write only the local generated block
//   node sync-agent-policy.mjs --check-remotes   -> fetch and verify git-backed origin defaults
import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

const HERE = path.dirname(new URL(import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, "$1"));
const SOURCE = path.join(HERE, "SHARED-AGENT-POLICY.md");
const SOURCE_DISPLAY = "C:\\Users\\Lauri\\.agents\\SHARED-AGENT-POLICY.md";
const BEGIN = "<!-- SHARED-AGENT-POLICY:BEGIN -->";
const END = "<!-- SHARED-AGENT-POLICY:END -->";
const NOTE = `<!-- Generated from ${SOURCE_DISPLAY}. Do not edit between these markers; edit the source and run sync-agent-policy.mjs. -->`;

const DEFAULT_TARGETS = [
  "C:/Users/Lauri/Documents/Unreal Projects/p3/AGENTS.md",
  "C:/Users/Lauri/Desktop/lowvram3d-repo/AGENTS.md",
  "C:/Users/Lauri/Desktop/AGENTS.md",
  "C:/Users/Lauri/Desktop/tiny3d/AGENTS.md",
  "C:/Users/Lauri/Desktop/vault/AGENTS.md",
  // global harness homes
  "C:/Users/Lauri/.codex/AGENTS.md",
  "C:/Users/Lauri/.claude/CLAUDE.md",
  "C:/Users/Lauri/.config/opencode/AGENTS.md",
  "C:/Users/Lauri/.traycer/agent-selection-guide.md",
];
const TARGETS = process.env.POLICY_SYNC_TARGETS
  ? process.env.POLICY_SYNC_TARGETS.split(path.delimiter).filter(Boolean)
  : DEFAULT_TARGETS;

const body = fs.readFileSync(SOURCE, "utf-8").replace(/\r\n?/g, "\n").trim();
const block = `${BEGIN}\n${NOTE}\n## Shared agent policy\n\n${body}\n${END}`;
const apply = process.argv.includes("--apply");
const explicitCheck = process.argv.includes("--check");
const checkRemotes = process.argv.includes("--check-remotes");
const modeCount = Number(apply) + Number(explicitCheck) + Number(checkRemotes);
if (modeCount > 1) {
  console.error("POLICY_SYNC_MODE_CONFLICT=choose-one-of---apply---check---check-remotes");
  process.exit(2);
}
const check = !apply && !checkRemotes;

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

function git(args, cwd, { trim = true } = {}) {
  try {
    const value = execFileSync("git", args, { cwd, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });
    return trim ? value.trim() : value;
  } catch {
    return null;
  }
}
function normalize(text) { return text.replace(/\r\n/g, "\n"); }
function generatedBlock(text) {
  const value = normalize(text);
  const start = value.indexOf(BEGIN);
  const stop = value.indexOf(END);
  if (start === -1 || stop === -1 || stop <= start) return null;
  return value.slice(start, stop + END.length);
}
function gitRootFor(target) {
  const dir = path.dirname(target);
  if (!fs.existsSync(dir)) return null;
  return git(["rev-parse", "--show-toplevel"], dir);
}
function originDefaultRef(root) {
  let ref = git(["symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD"], root);
  if (ref) return ref;
  for (const candidate of ["origin/main", "origin/master"]) {
    if (git(["rev-parse", "--verify", candidate], root)) return candidate;
  }
  return null;
}

if (checkRemotes) {
  const roots = new Map();
  const skipped = [];
  for (const target of TARGETS) {
    const root = gitRootFor(target);
    if (!root) { skipped.push(target); continue; }
    const list = roots.get(root) || [];
    list.push(target);
    roots.set(root, list);
  }

  const drifted = [], missing = [], unavailable = [];
  for (const [root, targets] of roots.entries()) {
    if (git(["fetch", "origin", "--quiet"], root) === null) {
      unavailable.push(`${root} (fetch origin failed)`);
      continue;
    }
    const ref = originDefaultRef(root);
    if (!ref) {
      unavailable.push(`${root} (origin default ref unavailable)`);
      continue;
    }
    for (const target of targets) {
      const rel = path.relative(root, target).split(path.sep).join("/");
      const remoteText = git(["show", `${ref}:${rel}`], root, { trim: false });
      if (remoteText === null) { missing.push(`${root} ${ref}:${rel}`); continue; }
      const remoteBlock = generatedBlock(remoteText);
      if (remoteBlock !== block) drifted.push(`${root} ${ref}:${rel}`);
    }
  }

  for (const x of drifted) console.log("REMOTE_DRIFTED  " + x);
  for (const x of missing) console.log("REMOTE_MISSING  " + x);
  for (const x of unavailable) console.log("REMOTE_UNAVAILABLE  " + x);
  for (const x of skipped) console.log("REMOTE_SKIPPED_NON_GIT  " + x);
  if (drifted.length || missing.length || unavailable.length) {
    console.log(`\n${drifted.length} remote drifted, ${missing.length} remote missing, ${unavailable.length} remote unavailable, ${skipped.length} non-git skipped`);
    process.exit(1);
  }
  console.log(`all ${roots.size} git-backed origin defaults match the source; ${skipped.length} non-git targets skipped`);
  process.exit(0);
}

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
  console.log(`all ${TARGETS.length} local targets match the source`);
} else {
  if (missing.length || malformed.length) process.exit(1);
  console.log(`\n${changed} updated, ${TARGETS.length - changed - missing.length} already current`);
}
