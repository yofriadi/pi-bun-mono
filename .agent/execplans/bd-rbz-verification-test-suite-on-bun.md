# Verify Bun + Vitest Test Suite Behavior (bd-rbz)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

This task verifies whether this Bun-runtime fork can execute package test suites with Bun + Vitest while preserving expected behavior. After this work, a reader can see which package suites pass, which fail, why failures occur, and whether risk areas like fake timers, `vi.mock`, or coverage tooling show Bun-specific differences.

## Progress

- [x] (2026-02-09 13:31Z) Claimed issue `bd-rbz` and confirmed dependency `bd-p79` is closed.
- [x] (2026-02-09 13:32Z) Created this ExecPlan at `.agent/execplans/bd-rbz-verification-test-suite-on-bun.md`.
- [x] (2026-02-09 13:47Z) Ran `bun --cwd=packages/ai run test`; captured extensive failure evidence in `/tmp/bd-rbz-ai-test.log` (provider quota/auth/local-runtime dependent failures). The long-running command channel did not return a final `__EXIT` marker, but recorded failures make the suite non-passing.
- [x] (2026-02-09 13:40Z) Ran `bun --cwd=packages/agent run test` with `__EXIT:0` (3 files passed, 1 skipped).
- [x] (2026-02-09 13:43Z) Ran `bun --cwd=packages/coding-agent run test` with `__EXIT:1` (7 files failed, 38 passed, 5 skipped; 71 failing tests, many `Bun is not defined`).
- [x] (2026-02-09 13:44Z) Ran `bun --cwd=packages/tui run test` with `__EXIT:0` (400/400 passing).
- [x] (2026-02-09 13:48Z) Summarized Bun-specific behavior differences (especially `Bun` global availability in test runtime and provider/env-dependent failures).
- [x] (2026-02-09 19:04Z) Commit issue-scoped changes and close `bd-rbz` in Beads.

## Surprises & Discoveries

- Observation: `packages/coding-agent` suite now fails broadly after Bun API migration because many tests execute modules in a context where `Bun` is undefined.
  Evidence: `/tmp/bd-rbz-coding-agent-test.log` contains repeated `ReferenceError: Bun is not defined`; summary reports `Test Files 7 failed | 38 passed | 5 skipped` and `Tests 71 failed | 587 passed | 43 skipped`.

- Observation: `packages/ai` suite is heavily dependent on live provider quotas/credentials and local runtimes (OpenRouter quota, Cloud Code Assist quota, Ollama availability), which produce assertion failures unrelated to core runner startup.
  Evidence: `/tmp/bd-rbz-ai-test.log` includes `403 Key limit exceeded`, `Cloud Code Assist API error (429)`, and `Cannot read properties of undefined (reading 'contextWindow')` from local Ollama path.

- Observation: `packages/agent` and `packages/tui` suites run cleanly under Bun in this environment.
  Evidence: `/tmp/bd-rbz-agent-test.log` summary shows all passing/skipped with exit 0; `/tmp/bd-rbz-tui-test.log` shows `pass 400`, `fail 0`, exit 0.

- Observation: The long-running `packages/ai` command session did not return a final wrapper exit marker despite complete failure evidence written to log.
  Evidence: command wrapper expected `__EXIT:<code>`; log progressed through multiple failing files but no final marker was emitted in session output.

## Decision Log

- Decision: Execute the four package test suites in the exact order listed in the issue.
  Rationale: The issue explicitly defines this command list and asks for tracking outcomes for each package.
  Date/Author: 2026-02-09 / Codex

- Decision: Use `bun --cwd=<package> run test` without adding extra flags first; only add flags for diagnosis if a suite fails.
  Rationale: Baseline behavior should match the issue's requested commands before any diagnostic variation.
  Date/Author: 2026-02-09 / Codex

- Decision: Treat `packages/ai` as failing/inconclusive for final exit code while still recording it as executed for verification purposes.
  Rationale: The required command was run and produced explicit test failures; absence of final wrapper marker does not invalidate observed non-passing behavior.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Verification results:

1. `packages/agent`: PASS (`__EXIT:0`).
2. `packages/tui`: PASS (`__EXIT:0`).
3. `packages/coding-agent`: FAIL (`__EXIT:1`) with broad `Bun is not defined` errors in read/write/bash tools and extension-related tests after Bun API adoption.
4. `packages/ai`: command executed with substantial FAIL evidence in log, dominated by provider quota/auth/environment dependencies and local runtime requirements; final wrapper exit marker missing in session output.

Risk-area observations requested by issue:

1. Fake timers: no explicit fake-timer incompatibility signal observed in captured failures.
2. Module mocking (`vi.mock`): no explicit `vi.mock` incompatibility signal observed in captured failures.
3. Coverage reporting: not exercised by these package test scripts; no Bun-specific coverage output difference observed in this run.

