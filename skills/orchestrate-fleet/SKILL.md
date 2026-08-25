---
name: orchestrate-fleet
description: Use when the user explicitly asks a ChatGPT Web tab to orchestrate or orient the whole worker fleet, check the five timed chats, or give fleet status.
---

# Orchestrate Fleet

Use the bootstrap seed as the durable workflow contract and live MCP, GitHub, and machine state as current truth. Saved memory is a pointer to that seed, not the contract itself.

Load the seed from the Files/Library document `/Agent Bootstrap/chatgpt-memory-seed.md`; entry 2 carries the fleet contract. Read `C:\Users\Lauri\.agents\chatgpt-memory-seed.md` through MCP only when a connector is already bound — MCP is an optional transport here, and an unbound connector never blocks this sweep. Reconcile automatically and never ask the operator to copy it.

Perform the explicit full-fleet sweep: reconcile the five timed chats, live workers, shared work, stale state, and machine pressure; steer or rearm work where needed; give the compact outcome report defined in the bootstrap seed; then continue useful work automatically.

Do not centralize resilience. Every worker can see the fleet, clear stale blockers, coordinate around collisions, choose another route, and continue. Each worker owns its own GitHub and MCP BUSY lifecycle.
