#!/usr/bin/env node
// Bootstrap seed publication and verification. Deliberately MCP-free: the seed must
// stay recoverable when no connector is bound, so this only touches local bytes.
//   node publish-seed.mjs             -> print the bytes/SHA-256 to publish
//   node publish-seed.mjs --verify F  -> compare a downloaded Library copy, record on match
//   node publish-seed.mjs --check     -> fail if the seed changed since the last verified publish
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";

const HERE = path.dirname(new URL(import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, "$1"));
const SEED = path.join(HERE, "chatgpt-memory-seed.md");
const MANIFEST = path.join(HERE, "chatgpt-memory-seed.manifest.json");
const LIBRARY_PATH = "/Agent Bootstrap/chatgpt-memory-seed.md";

const digest = (buf) => crypto.createHash("sha256").update(buf).digest("hex").toUpperCase();

const seed = fs.readFileSync(SEED);
const bytes = seed.length;
const sha = digest(seed);

const verifyAt = process.argv.indexOf("--verify");
if (verifyAt !== -1) {
  const copyPath = process.argv[verifyAt + 1];
  if (!copyPath) {
    console.error("SEED_VERIFY_NO_FILE=pass the downloaded Library copy");
    process.exit(2);
  }
  if (!fs.existsSync(copyPath)) {
    console.error(`SEED_VERIFY_MISSING_FILE=${copyPath}`);
    process.exit(2);
  }
  const copy = fs.readFileSync(copyPath);
  const copySha = digest(copy);
  console.log(`seed  ${bytes} bytes  ${sha}`);
  console.log(`copy  ${copy.length} bytes  ${copySha}`);
  if (copy.length !== bytes || copySha !== sha) {
    console.error("SEED_LIBRARY_MISMATCH=do not replace the previous snapshot");
    process.exit(1);
  }
  // Only a verified copy is recorded as published.
  fs.writeFileSync(
    MANIFEST,
    JSON.stringify({ libraryPath: LIBRARY_PATH, bytes, sha256: sha }, null, 2) + "\n"
  );
  console.log(`SEED_LIBRARY_MATCH=${LIBRARY_PATH}`);
  console.log("previous snapshot may now be replaced");
  process.exit(0);
}

if (process.argv.includes("--check")) {
  if (!fs.existsSync(MANIFEST)) {
    console.error("SEED_NEVER_PUBLISHED=no verified snapshot recorded");
    process.exit(1);
  }
  const prev = JSON.parse(fs.readFileSync(MANIFEST, "utf-8"));
  if (prev.bytes !== bytes || prev.sha256 !== sha) {
    console.error(`SEED_UNPUBLISHED_CHANGE recorded=${prev.bytes}/${prev.sha256}`);
    console.error(`                        actual=${bytes}/${sha}`);
    console.error(`Publish the new bytes to ${LIBRARY_PATH}, then --verify the download.`);
    process.exit(1);
  }
  console.log(`seed published and verified  ${bytes} bytes  ${sha}`);
  process.exit(0);
}

console.log(`seed ${bytes} bytes  SHA-256 ${sha}`);
console.log(`publish these exact bytes to ${LIBRARY_PATH}`);
console.log("then: node publish-seed.mjs --verify <downloaded copy>");
console.log("replace the previous snapshot only after that verify passes");
