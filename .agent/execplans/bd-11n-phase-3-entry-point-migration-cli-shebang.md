# Switch coding-agent CLI Shebang to Bun (bd-11n)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, the coding-agent CLI script can be executed directly with Bun as the runtime via its shebang line. The behavioral target is intentionally narrow: only shebang migration from Node to Bun while preserving all existing code paths including the `main()` import and invocation.

## Progress

- [x] (2026-02-09 12:59Z) Claimed `bd-11n` and inspected current `packages/coding-agent/src/cli.ts` header and `main()` usage.
- [x] (2026-02-09 12:59Z) Created this ExecPlan at `.agent/execplans/bd-11n-phase-3-entry-point-migration-cli-shebang.md`.
- [x] (2026-02-09 12:59Z) Changed shebang from `#!/usr/bin/env node` to `#!/usr/bin/env bun` in `packages/coding-agent/src/cli.ts`.
- [x] (2026-02-09 12:59Z) Validated that `import { main } from "./main"` and `main(process.argv.slice(2));` remain unchanged.
- [x] (2026-02-09 19:04Z) Commit issue-scoped files and add Beads comment with commit hash.
- [x] (2026-02-09 19:04Z) Close `bd-11n`, sync state, and fetch next READY issue.

## Surprises & Discoveries

- Observation: The source already imports `main` from `./main` (extensionless), so no import adjustment is needed.
  Evidence: Current file content includes `import { main } from "./main";` followed by `main(process.argv.slice(2));`.

## Decision Log

- Decision: Limit code edit to the first-line shebang only.
  Rationale: The issue explicitly requests no additional migration changes and to keep all other code unchanged.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestones 1 and 2 are complete. The shebang now targets Bun and the rest of CLI entry logic (including `main` import and invocation) remains unchanged.

## Context and Orientation

Target file: `packages/coding-agent/src/cli.ts`.

Current role of this file: executable CLI entrypoint that sets process title, imports `main`, and invokes it with CLI args. Only runtime launcher line (`#!`) is in scope.

## Plan of Work

Milestone 1 updates only line 1 shebang to Bun.

Milestone 2 validates file still imports and invokes `main` exactly as before.

Milestone 3 commits, records Beads note, closes issue, syncs, and returns to READY queue.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Edit shebang line in `packages/coding-agent/src/cli.ts`.
2. Validate via `sed -n '1,20p' packages/coding-agent/src/cli.ts`.
3. Commit and tracker updates:

       git add packages/coding-agent/src/cli.ts .agent/execplans/bd-11n-phase-3-entry-point-migration-cli-shebang.md
       git commit -m "chore(coding-agent): switch cli shebang to bun"
       br comments add bd-11n --message "Updated coding-agent CLI shebang to Bun. Commit: <hash>"
       br close bd-11n --reason "Completed"
       br sync --flush-only
       br ready --json

## Validation and Acceptance

Acceptance criteria:

- `packages/coding-agent/src/cli.ts` line 1 is `#!/usr/bin/env bun`.
- The `main` import and invocation statements are unchanged from baseline.

## Idempotence and Recovery

The shebang replacement is idempotent. Reapplying same value has no effect. If any additional line changes accidentally occur, revert those before commit.

## Artifacts and Notes

Capture:

- Pre/post header snippet (`sed -n '1,20p' ...`).
- Commit hash and `br close` confirmation.

## Interfaces and Dependencies

No runtime interfaces, dependencies, or CLI arguments change. This issue modifies only the executable shebang line.

Revision Note (2026-02-09 12:59Z, Codex): Initial ExecPlan created because issue `bd-11n` had no ExecPlan path and required a self-contained implementation guide.
Revision Note (2026-02-09 12:59Z, Codex): Updated progress and outcomes after shebang edit and validation.
Revision Note (2026-02-09 19:04Z, Codex): Backfilled closure markers after issue completion; commit evidence: e2608a23.
