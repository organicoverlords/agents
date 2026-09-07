# Cross-repository documentation

`organicoverlords/agents` is the canonical home for human-facing documentation across the current stack. This directory preserves the former `organicoverlords/docs` content inside that single authority.

## Where things live

| What | Canonical owner |
| --- | --- |
| Project direction / North Star | `organicoverlords/agents` under `docs/repos/<repo>/` |
| Human README, guides, runbooks, and project history | `organicoverlords/agents` under `docs/repos/<repo>/` |
| Cross-repository documentation standards | `organicoverlords/agents` under `docs/repos/docs/standards/` |
| Shared agent policy | `C:\Users\Lauri\.agents\RULES.md` and `C:\Users\Lauri\.agents\AGENTS.md`, version-controlled by `organicoverlords/agents` |
| Repo-local machine contracts and artifact-bound evidence | the owning product repository |
| Work state and proof of landing | the owning repository's GitHub issues, PRs, checks, git state, and runtime evidence |

Product repositories may keep short compatibility pointers at historical documentation paths. A local Markdown file may remain substantive only when automation, packaging, a runtime, or an artifact contract consumes it. Human prose must not be maintained in both places.

## Standards

- [`standards/changelog.md`](standards/changelog.md) defines the human changelog contract under the central Agents authority.
- Seed content for a new canonical changelog is in [`standards/templates/CHANGELOG.md`](standards/templates/CHANGELOG.md).

## Legacy `organicoverlords/docs` repository

The standalone `organicoverlords/docs` repository is now a compatibility surface only. Its Markdown paths point here so existing links remain navigable; edits to human-facing standards or direction belong in this Agents repository.
