# Verify Bun Compiled Binary Behavior (bd-j1c)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

This task verifies that the coding-agent still works when compiled as a standalone Bun binary. After this work, a reader can see whether `bun build --compile` succeeds and whether the produced binary behaves correctly for help/tool visibility, interactive startup, session persistence, and basic size expectations.

## Progress

- [x] (2026-02-09 13:58Z) Claimed issue `bd-j1c` and confirmed dependency `bd-rbz` is closed.
- [x] (2026-02-09 13:59Z) Created this ExecPlan at `.agent/execplans/bd-j1c-verification-binary-build.md`.
- [x] (2026-02-09 13:59Z) Built binary with `bun build --compile packages/coding-agent/src/cli.ts --outfile dist/pi` (`__EXIT:0`).
- [x] (2026-02-09 13:59Z) Verified binary execution behavior: fails at startup (`ENOENT ... dist/package.json`) even for `--help`.
- [x] (2026-02-09 13:59Z) Verified tool availability check attempt: blocked by startup failure (same `package.json` error).
- [x] (2026-02-09 13:59Z) Verified interactive startup check attempt: blocked by startup failure before TUI init.
- [x] (2026-02-09 13:59Z) Verified session persistence check attempt: blocked by startup failure before session operations.
- [x] (2026-02-09 13:59Z) Captured binary size and assessed reasonableness (`68M`, reasonable for Bun-compiled CLI with bundled runtime).
- [x] (2026-02-09 14:00Z) Verified package `build:binary` script status for issue note: FAIL (pre-compile TypeScript/tsgo errors).
- [x] (2026-02-09 14:00Z) Summarized verification outcomes and parity impact in this plan.
- [x] (2026-02-09 19:04Z) Commit issue-scoped notes and close `bd-j1c` in Beads.

## Surprises & Discoveries

- Observation: Direct compiled artifact `dist/pi` cannot start because runtime config/data files expected relative to executable are missing.
  Evidence: `/tmp/bd-j1c-help.log`, `/tmp/bd-j1c-tools.log`, and prompt logs all fail with `ENOENT: no such file or directory, open '/Users/ycm/Developer/oss/pi-bun-mono/dist/package.json'`.

- Observation: The package-level `build:binary` script currently fails before binary compile due TypeScript build errors in this workspace state.
  Evidence: `/tmp/bd-j1c-build-binary-script.log` exits 1 with many TS7006/TS2835/TS2305 errors during `npm run build`.

## Decision Log

- Decision: Follow the exact build command and then execute behavioral checks against the generated `dist/pi` artifact.
  Rationale: The issue explicitly names command and expected verification matrix.
  Date/Author: 2026-02-09 / Codex

- Decision: Use quick, evidence-focused checks (`--help`, non-interactive prompt, interactive PTY startup, session file reuse) rather than broad test suites.
  Rationale: This issue verifies compiled runtime behavior, not package-level unit/integration coverage.
  Date/Author: 2026-02-09 / Codex

- Decision: Also run `bun --cwd=packages/coding-agent run build:binary` after direct compile failed at runtime.
  Rationale: The issue explicitly states that existing `build:binary` script should still work; validating this claim is part of verification scope.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Verification results:

1. Build command from issue text:
   - `bun build --compile packages/coding-agent/src/cli.ts --outfile dist/pi`
   - PASS (artifact produced).
2. Binary executes correctly:
   - FAIL. `./dist/pi --help` exits with `ENOENT ... dist/package.json`.
3. All tools work:
   - BLOCKED/FAIL due startup failure (binary never reaches tool handling).
4. Interactive mode renders:
   - BLOCKED due startup failure before TUI initialization.
5. Session persistence works:
   - BLOCKED due startup failure before session logic.
6. Binary size:
   - `68M`; reasonable for Bun-compiled binary footprint.
7. Existing `build:binary` script still works:
   - FAIL in this workspace state (`bun --cwd=packages/coding-agent run build:binary` exits 1 with extensive TypeScript build errors before compile stage).

Parity impact:

1. Direct compile command currently produces non-runnable artifact without expected companion assets.
2. Standard package `build:binary` workflow is also currently broken in this workspace due TS build failures.
3. Binary verification matrix cannot pass until build/runtime packaging and compile preconditions are fixed.

## Context and Orientation

