# Adopt Bun File APIs in coding-agent Hot Paths (bd-2zj)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, hot-path file reads and writes in selected coding-agent tools will use Bun-native file APIs (`Bun.file`, `Bun.write`) instead of Node `fs/promises` read/write helpers. This preserves behavior while reducing Node-specific file I/O usage in the Bun runtime migration.

## Progress

- [x] (2026-02-09 13:04Z) Claimed `bd-2zj` and inspected listed target files.
- [x] (2026-02-09 13:04Z) Created this ExecPlan at `.agent/execplans/bd-2zj-phase-4a-bun-api-adoption-file-io-hot-paths.md`.
- [x] (2026-02-09 13:06Z) Replaced file-content read/write operations with Bun APIs in `core/tools/read.ts` and `core/tools/write.ts`.
- [x] (2026-02-09 13:06Z) Validated directory/access operations remain on Node FS (`fsAccess`, `fsMkdir`) and only read/write adapters changed.
- [ ] Commit issue-scoped files and add Beads comment with commit hash.
- [ ] Close `bd-2zj`, sync state, and fetch next READY issue.

## Surprises & Discoveries

- Observation: `packages/coding-agent/src/session/session-storage.ts` does not exist in the current repository state.
  Evidence: `sed -n '1,260p' packages/coding-agent/src/session/session-storage.ts` fails with "No such file or directory".

- Observation: The two existing target files already use async `fs/promises` read/write wrappers rather than `readFileSync`/`writeFileSync`.
  Evidence: `read.ts` imports `readFile` from `fs/promises`; `write.ts` imports `writeFile` from `fs/promises`.

## Decision Log

- Decision: Limit implementation to existing target files (`core/tools/read.ts`, `core/tools/write.ts`) and document the missing session-storage path.
  Rationale: The listed third file is absent, and migrating unrelated modules would exceed issue scope.
  Date/Author: 2026-02-09 / Codex

- Decision: Keep directory operations on Node `fs/promises` while switching only content read/write to Bun APIs.
  Rationale: Issue explicitly says to keep directory/stat/exists operations on Node FS.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestones 1 and 2 are complete. Bun file APIs now back the default read/write tool adapters while Node FS directory/access semantics remain unchanged. The missing `session-storage.ts` target was documented and not substituted with unrelated modules.

## Context and Orientation

In scope files:

- `packages/coding-agent/src/core/tools/read.ts`
- `packages/coding-agent/src/core/tools/write.ts`

Out-of-date path from issue description (not present):

- `packages/coding-agent/src/session/session-storage.ts`

Current behavior in scope files:

- `read.ts` uses `fs/promises.readFile` via `defaultReadOperations.readFile`.
- `write.ts` uses `fs/promises.writeFile` via `defaultWriteOperations.writeFile`.

Required migration for this issue in current tree:

- Replace file-content read with `await Bun.file(path).arrayBuffer()` + `Buffer` conversion.
- Replace file-content write with `await Bun.write(path, content)`.
- Preserve Node FS directory-access operations (`access`, `mkdir`).

## Plan of Work

Milestone 1 updates read/write operation implementations in `read.ts` and `write.ts` only.

Milestone 2 validates via focused diff and search that only requested APIs changed and Node directory ops remained.

Milestone 3 commits and closes Beads issue.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Edit `read.ts` and `write.ts` imports/default operations.
2. Validate:

       rg -n "Bun\.file|Bun\.write|fsReadFile|fsWriteFile|fsMkdir|fsAccess" packages/coding-agent/src/core/tools/read.ts packages/coding-agent/src/core/tools/write.ts
       git diff -- packages/coding-agent/src/core/tools/read.ts packages/coding-agent/src/core/tools/write.ts

3. Commit and close:

       git add packages/coding-agent/src/core/tools/read.ts packages/coding-agent/src/core/tools/write.ts .agent/execplans/bd-2zj-phase-4a-bun-api-adoption-file-io-hot-paths.md
       git commit -m "refactor(coding-agent): use bun file APIs in read/write tools"
       br comments add bd-2zj --message "Adopted Bun file APIs in coding-agent read/write hot paths. Commit: <hash>"
       br close bd-2zj --reason "Completed"
       br sync --flush-only
       br ready --json

## Validation and Acceptance

Acceptance criteria:

- `read.ts` file reads use Bun file API (`Bun.file(...).arrayBuffer()` pathway).
- `write.ts` file writes use Bun API (`Bun.write(...)`).
- Node FS directory/access operations remain (`fsAccess`, `fsMkdir`).
- No unrelated file changes are included.

## Idempotence and Recovery

These code edits are deterministic and idempotent in source. If behavior regressions appear, revert only modified operation adapters in the two target files.

## Artifacts and Notes

Capture:

- Focused diffs for `read.ts` and `write.ts`.
- Commit hash and Beads close confirmation.
- Note on missing `session-storage.ts` path.

## Interfaces and Dependencies

No public interfaces change; only internal default file operation adapters in tool implementations are updated.

Revision Note (2026-02-09 13:04Z, Codex): Initial ExecPlan created because issue `bd-2zj` had no ExecPlan path and required a self-contained implementation guide.
Revision Note (2026-02-09 13:06Z, Codex): Updated progress and outcomes after Bun API adapter migration and focused validation.