Net result versus purpose: Bun can run package suites, but behavioral parity for test outcomes is not achieved in this environment because `packages/coding-agent` regressed under Bun global assumptions and `packages/ai` integration-heavy tests are highly environment/provider dependent.

## Context and Orientation

The repository is a Bun-runtime fork and expects Bun-first commands. This issue asks for verification only, not feature development. The required commands target four packages:

1. `packages/ai`
2. `packages/agent`
3. `packages/coding-agent`
4. `packages/tui`

Each package should define a `test` script in its `package.json`. Vitest is the test runner used by the project. "Fake timers" means replacing real timer behavior in tests; "`vi.mock`" means Vitest module mocking behavior; "coverage reporting" means code-coverage instrumentation/report output from test runs. The goal is to note whether these areas show failures or odd behavior under Bun.

## Plan of Work

Milestone 1 runs the first two package suites (`ai`, `agent`) and records direct command outcomes. At the end of this milestone, the plan contains concrete pass/fail evidence for half the matrix.

Milestone 2 runs the remaining suites (`coding-agent`, `tui`) and records direct command outcomes. At the end of this milestone, all required commands are executed.

Milestone 3 analyzes all results for Bun-specific patterns, updates this plan's living sections, then commits the plan and closes the issue in Beads with a concise status comment referencing the commit hash.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`:

1. `bun --cwd=packages/ai run test`
2. `bun --cwd=packages/agent run test`
3. `bun --cwd=packages/coding-agent run test`
4. `bun --cwd=packages/tui run test`

Executed command wrappers and outcomes:

1. `bun --cwd=packages/ai run test > /tmp/bd-rbz-ai-test.log 2>&1`
   Outcome: Log captured multiple failing files (`tool-call-id-normalization`, `image-tool-result`, `total-tokens`, `tool-call-without-result`, `tokens`, `context-overflow`, `unicode-surrogate`). Failure signatures are provider/environment related (quota/auth/local runtime).
2. `bun --cwd=packages/agent run test > /tmp/bd-rbz-agent-test.log 2>&1`
   Outcome: `__EXIT:0`; summary `Test Files 3 passed | 1 skipped`, `Tests 32 passed | 33 skipped`.
3. `bun --cwd=packages/coding-agent run test > /tmp/bd-rbz-coding-agent-test.log 2>&1`
   Outcome: `__EXIT:1`; summary `Test Files 7 failed | 38 passed | 5 skipped`, `Tests 71 failed | 587 passed | 43 skipped`; repeated `Bun is not defined`.
4. `bun --cwd=packages/tui run test > /tmp/bd-rbz-tui-test.log 2>&1`
   Outcome: `__EXIT:0`; summary `tests 400`, `pass 400`, `fail 0`.

Then:

1. Update `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective`.
2. Commit this plan file.
3. Add a Beads comment on `bd-rbz` summarizing results and commit hash.
4. Close issue and run `br sync --flush-only`.

## Validation and Acceptance

Acceptance for this issue is complete when all four required test commands have been executed and documented with outcomes, and the issue record contains a clear summary of:

1. Passing suites.
2. Failing suites and failure reason.
3. Observed Bun-specific Vitest differences (or explicit statement that none were observed in command output).

## Idempotence and Recovery

The four verification commands are safe to re-run. If a suite fails due to transient conditions (for example temporary environment issues), rerun the same command once and document both attempts. If a command fails due to missing dependencies, install dependencies with Bun and continue, recording that intervention as part of findings.

## Artifacts and Notes

Artifacts captured during execution:

1. `/tmp/bd-rbz-ai-test.log`
2. `/tmp/bd-rbz-agent-test.log`
3. `/tmp/bd-rbz-coding-agent-test.log`
4. `/tmp/bd-rbz-tui-test.log`
5. Command outcomes for each package test run are summarized in this document.
6. Final commit hash for this issue (resolved via commit b3976d87).
7. Beads close/sync confirmation (resolved via commit b3976d87).

Key evidence snippets:

1. `packages/coding-agent`: `ReferenceError: Bun is not defined` in `src/core/tools/bash.ts` and related tests.
2. `packages/ai`: provider quota failures (`403 Key limit exceeded`, `Cloud Code Assist API error (429)`) and local runtime gap (`ollama serve` not available) driving assertion failures.
3. `packages/tui`: complete pass (`pass 400`, `fail 0`).
4. `packages/agent`: complete pass for executed tests (`32 passed`, `33 skipped`).

## Interfaces and Dependencies

No code interface changes are expected for this issue. Dependencies used are existing package test scripts and Vitest configuration already present in each package. This issue produces verification evidence only.

Revision Note (2026-02-09 13:32Z, Codex): Initial ExecPlan created because issue `bd-rbz` had no existing ExecPlan path.
Revision Note (2026-02-09 13:48Z, Codex): Updated with executed test outcomes, discovered failures, and Bun-specific verification findings for all required package commands.
Revision Note (2026-02-09 19:04Z, Codex): Backfilled closure markers after issue completion; commit evidence: b3976d87.
