# Migrate coding-agent package.json to Bun Runtime Paths (bd-97a)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, the `@mariozechner/pi-coding-agent` package metadata will point directly at TypeScript source files for CLI entry, main module entry, and exported subpaths, while declaring Bun as the runtime engine. A contributor can verify the migration by inspecting `packages/coding-agent/package.json` and confirming that previous `dist/*.js` entrypoint references are replaced by `src/*.ts` paths and that Bun version requirements are declared.

## Progress

- [x] (2026-02-09 12:47Z) Claimed issue `bd-97a` and inspected current `packages/coding-agent/package.json` state.
- [x] (2026-02-09 12:47Z) Created this ExecPlan at `.agent/execplans/bd-97a-phase-1-package-infrastructure-coding-agent-package-json.md`.
- [x] (2026-02-09 12:48Z) Edited `packages/coding-agent/package.json` for source-based entrypoints/exports, Bun engine declaration, and removal of `clean` and `dev` scripts.
- [x] (2026-02-09 12:48Z) Validated JSON parsing and captured focused diff evidence for the package manifest edits.
- [ ] Commit issue-scoped files and add Beads progress comment with commit hash.
- [ ] Close `bd-97a`, flush Beads sync, and fetch next READY issue.

## Surprises & Discoveries

- Observation: The package currently uses `dist/*.js` entrypoints and `dist/*.d.ts` type exports, plus a Node engine requirement.
  Evidence: Baseline `packages/coding-agent/package.json` has `bin.pi = dist/cli.js`, `main = ./dist/index.js`, exports under `./dist/*`, and `engines.node = >=20.0.0`.

## Decision Log

- Decision: Scope this issue strictly to the fields explicitly listed in `bd-97a`.
  Rationale: The issue requests targeted package metadata migration, not broader script/tooling rewrites; minimizing edits reduces behavior risk.
  Date/Author: 2026-02-09 / Codex

- Decision: Move top-level `types` from `./dist/index.d.ts` to `./src/index.ts`.
  Rationale: Entry and export surfaces now point directly at source TypeScript paths; keeping `types` aligned avoids mismatched `dist` assumptions in source-first runtime usage.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestones 1 and 2 are complete. The package manifest now points to source TypeScript entrypoints and exports, uses Bun engine constraints, and removes the requested build-watch/clean scripts. Final tracker bookkeeping and issue closure remain.

## Context and Orientation

The file `packages/coding-agent/package.json` defines package publishing metadata and local tooling scripts for the coding-agent package. For this issue, the relevant fields are:

- `bin.pi` for the CLI executable path.
- `main` for module default import resolution.
- `exports` for public subpath entrypoints.
- `engines` for runtime compatibility declaration.
- `scripts` for development/build lifecycle commands.

The requested migration moves runtime-relevant package entrypoints away from built JavaScript output in `dist/` to source TypeScript in `src/`, and removes build-watch/clean script entries called out by the issue.

## Plan of Work

Milestone 1 edits `packages/coding-agent/package.json` only. Update `bin.pi` from `dist/cli.js` to `src/cli.ts`, update `main` from `./dist/index.js` to `./src/index.ts`, and rewrite each `exports` target from `./dist/...` to corresponding `./src/...` TypeScript files. Update `engines` from Node to Bun (`>=1.3.7`). Remove script entries for `clean` and `dev` because the issue explicitly requests removing clean/dev-watch build scripts.

Milestone 2 validates that the JSON remains syntactically correct and that the file contains the expected value changes. Use `bun --print` to parse package JSON and inspect a focused git diff.

Milestone 3 stages only the issue files (`packages/coding-agent/package.json` plus this ExecPlan), creates a commit, records Beads issue comment with commit hash, closes the issue, flushes sync state, and returns to READY queue.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Apply package metadata edits:

       edit packages/coding-agent/package.json

2. Validate and capture evidence:

       bun --print "JSON.parse(require('node:fs').readFileSync('packages/coding-agent/package.json','utf8')).engines"
       git diff -- packages/coding-agent/package.json

3. Commit and tracker updates:

       git add packages/coding-agent/package.json .agent/execplans/bd-97a-phase-1-package-infrastructure-coding-agent-package-json.md
       git commit -m "chore(coding-agent): migrate package metadata to bun source paths"
       br comments add bd-97a --message "Implemented coding-agent package.json Bun migration. Commit: <hash>"
       br close bd-97a --reason "Completed"
       br sync --flush-only
       br ready --json

## Validation and Acceptance

Acceptance criteria for this issue are met when all statements below are true in `packages/coding-agent/package.json`:

- `bin.pi` is `src/cli.ts`.
- `main` is `./src/index.ts`.
- All entries in `exports` reference `./src/*.ts` paths instead of `./dist/*.js` or `./dist/*.d.ts`.
- `engines.bun` is `>=1.3.7` and `engines.node` is not present.
- Scripts `clean` and `dev` are absent.
- Package name remains scoped as `@mariozechner/pi-coding-agent`.

## Idempotence and Recovery

The edits are idempotent: reapplying the same key/value changes has no additional effect. If JSON syntax is broken, restore by comparing with `git diff` and correcting commas/quotes in `packages/coding-agent/package.json` before committing. Stage files explicitly to avoid capturing unrelated repository changes.

## Artifacts and Notes

Artifacts to include as evidence:

- Focused diff for `packages/coding-agent/package.json`.
- Commit hash for issue traceability.
- `br close` output showing issue closure.

## Interfaces and Dependencies

This issue only changes package manifest metadata interfaces in `packages/coding-agent/package.json`. No TypeScript runtime source files are modified in this issue.

Revision Note (2026-02-09 12:47Z, Codex): Initial ExecPlan created because issue `bd-97a` had no ExecPlan path and required a self-contained implementation guide.
Revision Note (2026-02-09 12:48Z, Codex): Updated progress and decision records after implementing and validating package manifest changes.