The coding-agent entrypoint is `packages/coding-agent/src/cli.ts`. Bun supports compiling this into a standalone executable with `bun build --compile`. The issue requires checking not only compilation success but also runtime behavior:

1. Binary launches and responds correctly.
2. Tool behavior is available as expected.
3. Interactive TUI starts.
4. Session persistence still works when using compiled binary.
5. Output binary size is not unexpectedly large.

Existing prior verification already covered source-run CLI behavior. This issue focuses specifically on compiled artifact behavior.

## Plan of Work

Milestone 1 builds `dist/pi` and confirms artifact existence + size.

Milestone 2 runs behavioral checks (`--help`, tool-related invocation, interactive startup smoke, non-interactive prompt) against `dist/pi`.

Milestone 3 runs session persistence check with explicit session file path, records outcomes, then commits and closes.

## Concrete Steps

Run from `/Users/ycm/Developer/oss/pi-bun-mono`:

1. Build:
   - `bun build --compile packages/coding-agent/src/cli.ts --outfile dist/pi`
2. Existence/size:
   - `ls -lh dist/pi`
3. Basic execution:
   - `./dist/pi --help`
4. Tool behavior smoke:
   - `./dist/pi tools` (or equivalent behavior observation for tool listing path)
   - `echo 'hello' | ./dist/pi -p 'respond with hi'`
5. Interactive startup smoke (PTY):
   - `./dist/pi`
6. Session persistence:
   - run once with `--session <path>` and prompt
   - run again with same `--session <path>` and verify context carry-over
7. Record pass/fail/blocked for each required check in this plan.

Executed commands and outcomes:

1. `bun build --compile packages/coding-agent/src/cli.ts --outfile dist/pi`
   Outcome: `__EXIT:0`, build succeeded.
2. `ls -lh dist/pi`
   Outcome: `68M` binary.
3. `./dist/pi --help`
   Outcome: exit 1 with `ENOENT` for `dist/package.json`.
4. `./dist/pi tools`
   Outcome: exit 1 with same `ENOENT`; no tool runtime reached.
5. `echo 'hello' | ./dist/pi -p 'respond with hi' --session /tmp/bd-j1c-session.jsonl`
   Outcome: exit 1 with same `ENOENT`; session flow blocked.
6. `echo 'followup' | ./dist/pi -p 'What did I ask you to respond with?' --session /tmp/bd-j1c-session.jsonl`
   Outcome: exit 1 with same `ENOENT`.
7. `bun --cwd=packages/coding-agent run build:binary`
   Outcome: `__EXIT:1`; TS compile/type/module-resolution errors prevent binary script completion.

## Validation and Acceptance

Acceptance for this issue is complete when:

1. Build command has concrete success or failure evidence.
2. Binary execution checks are recorded for help/tools/interactive/non-interactive behavior.
3. Session persistence is explicitly tested with same session path across runs.
4. Binary size is recorded and judged reasonable for this project context.

## Idempotence and Recovery

Build and runtime checks are safe to re-run. If build fails, capture compiler output and stop behavioral checks that require artifact. If interactive command hangs, terminate safely and record observed startup state before exit.

## Artifacts and Notes

Artifacts captured:

1. `/tmp/bd-j1c-build.log`
2. `/tmp/bd-j1c-size.log`
3. `/tmp/bd-j1c-help.log`
4. `/tmp/bd-j1c-tools.log`
5. `/tmp/bd-j1c-prompt1.log`
6. `/tmp/bd-j1c-prompt2.log`
7. `/tmp/bd-j1c-build-binary-script.log`
8. Final commit hash and Beads close/sync confirmation (resolved via commit af6a03e1).

## Interfaces and Dependencies

No code changes are required unless a minimal fix is needed to make compiled binary behavior match expectations. Primary dependency is Bun compiler/runtime behavior for `--compile` artifact execution.

Revision Note (2026-02-09 13:59Z, Codex): Initial ExecPlan created because issue `bd-j1c` had no existing ExecPlan path.
Revision Note (2026-02-09 14:00Z, Codex): Updated with build results, runtime failure evidence (`dist/package.json` missing), `build:binary` script failure evidence, and full verification matrix outcomes.
Revision Note (2026-02-09 19:04Z, Codex): Backfilled closure markers after issue completion; commit evidence: af6a03e1.
