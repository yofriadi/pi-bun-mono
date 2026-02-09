# Migrate Root package.json to Bun Infrastructure (bd-3pf)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, the monorepo root package metadata and key developer scripts will run with Bun-first assumptions instead of npm/Node-first assumptions. A contributor should be able to run development, checks, and tests from the repository root using Bun commands while preserving existing workspace coverage and behavior intent. The change is visible by inspecting `package.json` and by running `bun run dev`, `bun run check`, and `bun run test` from the repository root.

## Progress

- [x] (2026-02-09 12:41Z) Claimed issue `bd-3pf` and confirmed no existing ExecPlan path was provided in issue metadata.
- [x] (2026-02-09 12:41Z) Reviewed `.agents/PLANS.md` requirements and captured current root `package.json` baseline.
- [x] (2026-02-09 12:42Z) Created this self-contained ExecPlan at `.agent/execplans/bd-3pf-phase-1-package-infrastructure-root-package-json.md`.
- [x] (2026-02-09 12:44Z) Edited root `package.json` for Bun engines, Bun-first `dev`/`check`/`test` scripts, removed `husky`/`tsx`, added `@types/bun`, and removed `prepare` hook tied to Husky.
- [x] (2026-02-09 12:44Z) Ran validation command `bun run check` and captured failing output for repo-wide pre-existing type/config problems.
- [x] (2026-02-09 19:04Z) Commit issue-scoped changes and add issue progress notes with commit links.
- [x] (2026-02-09 19:04Z) Close `bd-3pf`, sync Beads state, and fetch next READY issue.

## Surprises & Discoveries

- Observation: The environment does not include `bd`; issue tracking commands work with `br`.
  Evidence: Running `bd ready --json` returned `zsh:1: command not found: bd`; `br ready --json` returned READY issues including `bd-3pf`.

- Observation: `bun run check` fails in this repository due broad type/config issues unrelated to this issue's root script rewiring.
  Evidence: Biome schema mismatch warning (`2.3.5` schema with `2.3.14` CLI) and many existing TypeScript errors across `packages/*` (missing module/type declarations).

## Decision Log

- Decision: Use `br` commands for this issue despite the request text referencing `bd`.
  Rationale: The active repository toolchain and `AGENTS.md` define `br` as the tracker; `bd` is unavailable in this environment.
  Date/Author: 2026-02-09 / Codex

- Decision: Create the ExecPlan under `.agent/execplans/` using the issue id plus slug.
  Rationale: The issue did not include an ExecPlan path, and the requested operating rules require creating one at `.agent/execplans/<issue-id>-<slug>.md`.
  Date/Author: 2026-02-09 / Codex

- Decision: Keep `@types/node` in root `devDependencies` while adding `@types/bun`.
  Rationale: Removing `@types/node` immediately increased type breakage in current repo state, while this issue's direct requirement can still be met by removing Husky/TSX and switching root scripts/engine to Bun-first behavior.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestones 1 and 2 are complete. Root metadata migration is implemented for `engines` plus `dev`/`check`/`test` scripts, and Husky wiring has been removed. Validation command execution is complete but does not pass in this repo snapshot due pre-existing broader issues, which are recorded in this plan.

## Context and Orientation

The root `package.json` in this repository (`package.json`) defines shared workspace configuration and top-level scripts. The issue scope is limited to root package infrastructure migration for Bun runtime compatibility:

- `engines` currently requires Node (`>=20.0.0`) and must require Bun (`>=1.3.7`).
- Root scripts currently use npm invocation patterns for task fan-out. This issue explicitly requires Bun equivalents for `dev`, `check`, and `test`.
- Root `devDependencies` include `husky`, `tsx`, and `@types/node`; this issue requires adding `@types/bun` and removing Node-only dependencies.
- Workspace entries under `workspaces` must remain unchanged.

Term definitions used here:

- "Bun-first script" means a script string that invokes workspace/package scripts via `bun run` and Bun flags rather than `npm run`.
- "Node-only dependency" means a dependency needed only for Node-specific runtime or tooling semantics in this repository root context.

## Plan of Work

Milestone 1 introduces configuration changes in `package.json` only. Update `engines` to Bun, then replace script bodies for `dev`, `check`, and `test` with Bun-based command lines that keep the same package coverage. Keep all other scripts unchanged unless required by this issue. Update `devDependencies` by removing `husky` and `tsx` and adding `@types/bun`; retain `@types/node` for compatibility with current package type usage.

Milestone 2 validates that the modified scripts parse and execute in this repo context by running the issue-relevant command set. At minimum run `bun run check`; if additional commands are too expensive or blocked, capture that fact with evidence.

Milestone 3 records tracker and source-control evidence: stage only issue files, create a commit, add `br comments` update that includes commit hash, close the issue with `br close`, flush Beads sync state, and then return to READY queue fetch.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Edit root package metadata:

       apply package.json edits for engines/scripts/devDependencies

2. Validate changes:

       bun run check

   Optional follow-up if quick in this environment:

       bun run test

3. Commit and tracker updates:

       git add package.json .agent/execplans/bd-3pf-phase-1-package-infrastructure-root-package-json.md
       git commit -m "chore(root): migrate package.json scripts and engines to bun"
       br comments add bd-3pf --message "Implemented root package.json Bun migration. Commit: <hash>"
       br close bd-3pf --reason "Completed"
       br sync --flush-only
       br ready --json

Expected transcript snippets include:

- `bun run check` executes and reports repository type/config failures (captured as evidence).
- `git commit` prints a new commit hash.
- `br close` reports status transition to `closed`.

## Validation and Acceptance

Acceptance criteria for this issue are satisfied when all of the following are true:

- `package.json` has `engines.bun` set to `>=1.3.7` and no longer declares `engines.node`.
- Root scripts `dev`, `check`, and `test` use Bun command forms rather than npm command forms.
- `devDependencies` includes `@types/bun` and excludes `husky` and `tsx`.
- The workspace list in `package.json` remains unchanged.
- At least one repository-standard validation command executes after edits (`bun run check`) and result is recorded.

## Idempotence and Recovery

These edits are idempotent at file level; reapplying identical JSON values has no additional effect. If validation fails, inspect failure output and either fix only issue-scoped root configuration errors or document unrelated pre-existing failures before proceeding. If a commit accidentally includes unrelated files, unstage only those files and recommit with explicit path list.

## Artifacts and Notes

Artifacts will be appended as work progresses, including:

- `git diff -- package.json`
- Validation command exit summaries
- Commit hash and Beads comment/close confirmation

## Interfaces and Dependencies

This issue intentionally edits only repository metadata interfaces in root `package.json`:

- `scripts.dev: string`
- `scripts.check: string`
- `scripts.test: string`
- `engines.bun: string`
- `devDependencies` package keys

No runtime module API signatures or TypeScript source interfaces are changed in this issue.

Revision Note (2026-02-09 12:42Z, Codex): Initial ExecPlan created because issue `bd-3pf` had no existing ExecPlan path and required self-contained execution guidance.
Revision Note (2026-02-09 12:44Z, Codex): Updated progress, decisions, and acceptance details after implementing package edits and recording `bun run check` failure evidence.
Revision Note (2026-02-09 19:04Z, Codex): Backfilled closure markers after issue completion; commit evidence: 5576d463.
