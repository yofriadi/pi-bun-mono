# Remove Internal .js Import Extensions in packages/ai (bd-ylu)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, TypeScript files under `packages/ai` will use extensionless relative internal imports instead of `*.js` suffixes. This aligns runtime source-path resolution with Bun-first package metadata and avoids mixed source-vs-built extension assumptions. Verification is straightforward: search within `packages/ai` for relative imports ending in `.js` and observe none remain.

## Progress

- [x] (2026-02-09 12:53Z) Claimed `bd-ylu` and captured baseline `.js` internal import references in `packages/ai/src` and `packages/ai/test`.
- [x] (2026-02-09 12:53Z) Created this ExecPlan at `.agent/execplans/bd-ylu-phase-2-import-extension-cleanup-packages-ai.md`.
- [x] (2026-02-09 12:55Z) Removed `.js` suffixes from relative internal imports in `packages/ai` TypeScript files via codemod.
- [x] (2026-02-09 12:55Z) Verified no relative `.js` imports remain anywhere in `packages/ai`.
- [ ] Commit issue-scoped files and add Beads comment with commit hash.
- [ ] Close `bd-ylu`, flush Beads sync, and fetch next READY issue.

## Surprises & Discoveries

- Observation: The package currently has many `../src/*.js`, `./*.js`, and nested relative `.js` imports across source and tests.
  Evidence: `rg -n "(from|import\()\s*['\"]\.{1,2}/[^'\"]+\.js['\"]" packages/ai/src packages/ai/test` reports numerous matches.

- Observation: There are no actual `.js` source files inside `packages/ai`.
  Evidence: `rg --files packages/ai | rg '\.js$'` returned no files.

- Observation: The codemod touched `packages/ai/scripts/generate-models.ts` in addition to `src` and `test` files.
  Evidence: `git diff --stat -- packages/ai` includes `packages/ai/scripts/generate-models.ts`.

## Decision Log

- Decision: Apply a targeted codemod to relative import specifiers (`./` and `../`) ending in `.js` across `.ts` files under `packages/ai`.
  Rationale: The issue scope is broad (~20 files estimated) and pattern-based; codemod is safer and more complete than manual edits.
  Date/Author: 2026-02-09 / Codex

- Decision: Include test files in the import cleanup.
  Rationale: The issue scope says internal TypeScript imports in `packages/ai`; tests are TypeScript files in-package and currently use relative `.js` imports.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestones 1 and 2 are complete. Relative `.js` import suffixes were removed across `packages/ai` TypeScript files and validated with zero remaining matches. Remaining work is commit and issue closure.

## Context and Orientation

Relevant paths in this task:

- `packages/ai/src/**/*.ts`
- `packages/ai/test/**/*.ts`

"Internal import" in this issue means a relative module specifier beginning with `./` or `../` that resolves to files inside `packages/ai`. The required transformation is:

- `from "./foo.js"` -> `from "./foo"`
- `from "../bar/baz.js"` -> `from "../bar/baz"`
- same for `await import("...")` and `export ... from "..."`

Specifiers that must stay unchanged:

- external package imports (do not start with `./` or `../`)
- JSON imports (`.json`)
- actual `.js` file imports (none currently exist in this package)

## Plan of Work

Milestone 1 runs a deterministic in-place replacement across `packages/ai` TypeScript files to strip only trailing `.js` from relative import specifiers.

Milestone 2 runs targeted searches proving there are no remaining relative `.js` specifiers and no accidental non-relative import rewrites.

Milestone 3 stages only issue files, commits, records Beads progress note with commit hash, closes issue, syncs, and returns to READY.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Apply codemod:

       rg --files packages/ai | rg '\.ts$' | xargs perl -i -pe 's{((?:from\s*|import\s*\()\s*["\']\.{1,2}/[^"\']+)\.js(["\'])}{$1$2}g'

2. Validate:

       rg -n "(from|import\()\s*['\"]\.{1,2}/[^'\"]+\.js['\"]" packages/ai/src packages/ai/test
       git diff -- packages/ai

3. Commit and track:

       git add packages/ai/src packages/ai/test .agent/execplans/bd-ylu-phase-2-import-extension-cleanup-packages-ai.md
       git commit -m "refactor(ai): remove internal .js import extensions"
       br comments add bd-ylu --message "Removed internal .js import extensions in packages/ai. Commit: <hash>"
       br close bd-ylu --reason "Completed"
       br sync --flush-only
       br ready --json

## Validation and Acceptance

Acceptance criteria are met when:

- No `packages/ai/src` or `packages/ai/test` TypeScript file contains a relative import/export/dynamic-import specifier ending in `.js`.
- External imports are unchanged.
- JSON imports remain unchanged.
- Git diff shows only import-specifier extension removal in `packages/ai` files.

## Idempotence and Recovery

The codemod is idempotent because it only strips existing `.js` suffixes in relative specifiers; re-running does nothing after first pass. If an unintended change appears, revert that specific file line before staging.

## Artifacts and Notes

Artifacts to capture:

- Pre/post search evidence from `rg`.
- Focused diff in `packages/ai`.
- Commit hash and `br close` confirmation.

## Interfaces and Dependencies

No package dependencies or runtime logic are changed. This issue only updates module specifier strings in TypeScript source and test files within `packages/ai`.

Revision Note (2026-02-09 12:53Z, Codex): Initial ExecPlan created because issue `bd-ylu` had no ExecPlan path and required a self-contained implementation guide.
Revision Note (2026-02-09 12:55Z, Codex): Updated progress/outcomes after codemod execution and validation.
