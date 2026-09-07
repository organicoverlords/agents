# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).
The rule this file follows is [`standards/changelog.md`](standards/changelog.md).

## [Unreleased]

### Added

- `NORTH_STAR.md` for this repo.

- Canonical org-wide changelog standard at `standards/changelog.md`: `CHANGELOG.md` at every
  repo root, Keep a Changelog 1.1.0 format, SemVer 2.0.0, entry written in the same PR as the
  change.
- Seed template at `standards/templates/CHANGELOG.md` for new and adopting repositories.

### Changed

- Documentation authority moved from `organicoverlords/docs` to `organicoverlords/agents` under `docs/repos/docs/`; the former repository now serves compatibility pointers only (`organicoverlords/docs#4`, `organicoverlords/agents#149`).

- `AGENTS.md` shared policy raised to v1.2, adding a hard rail on deleting irreplaceable data
  (masters, assets, evidence) after an agent destroyed a set of masters, plus non-blocking
  defaults for disk reclaim, branch prune-on-merge, and full-target builds for anything CI or a
  runtime loads. The visual-proof gate is explicitly excluded from those relaxations.

- `README.md` is now an index of cross-repo standards rather than a placeholder.

[Unreleased]: https://github.com/organicoverlords/agents/commits/main/docs/repos/docs
