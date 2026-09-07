# Changelog standard

**Status: canonical. Applies to every `organicoverlords` repository, from 2026-08-24.**

Each current repository has one canonical human changelog in `organicoverlords/agents` at
`docs/repos/<repo>/CHANGELOG.md`, using [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

A product repository may retain a root `CHANGELOG.md` only as a compatibility pointer or a minimal
machine projection when a live workflow, package, runtime, or artifact contract consumes that path.
Do not maintain the same human prose in both places. Start a new canonical changelog from
[`templates/CHANGELOG.md`](templates/CHANGELOG.md).

## Why

The backlog says what we intend to do and the issues say what we proved. Neither says what
actually changed for the person using the thing. A commit log is not a substitute: it is
full of noise, written for the diff rather than the reader, and nobody outside the branch
can read it. One changelog per repo, written as the change lands, is the whole standard.

## The rules

1. **The canonical human `CHANGELOG.md` lives in Agents at `docs/repos/<repo>/CHANGELOG.md`.** A repo-root file is pointer/projection compatibility only unless machine ownership is proven.
2. **`## [Unreleased]` stays at the top, always.** New entries land there.
3. **Write the entry in the same commit or PR as the change.** Not at release time, not in a
   catch-up sweep. A changelog that mentions only some of the changes is as dangerous as no
   changelog at all.
4. **Use exactly these six headings, in this order, omitting the empty ones:**

   | Heading | For |
   | --- | --- |
   | `Added` | new features |
   | `Changed` | changes in existing functionality |
   | `Deprecated` | soon-to-be removed features |
   | `Removed` | now removed features |
   | `Fixed` | any bug fixes |
   | `Security` | vulnerabilities |

   No other headings. No `Misc`, no `Internal`, no `Chore`.
5. **One line per entry, written for a human**, ending with the issue or PR number:
   `- Sprint combat effects are now server-authoritative; clients can no longer apply damage locally (#494).`
   Not `- refactor UP3GameplaySprintComponent per review`.
6. **Deprecate before you remove.** A `Deprecated` entry, then the `Removed` entry in a later
   version. Silent removals are the failure this standard exists to prevent.
7. **Skip the entry only when a change has no observable effect**: pure formatting,
   comment-only edits, lockfile churn, CI noise. When in doubt, write the line.
8. **Releasing** = rename `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD`, open a fresh empty
   `## [Unreleased]` above it, update the link block at the bottom. Latest version first.
9. **Dates are ISO 8601, `YYYY-MM-DD`.** No regional formats.
10. **Never rewrite a released section.** Correct it with a new entry in a later version. A
    release pulled after publishing is marked `## [1.4.0] - 2026-08-01 [YANKED]`.
11. **Versions and sections are linkable.** Keep the comparison links at the bottom of the file
    current so every heading resolves to a real diff.
12. **The changelog is a product record, not a proof record.** It is not a coordination
    surface, not a BUSY marker, not a receipt, and never evidence that something was proven.
    `PROVENANCE=<actor>`, `PROVEN`/`NOT_PROVEN`, run ids and receipt hashes belong in the
    issue or PR, never here.

## Version numbers

`MAJOR.MINOR.PATCH`: incompatible API/contract change, backward-compatible capability,
backward-compatible fix. For repos with no external consumer — a game project, a research
tree — the same numbering still applies, read against the project's own contracts: a save
format, a schema, a script interface, a runtime API another repo calls.

A repo that has never cut a release simply has an `## [Unreleased]` section and nothing else.
That is a valid changelog, and it is the state every new repo starts in.

## Adoption

Existing repos do not backfill history. Add the canonical file under `organicoverlords/agents`
with an `## [Unreleased]` section and, optionally, one `## [0.1.0]` line marking the point of
adoption. Keep a repo-root compatibility pointer only when stable links or machine consumers need it.
Everything from that day forward gets an entry in the canonical Agents copy.
