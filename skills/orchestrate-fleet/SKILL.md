---
name: orchestrate-fleet
description: Use when the user explicitly asks a ChatGPT Web tab to orchestrate or orient the whole worker fleet, check the five timed chats, or give fleet status.
---

# Orchestrate Fleet

Use current automation state, GitHub, BUSY, worker/process, and machine evidence as live truth. Do not bootstrap from broad history. Reconcile automatically and do not ask the operator to supervise workers.

Perform the explicit full-fleet sweep: reconcile the five timed workers, shared work, stale state, and machine pressure; repair or rearm obvious scheduler-health failures; then continue useful work. This skill is a convenience sweep, not an ownership tier.

Do not centralize resilience. Timed workers form a flat self-healing pool: each owns its assigned task and exact BUSY lifecycle, may repair obvious sibling scheduler-liveness faults, and does not steer or reassign peer task scope.

Fan-in is scope-owned rather than coordinator-owned. If a parallel/scout finding is blocked by a live claim, preserve it as scope-visible pending work with provenance and verify it survives release so the next owner can consume it.