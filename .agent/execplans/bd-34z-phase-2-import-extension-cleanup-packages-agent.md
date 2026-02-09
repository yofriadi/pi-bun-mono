# Remove Internal .js Import Extensions in packages/agent (bd-34z)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, TypeScript files in `packages/agent` will reference internal modules with extensionless relative import specifiers instead of `.js` suffixes. This keeps source imports consistent with Bun-first source-path execution.

## Progress

- [x] (2026-02-09 12:56Z) Claimed `bd-34z` and captured baseline `.js` relative imports in `packages/agent/src` and `packages/agent/test`.
- [x] (2026-02-09 12:56Z) Created this ExecPlan at `.agent/execplans/bd-34z-phase-2-import-extension-cleanup-packages-agent.md`.
- [x] (2026-02-09 12:56Z) Removed `.js` suffixes from internal relative imports in `packages/agent` TypeScript files.
- [x] (2026-02-09 12:56Z) Validated that no relative `.js` imports remain in `packages/agent`.
- [x] (2026-02-09 19:04Z) Commit issue-scoped files and add Beads comment with commit hash.
- [x] (2026-02-09 19:04Z) Close `bd-34z`, sync state, and fetch next READY issue.

## Surprises & Discoveries

- Observation: The issue estimate (~5 files) understates actual impacted files because tests also import internal modules with `.js` suffixes.
  Evidence: Baseline search reports matches in both `packages/agent/src/*.ts` and `packages/agent/test/*.ts`.

## Decision Log

- Decision: Apply the same codemod strategy used for `bd-ylu` to all `.ts` files under `packages/agent`.
  Rationale: The pattern is uniform and codemod is deterministic and complete for this scope.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestones 1 and 2 are complete. Import-specifier cleanup changed nine `packages/agent` TypeScript files, and validation confirms no remaining relative `.js` suffixes in the package.

## Context and Orientation

Scope includes only TypeScript files under:

- `packages/agent/src`
- `packages/agent/test`

Target transformation is only for relative (`./`, `../`) specifiers ending in `.js` for `from`, `export ... from`, and `import(...)` forms.

## Plan of Work

Milestone 1 runs in-place codemod on `packages/agent/**/*.ts`.

Milestone 2 validates zero remaining relative `.js` imports.

Milestone 3 commits and closes Beads issue.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Apply codemod to `packages/agent` TypeScript files.
2. Validate with `rg` search for remaining relative `.js` imports.
3. Commit and close issue via `br` with commit hash note.

## Validation and Acceptance

Acceptance criteria:

- No relative `.js` import/export/dynamic-import specifiers remain in `packages/agent` TypeScript files.
- Changes are limited to import specifier strings.

## Idempotence and Recovery

Codemod is idempotent for this pattern. Re-running after cleanup yields no changes. If an unintended edit appears, fix that line before commit.

## Artifacts and Notes

Capture:

- Pre/post `rg` evidence.
- Focused `git diff`/`git diff --stat` for `packages/agent`.
- Commit hash and `br close` output.

## Interfaces and Dependencies

No public runtime interfaces or dependencies change. Only relative import string literals in TypeScript files are modified.

Revision Note (2026-02-09 12:56Z, Codex): Initial ExecPlan created because issue `bd-34z` had no ExecPlan path and required a self-contained implementation guide.
Revision Note (2026-02-09 12:56Z, Codex): Updated progress and outcomes after codemod/validation completion.
Revision Note (2026-02-09 19:04Z, Codex): Backfilled closure markers after issue completion; commit evidence: 1f5d8009.
