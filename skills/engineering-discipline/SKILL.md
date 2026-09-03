---
name: engineering-discipline
description: Cross-project engineering discipline for substantive coding, debugging, refactoring, architecture, code review, and engineering reports. Composes diagnosis-first debugging, deep-module design, Ponytail minimalism, and unslop communication without overriding repo rules.
---

# Engineering discipline

Current user instruction and the applicable repo `AGENTS.md` outrank this skill. This adds method, not another gate or authority.

## Diagnose

For a non-trivial bug, performance regression, tool failure, or runtime failure, use the available `diagnosing-bugs` skill. Do not replace its phase discipline with this skill. Establish a tight red-capable feedback loop for the exact symptom before serious hypothesis work, then minimise, test ranked hypotheses, instrument narrowly, fix, and regression-test.

## Design

When changing module shape, interface, or seam placement, use `codebase-design`. Prefer deep modules: substantial behaviour behind a small interface at a real seam. One adapter is usually a hypothetical seam; two adapters make the variation real. Do not create an abstraction merely because one implementation might someday need another.

## Implement

After reading the task and tracing the real flow, use this order and stop at the first rung that fully satisfies the requirement:

1. Avoid the change if the requested behaviour already exists or is unnecessary.
2. Reuse the codebase's existing helper, type, or pattern.
3. Use the standard library.
4. Use a native platform feature.
5. Use an already-installed dependency.
6. Use the simplest correct expression.
7. Only then write the minimum custom code.

For bugs, fix the shared root cause rather than patching only the reported path. Non-trivial logic leaves the smallest runnable check that would fail if it breaks, unless repo-local acceptance requires stronger coverage. Never simplify away trust-boundary validation, data-loss protection, security, accessibility, or an explicit requirement.

## Review

Correctness, spec, and acceptance come first. Then use `ponytail-review` as a separate complexity-only lens when a meaningful diff may be over-built. Use `ponytail-audit` only for an explicit or clearly useful repo-wide complexity audit. Neither replaces correctness, security, performance, or repo acceptance review.

## Report

Apply the useful `unslop` principles to user-facing engineering prose: state concrete facts, commands, mechanisms, measurements, and evidence; prefer plain words and active voice where clearer; remove chatbot filler, puffery, vague claims, generic conclusions, and repeated restatement.

Technical precision wins over style heuristics. Preserve exact domain vocabulary, established technical terms, necessary punctuation, citations, and any format the user explicitly requested. Do not mechanically enforce `unslop` rules that make the engineering text less precise.

Finish when the bounded outcome has the smallest correct implementation, focused evidence for the claim, and a concise concrete report.
