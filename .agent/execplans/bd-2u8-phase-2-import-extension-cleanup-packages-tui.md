# Remove Internal .js Import Extensions in packages/tui (bd-2u8)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, TypeScript files in `packages/tui` will use extensionless internal relative imports rather than `.js`-suffixed specifiers. This aligns module references with Bun-first source execution and avoids dist-oriented import assumptions.

## Progress

- [x] (2026-02-09 13:01Z) Claimed `bd-2u8` and collected baseline relative `.js` import matches in `packages/tui` TypeScript files.
- [x] (2026-02-09 13:01Z) Created this ExecPlan at `.agent/execplans/bd-2u8-phase-2-import-extension-cleanup-packages-tui.md`.
- [x] (2026-02-09 13:02Z) Removed `.js` suffixes from internal relative imports in `packages/tui/**/*.ts`.
- [x] (2026-02-09 13:02Z) Validated no relative `.js` imports remain in `packages/tui` TypeScript files.
- [x] (2026-02-09 19:04Z) Commit issue-scoped files and add Beads comment with commit hash.
- [x] (2026-02-09 19:04Z) Close `bd-2u8`, sync state, and fetch next READY issue.

## Surprises & Discoveries

- Observation: Affected scope is broader than estimate; 40 TypeScript files contain matching relative `.js` specifiers.
  Evidence: `rg -l --glob '*.ts' "(from|import\()\s*['\"]\.{1,2}/[^'\"]+\.js['\"]" packages/tui | wc -l` returned `40`.

- Observation: No matching relative `.js` import points to an existing physical `.js` source file.
  Evidence: `bun /tmp/find-real-js-imports.mjs packages/tui` returned `<none>`.

## Decision Log

- Decision: Apply codemod across all `.ts` files under `packages/tui`.
  Rationale: Pattern is consistent and broad; codemod is reliable and repeatable.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestones 1 and 2 are complete. Import cleanup touched 40 TypeScript files and post-validation confirmed zero remaining relative `.js` specifiers in `packages/tui`.

## Context and Orientation

Scope is limited to TypeScript files under `packages/tui` (source and tests). Required transformation:

- `from "./foo.js"` -> `from "./foo"`
- `from "../bar/baz.js"` -> `from "../bar/baz"`
- same rule for dynamic `import("...")`

External package imports and non-relative specifiers are out of scope.

## Plan of Work

Milestone 1 applies codemod to `packages/tui/**/*.ts`.

Milestone 2 validates zero remaining relative `.js` matches in TypeScript files.

Milestone 3 commits issue files and closes `bd-2u8`.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Apply codemod:

       bun /tmp/strip-relative-js.mjs packages/tui

2. Validate:

       rg -n --glob '*.ts' "(from|import\()\s*['\"]\.{1,2}/[^'\"]+\.js['\"]" packages/tui
       git diff --stat -- packages/tui

3. Commit and close:

       git add packages/tui .agent/execplans/bd-2u8-phase-2-import-extension-cleanup-packages-tui.md
       git commit -m "refactor(tui): remove internal .js import extensions"
       br comments add bd-2u8 --message "Removed internal .js import extensions in packages/tui. Commit: <hash>"
       br close bd-2u8 --reason "Completed"
       br sync --flush-only
       br ready --json

## Validation and Acceptance

Acceptance criteria:

- No `packages/tui` TypeScript file has a relative import/export/dynamic-import specifier ending in `.js`.
- Diff changes are limited to specifier extension stripping.

## Idempotence and Recovery

Codemod is idempotent for this pattern. Re-run safely if interrupted. If unexpected edits appear, adjust affected lines before committing.

## Artifacts and Notes

Capture:

- Pre/post search evidence from `rg`.
- `git diff --stat -- packages/tui` summary.
- Commit hash and `br close` confirmation.

## Interfaces and Dependencies

No dependency or runtime behavior changes are intended; only relative import string literals in TypeScript files are modified.

Revision Note (2026-02-09 13:01Z, Codex): Initial ExecPlan created because issue `bd-2u8` had no ExecPlan path and required a self-contained implementation guide.
Revision Note (2026-02-09 13:02Z, Codex): Updated progress and outcomes after codemod and validation completion.
Revision Note (2026-02-09 19:04Z, Codex): Backfilled closure markers after issue completion; commit evidence: a9a37209.
