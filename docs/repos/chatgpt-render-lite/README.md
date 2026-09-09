# ChatGPT Render Lite

## Purpose

ChatGPT Render Lite is the local Firefox/Chromium extension for reducing RAM, layout, and paint pressure in long ChatGPT conversations. The product source repository is `organicoverlords/chatgpt-render-lite`.

## Canonical source layout

- Chromium/Brave unpacked extension: repository root.
- Firefox build: `firefox-build/`.
- Current Brave unpacked extension ID on KONE: `koodadgggieepgbmonhiijikfeijbfjf`.
- Current Firefox development add-on ID: `chatgpt-render-lite@local`.

Local browser profile paths are runtime installation state, not source authority. The repository is the source authority.

## Safety invariant

RAM optimization may suppress layout/paint work for cold message DOM while retaining ChatGPT's own application state. It must **not** intercept, truncate, replace, or synthesize ChatGPT conversation API responses, and it must not mutate ChatGPT navigation/history to recover from memory pressure.

Allowed optimization boundary:

- mark old rendered turns as cold;
- preserve their measured block height;
- remove cold descendants from layout/paint with extension CSS;
- restore them near the viewport or on a one-shot full-page restore.

Forbidden optimization boundary:

- monkey-patching `window.fetch` for ChatGPT conversation endpoints;
- rewriting `/backend-api/conversation/*` or shared-conversation JSON;
- replacing `mapping`, `root`, or `current_node` in ChatGPT response data;
- navigating to `chatgpt.com/`, changing history, or reloading as an automatic memory-management strategy.

## 2026-09-09 regression

v0.6.0 introduced optional "Aggressive RAM pre-trim" by patching page-world `fetch()` and returning a truncated conversation graph before React rendered it. Brave extension storage shows that option was enabled with a 6-turn limit. While it was active, Render Lite runtime telemetry recorded active `/c/<conversation>` URLs transitioning to plain `https://chatgpt.com/`, matching the reported behavior where a conversation appeared to blank out and browser Back returned to it.

The exact internal ChatGPT router decision is not observable from the extension telemetry, but response rewriting is the only Render Lite path that altered ChatGPT application data and is therefore the regression boundary.

v0.6.1 removes the page-world response rewrite by construction: the pre-trim scripts are absent from the manifest/runtime, the popup no longer exposes the mode, and legacy stored `aggressivePretrim` / `pretrimTurns` settings are stripped by background configuration migration. The normal DOM rendering-sleep path remains.

## Regression checks

Run from the repository root:

`powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\run-static.ps1`

The source regression must prove:

- no `document_start` page-world content script;
- no MAIN-world extension script;
- no pre-trim runtime files;
- no ChatGPT `fetch()` response rewrite in active content code;
- no aggressive pre-trim popup controls;
- legacy unsafe settings are migrated away;
- normal viewport windowing and weekly send-counter behavior remain covered.

## Browser update rule

Change the repository first, validate it, then update/reload the unpacked browser extension from the repository-owned build. Do not treat Brave or Firefox profile state as the implementation owner and do not perform browser-wide repair for a Render Lite regression.
