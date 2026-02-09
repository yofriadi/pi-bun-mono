# Add Root bunfig.toml for Deterministic Bun Install and Markdown Loader (bd-3e3)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, the repository has an explicit Bun configuration file at the root with deterministic install behavior and markdown text-loader support. Contributors can verify the feature by opening `bunfig.toml` and confirming `[install].exact = true` and `[loader].".md" = "text"`.

## Progress

- [x] (2026-02-09 12:52Z) Claimed issue `bd-3e3` and confirmed `bunfig.toml` does not already exist.
- [x] (2026-02-09 12:52Z) Created this ExecPlan at `.agent/execplans/bd-3e3-phase-1-package-infrastructure-bunfig-toml.md`.
- [x] (2026-02-09 12:53Z) Created root `bunfig.toml` with requested `install` and `loader` sections.
- [x] (2026-02-09 12:53Z) Validated file content via `cat bunfig.toml`.
- [ ] Commit issue-scoped files and add Beads progress note with commit hash.
- [ ] Close `bd-3e3`, flush Beads sync, and fetch next READY issue.

## Surprises & Discoveries

- Observation: No root Bun config file exists yet.
  Evidence: `ls bunfig.toml` returned "No such file or directory".

## Decision Log

- Decision: Create only the two requested Bun config sections with exact values from the issue.
  Rationale: The issue is narrowly scoped and does not request any additional Bun settings.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestones 1 and 2 are complete. Root Bun configuration now exists with deterministic install and markdown text-loader settings. Remaining work is commit and Beads closure.

## Context and Orientation

`bunfig.toml` is Bun's repository-level configuration file. The issue requires two settings:

- `[install].exact = true` for deterministic dependency version recording.
- `[loader].".md" = "text"` so markdown files can be imported as raw text content.

No other files are in scope.

## Plan of Work

Milestone 1 creates `bunfig.toml` with exact requested content.

Milestone 2 validates by printing file content.

Milestone 3 commits file and plan, writes Beads progress note, closes issue, syncs, and returns to READY queue.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Create config file:

       write bunfig.toml with install/loader sections

2. Validate:

       cat bunfig.toml

3. Commit and track:

       git add bunfig.toml .agent/execplans/bd-3e3-phase-1-package-infrastructure-bunfig-toml.md
       git commit -m "chore(root): add bunfig for deterministic installs and md loader"
       br comments add bd-3e3 --message "Added root bunfig.toml. Commit: <hash>"
       br close bd-3e3 --reason "Completed"
       br sync --flush-only
       br ready --json

## Validation and Acceptance

Acceptance is met when:

- `bunfig.toml` exists at repository root.
- File content matches exactly:
  - `[install]` with `exact = true`
  - `[loader]` with `".md" = "text"`

## Idempotence and Recovery

Creating `bunfig.toml` with fixed static content is idempotent. Re-running file creation with same content yields no net change. If typo occurs, replace with exact required values before commit.

## Artifacts and Notes

Artifacts to capture:

- `cat bunfig.toml` output
- Commit hash and `br close` confirmation

## Interfaces and Dependencies

Only one new file interface is introduced: root `bunfig.toml`. No code module or dependency changes are made.

Revision Note (2026-02-09 12:52Z, Codex): Initial ExecPlan created because issue `bd-3e3` had no ExecPlan path and required a self-contained implementation guide.
Revision Note (2026-02-09 12:53Z, Codex): Updated progress and outcomes after creating and validating `bunfig.toml`.
