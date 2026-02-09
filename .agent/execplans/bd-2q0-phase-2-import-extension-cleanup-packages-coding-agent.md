# Remove Internal .js Import Extensions in packages/coding-agent (bd-2q0)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, TypeScript files in `packages/coding-agent` will use extensionless relative imports/exports instead of `.js` suffixes. This aligns source execution with Bun runtime entrypoint migration and eliminates path suffix assumptions tied to built JavaScript output.

## Progress

- [x] (2026-02-09 12:57Z) Claimed `bd-2q0` and confirmed a large baseline of relative `.js` specifiers in `packages/coding-agent` TypeScript files.
- [x] (2026-02-09 12:57Z) Created this ExecPlan at `.agent/execplans/bd-2q0-phase-2-import-extension-cleanup-packages-coding-agent.md`.
- [x] (2026-02-09 12:58Z) Removed `.js` suffixes from internal relative imports in `packages/coding-agent` TypeScript files.
- [x] (2026-02-09 12:58Z) Validated no relative `.js` imports remain in `packages/coding-agent` TypeScript files and reconfirmed no real `.js`-file import exceptions.
- [x] (2026-02-09 19:04Z) Commit issue-scoped files and add Beads comment with commit hash.
- [x] (2026-02-09 19:04Z) Close `bd-2q0`, sync state, and fetch next READY issue.

## Surprises & Discoveries

- Observation: The affected scope is larger than estimate; baseline shows 151 files with matching relative `.js` import/export/dynamic-import specifiers.
  Evidence: `rg -l "(from|import\()\s*['\"]\.{1,2}/[^'\"]+\.js['\"]" packages/coding-agent | wc -l` returned `151`.

- Observation: No relative `.js` import points to an existing physical `.js` source file.
  Evidence: `bun /tmp/find-real-js-imports.mjs packages/coding-agent` reported `<none>`.

- Observation: Post-codemod diff touches 148 files across source, tests, and extension examples.
  Evidence: `git diff --stat -- packages/coding-agent` reports `148 files changed` with balanced insertions/deletions.

## Decision Log

- Decision: Use a deterministic codemod over all `packages/coding-agent/**/*.ts` files.
  Rationale: Manual edits are error-prone at this scale; codemod gives complete and repeatable transformation.
  Date/Author: 2026-02-09 / Codex

- Decision: Keep the exception rule for real `.js` files but apply no exemptions because none were detected.
  Rationale: The issue requests preserving actual `.js` imports if present; this package currently has none in TypeScript specifiers.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestones 1 and 2 are complete. Relative `.js` internal specifiers were removed package-wide for TypeScript files, with zero remaining matches in `packages/coding-agent/**/*.ts`.

## Context and Orientation

Scope includes TypeScript files under `packages/coding-agent` (source, tests, examples, and scripts where present). The transformation only affects relative specifiers starting with `./` or `../` and ending in `.js` in:

- `import ... from "..."`
- `export ... from "..."`
- `import("...")`

Do not touch external package imports or non-`.js` suffixes.

## Plan of Work

Milestone 1 runs codemod on all `.ts` files under `packages/coding-agent`.

Milestone 2 validates with post-change search and diff summary to ensure only extension stripping occurred.

Milestone 3 stages issue files, commits, posts Beads progress note, closes issue, syncs, and returns to READY.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Run codemod:

       bun /tmp/strip-relative-js.mjs packages/coding-agent

2. Validate:

       rg -n "(from|import\()\s*['\"]\.{1,2}/[^'\"]+\.js['\"]" packages/coding-agent
       git diff --stat -- packages/coding-agent

3. Commit and close:

       git add packages/coding-agent .agent/execplans/bd-2q0-phase-2-import-extension-cleanup-packages-coding-agent.md
       git commit -m "refactor(coding-agent): remove internal .js import extensions"
       br comments add bd-2q0 --message "Removed internal .js import extensions in packages/coding-agent. Commit: <hash>"
       br close bd-2q0 --reason "Completed"
       br sync --flush-only
       br ready --json

## Validation and Acceptance

Acceptance criteria:

- No `packages/coding-agent` TypeScript file contains a relative import/export/dynamic-import specifier ending with `.js`.
- No external package import paths were modified.
- Diff is limited to extension removals in relative module specifiers.

## Idempotence and Recovery

Codemod is idempotent for the target pattern. Re-running after cleanup yields no net changes. If any unintended edit appears, correct before commit.

## Artifacts and Notes

Capture:

- Baseline and post-cleanup match queries.
- `git diff --stat -- packages/coding-agent` summary.
- Commit hash and `br close` confirmation.

## Interfaces and Dependencies

No dependency or runtime logic changes are intended. This issue only rewrites internal relative import specifier strings.

Revision Note (2026-02-09 12:57Z, Codex): Initial ExecPlan created because issue `bd-2q0` had no ExecPlan path and required a self-contained implementation guide.
Revision Note (2026-02-09 12:58Z, Codex): Updated progress and outcomes after codemod execution and TypeScript-only validation.
Revision Note (2026-02-09 19:04Z, Codex): Backfilled closure markers after issue completion; commit evidence: 600ab31f.
