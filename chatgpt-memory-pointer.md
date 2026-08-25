# ChatGPT saved memory

Saved memory is empty. That is the design, not an oversight.

The bootstrap instruction lives in custom instructions, which are injected into every
conversation anyway, so a copy in memory would be the same rule stored twice — the
duplication that lets one copy be corrected while the other goes stale. Memory is also
the weakest authority and the only layer that drifts without leaving a diff: on
2026-08-25 it simultaneously held a stale MCP-primary routing rule, an unscoped "I am
the orchestrator of the agent fleet" claim that every chat would read as its own, and
the only surviving copy of the LowVRAM operational facts, which now live in
`lowvram3d-studio/docs/QUEUE_RUNBOOK.md`.

Behaviour, routing, fleet contract and machine facts are in
`C:\Users\Lauri\.agents\chatgpt-memory-seed.md`. Repository rules are in each repo's
AGENTS.md. Neither is restated here.

If saved memory ever contains anything, it has drifted. Delete it rather than
reconciling it, then check whether what it held exists in the seed or a repo document
and move it there if it does not.

## Emergency fallback only

If custom instructions are unavailable in some surface, this single entry restores
bootstrap and nothing else:

BOOTSTRAP. Before working, load the bootstrap seed once through MCP by reading
`C:\Users\Lauri\.agents\chatgpt-memory-seed.md`. Reload after any reset or version
change. Do not open the Files/Library copy in a conversation that will use MCP — it
anchors the tool surface and the connector rarely returns. Behaviour rules, routing,
fleet contract and machine facts are in that seed; repo operating policy is in each
repo's AGENTS.md. Memory is the weakest authority — on conflict follow the seed and
AGENTS.md and say memory was stale.
