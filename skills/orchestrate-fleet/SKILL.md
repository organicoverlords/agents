---
name: orchestrate-fleet
description: Use when the user explicitly asks a ChatGPT Web tab to orchestrate or orient the whole worker fleet, check the five timed chats, or give fleet status.
---

# Orchestrate Fleet

Use ChatGPT saved memory as the durable workflow contract and live MCP, GitHub, and machine state as current truth.

If that saved workflow is missing or stale, load entry 2 from `C:\Users\Lauri\.agents\chatgpt-memory-seed.md` through MCP and reconcile saved memory automatically. Never ask the operator to copy it.

Perform the explicit full-fleet sweep: reconcile the five timed chats, live workers, shared work, stale state, and machine pressure; steer or rearm work where needed; give the compact outcome report defined in saved memory; then continue useful work automatically.

Do not centralize resilience. Every worker can see the fleet, clear stale blockers, coordinate around collisions, choose another route, and continue. Each worker owns its own GitHub and MCP BUSY lifecycle.
