# Remove Internal .js Import Extensions in packages/mom and packages/pods (bd-2bs)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, TypeScript files in `packages/mom` and `packages/pods` use extensionless relative import specifiers instead of `.js` suffixes. This keeps module resolution consistent with source-first Bun runtime execution.

## Progress

- [x] (2026-02-09 13:02Z) Claimed `bd-2bs` and captured baseline relative `.js` import matches in both target packages.
- [x] (2026-02-09 13:02Z) Created this ExecPlan at `.agent/execplans/bd-2bs-phase-2-import-extension-cleanup-packages-mom-pods.md`.
- [x] (2026-02-09 13:03Z) Removed `.js` suffixes from relative imports in `packages/mom/**/*.ts` and `packages/pods/**/*.ts`.
- [x] (2026-02-09 13:03Z) Validated no relative `.js` imports remain in TypeScript files for both packages.
- [x] (2026-02-09 19:04Z) Commit issue-scoped files and add Beads comment with commit hash.
- [x] (2026-02-09 19:04Z) Close `bd-2bs`, sync state, and fetch next READY issue.

## Surprises & Discoveries

- Observation: Combined scope is 17 TypeScript files with matching relative `.js` import specifiers.
  Evidence: `rg -l --glob '*.ts' "(from|import\()\s*['\"]\.{1,2}/[^'\"]+\.js['\"]" packages/mom packages/pods | wc -l` returned `17`.

- Observation: No matching relative `.js` imports resolve to existing physical `.js` files.
  Evidence: `bun /tmp/find-real-js-imports.mjs packages/mom` and `bun /tmp/find-real-js-imports.mjs packages/pods` both returned `<none>`.

## Decision Log

- Decision: Use codemod across both package trees in one milestone.
  Rationale: The transformation is identical and low-risk across both packages.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestones 1 and 2 are complete. Import cleanup touched 17 TypeScript files across `packages/mom` and `packages/pods`, and post-validation confirms zero remaining relative `.js` specifiers.

## Context and Orientation

Scope includes TypeScript files under:

- `packages/mom`
- `packages/pods`

Required transformation is removal of trailing `.js` only from relative specifiers (`./` / `../`) in import/export/dynamic import statements.

## Plan of Work

Milestone 1 applies codemod in both package trees.

Milestone 2 validates no remaining TypeScript-relative `.js` specifiers.

Milestone 3 commits issue files and closes `bd-2bs`.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Apply codemod:

       bun /tmp/strip-relative-js.mjs packages/mom
       bun /tmp/strip-relative-js.mjs packages/pods

2. Validate:

       rg -n --glob '*.ts' "(from|import\()\s*['\"]\.{1,2}/[^'\"]+\.js['\"]" packages/mom packages/pods
       git diff --stat -- packages/mom packages/pods

3. Commit and close:

       git add packages/mom packages/pods .agent/execplans/bd-2bs-phase-2-import-extension-cleanup-packages-mom-pods.md
       git commit -m "refactor(mom,pods): remove internal .js import extensions"
       br comments add bd-2bs --message "Removed internal .js import extensions in packages/mom and packages/pods. Commit: <hash>"
       br close bd-2bs --reason "Completed"
       br sync --flush-only
       br ready --json

## Validation and Acceptance

Acceptance criteria:

- No `packages/mom` or `packages/pods` TypeScript file has a relative import/export/dynamic-import specifier ending in `.js`.
- Changes are restricted to extension stripping in relative specifiers.

## Idempotence and Recovery

Codemod is idempotent for this pattern. Re-run safely if needed. If unexpected change appears, adjust affected line before commit.

## Artifacts and Notes

Capture:

- Pre/post `rg` evidence.
- `git diff --stat` for `packages/mom` and `packages/pods`.
- Commit hash and `br close` confirmation.

## Interfaces and Dependencies

No dependencies or runtime behavior are changed. Only internal TypeScript relative import strings are modified.

Revision Note (2026-02-09 13:02Z, Codex): Initial ExecPlan created because issue `bd-2bs` had no ExecPlan path and required a self-contained implementation guide.
Revision Note (2026-02-09 13:03Z, Codex): Updated progress and outcomes after codemod and validation completion.
Revision Note (2026-02-09 19:04Z, Codex): Backfilled closure markers after issue completion; commit evidence: 5a171612.
