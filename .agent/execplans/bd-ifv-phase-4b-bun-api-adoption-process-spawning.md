# Replace child_process.spawn with Bun.spawn in coding-agent (bd-ifv)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, command execution hot paths in coding-agent will use Bun-native process spawning instead of Node `child_process.spawn`. The goal is behavior parity: stdout/stderr streaming, timeout handling, signal/abort handling, and process-tree termination semantics should remain equivalent to existing behavior.

## Progress

- [x] (2026-02-09 13:06Z) Claimed `bd-ifv` and inspected current `spawn` usage in target files.
- [x] (2026-02-09 13:06Z) Created this ExecPlan at `.agent/execplans/bd-ifv-phase-4b-bun-api-adoption-process-spawning.md`.
- [x] (2026-02-09 13:09Z) Migrated `spawn` usage in `core/tools/bash.ts` and Windows `taskkill` spawn in `utils/shell.ts` to `Bun.spawn`.
- [x] (2026-02-09 13:09Z) Performed focused source-level validation of spawn migration; targeted test invocation attempted but blocked by missing `vitest` binary in environment.
- [x] (2026-02-09 19:04Z) Commit issue-scoped files and add Beads comment with commit hash.
- [x] (2026-02-09 19:04Z) Close `bd-ifv`, sync state, and fetch next READY issue.

## Surprises & Discoveries

- Observation: `utils/shell.ts` uses both `spawn` and `spawnSync`; only async `spawn` is in scope for Bun migration.
  Evidence: import line is `import { spawn, spawnSync } from "child_process"` and only `spawn("taskkill", ...)` is async.

- Observation: `core/tools/bash.ts` relies on Node stream event handlers (`child.stdout.on("data")`, `child.on("close")`, `child.on("error")`) and detached process tree semantics.
  Evidence: current `defaultBashOperations.exec` implementation uses event-driven `ChildProcess` API.

- Observation: Focused test command cannot run in this environment because `vitest` executable is not available.
  Evidence: `bun run --cwd packages/coding-agent test` fails with `/bin/bash: vitest: command not found`.

## Decision Log

- Decision: Keep `spawnSync` for shell discovery (`which`/`where`) unchanged.
  Rationale: Issue scope targets `spawn` migration and `spawnSync` remains appropriate for short synchronous path probes.
  Date/Author: 2026-02-09 / Codex

- Decision: Implement a local helper in `bash.ts` to stream `Bun.spawn` readable streams into existing `onData(Buffer)` callback semantics.
  Rationale: Bun streams differ from Node streams; adapter preserves existing tool contract.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestone 1 is complete and migrated spawn hot paths to Bun with stream adapter logic. Validation is partially complete: source-level migration checks passed, but runtime test execution is blocked by missing local test runner dependency (`vitest` not installed in current environment).

## Context and Orientation

Target files:

- `packages/coding-agent/src/utils/shell.ts`
- `packages/coding-agent/src/core/tools/bash.ts`

Current behavior to preserve:

- `bash` tool streams both stdout and stderr incrementally.
- `timeout` kills process tree and returns timeout error message.
- `AbortSignal` kills process tree and returns aborted message.
- Non-zero exit code returns output plus code.
- Windows process tree kill uses `taskkill` command.

## Plan of Work

Milestone 1 updates process spawning primitives to Bun while keeping all higher-level error/output semantics unchanged.

Milestone 2 validates with targeted tests focused on bash tool behavior and process handling.

Milestone 3 commits, comments, closes issue, and returns to READY queue.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Edit process spawning code in the two target files.

2. Validate source-level migration:

       rg -n "child_process|spawn\(|Bun\.spawn|spawnSync" packages/coding-agent/src/utils/shell.ts packages/coding-agent/src/core/tools/bash.ts
       git diff -- packages/coding-agent/src/utils/shell.ts packages/coding-agent/src/core/tools/bash.ts

3. Run focused tests:

       bun --cwd packages/coding-agent run test test/tools.test.ts

4. Commit and close:

       git add packages/coding-agent/src/utils/shell.ts packages/coding-agent/src/core/tools/bash.ts .agent/execplans/bd-ifv-phase-4b-bun-api-adoption-process-spawning.md
       git commit -m "refactor(coding-agent): migrate spawn paths to bun"
       br comments add bd-ifv --message "Migrated coding-agent spawn hot paths to Bun.spawn. Commit: <hash>"
       br close bd-ifv --reason "Completed"
       br sync --flush-only
       br ready --json

## Validation and Acceptance

Acceptance criteria:

- `spawn(...)` usage in the two target files is replaced with `Bun.spawn(...)`.
- Bash tool still streams output, handles timeout aborts, and reports exit codes in the same shape.
- Focused bash/tool test command runs successfully or, if failing, failure is documented with concrete output.

## Idempotence and Recovery

Code edits are deterministic. If Bun spawn behavior mismatches are detected, rollback only the adapter portions while keeping issue notes updated with observed gaps.

## Artifacts and Notes

Capture:

- Focused diffs of both target files.
- Test command result summary.
- Commit hash and `br close` output.

## Interfaces and Dependencies

Public tool interfaces remain unchanged (`BashOperations.exec` still resolves `{ exitCode }` and streams `Buffer` chunks). Migration affects only process implementation internals.

Revision Note (2026-02-09 13:06Z, Codex): Initial ExecPlan created because issue `bd-ifv` had no ExecPlan path and required a self-contained implementation guide.
Revision Note (2026-02-09 13:09Z, Codex): Updated progress and discoveries after Bun spawn migration and attempted focused test execution.
Revision Note (2026-02-09 19:04Z, Codex): Backfilled closure markers after issue completion; commit evidence: e73e6cd5.
