# Author PORTING_NOTES.md for Bun Fork Scope (bd-1fb)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

This task creates a clear `PORTING_NOTES.md` for the Bun-runtime fork so contributors understand boundaries and parity expectations before making changes. After this work, a new contributor can quickly see what is in-scope, what is forbidden, which Node APIs map to Bun APIs, how to run verification commands, and which known behavior differences currently exist.

## Progress

- [x] (2026-02-09 14:04Z) Claimed issue `bd-1fb`.
- [x] (2026-02-09 14:05Z) Created this ExecPlan at `.agent/execplans/bd-1fb-documentation-porting-notes-md.md`.
- [x] (2026-02-09 14:07Z) Collected fork policy from `AGENTS.md` and concrete verification outcomes from `bd-p79`, `bd-rbz`, `bd-3gp`, and `bd-j1c`.
- [x] (2026-02-09 14:08Z) Authored `PORTING_NOTES.md` with required sections: scope, allowed/forbidden changes, API mapping table, testing instructions, known differences.
- [x] (2026-02-09 14:08Z) Validated notes against current repository state and completed issue-scoped documentation update.
- [x] (2026-02-09 19:04Z) Commit and close issue.

## Surprises & Discoveries

- Observation: Known differences section can now be grounded in concrete evidence from completed verification issues rather than generic caveats.
  Evidence: recently closed verification plans document specific observed behaviors (tools/login invocation, binary runtime asset expectation, clipboard edge case, test-suite caveats).

## Decision Log

- Decision: Use repository-local policy (`AGENTS.md`) and executed verification outcomes as primary sources for note content.
  Rationale: The document must reflect actual current fork constraints and observed parity status.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Completed outcome:

1. Created `PORTING_NOTES.md`.
2. Included all required sections:
   - runtime-only scope
   - allowed changes
   - forbidden changes
   - Node-to-Bun mapping table
   - testing instructions
   - known differences
3. Documented current known parity/behavior differences observed during verification work.

## Context and Orientation

Issue requires a single document `PORTING_NOTES.md` with six content blocks:

1. Scope (runtime-only changes).
2. Allowed changes.
3. Forbidden changes.
4. Node-to-Bun API mapping table.
5. Testing instructions.
6. Known differences from upstream.

The repository already includes operating rules in `AGENTS.md`, and recent completed verification issues provide concrete known differences to capture.

## Plan of Work

Milestone 1 gathers policy and verification facts from repo state and issue outcomes.

Milestone 2 writes `PORTING_NOTES.md` with concise, prescriptive sections matching issue requirements.

Milestone 3 verifies file coverage/accuracy, commits, and closes.

## Concrete Steps

Run from `/Users/ycm/Developer/oss/pi-bun-mono`:

1. Read policy context:
   - `AGENTS.md`
2. Summarize known differences from completed verification issues (`bd-p79`, `bd-rbz`, `bd-3gp`, `bd-j1c`).
3. Create `PORTING_NOTES.md` with required six sections and Bun-first test commands.
4. Sanity-check file for completeness and factual accuracy.
5. Commit and close issue in Beads.

## Validation and Acceptance

Acceptance for this issue is complete when `PORTING_NOTES.md` exists and includes:

1. Explicit runtime-only scope statement.
2. Allowed and forbidden change lists.
3. Node-to-Bun API mapping table.
4. Bun-first testing instructions.
5. Known upstream parity differences documented with concrete behavior notes.

## Idempotence and Recovery

Documentation edits are repeatable. If a statement is uncertain, prefer explicit "observed currently" phrasing and avoid speculative claims.

## Artifacts and Notes

Artifacts to capture:

1. `PORTING_NOTES.md` content.
2. Commit hash.
3. Beads close/sync confirmation.

Captured artifacts so far:

1. `PORTING_NOTES.md` authored.
2. Commit hash and Beads close/sync confirmation (resolved via commit 536aab2d).

## Interfaces and Dependencies

No code interfaces are changed by this issue; only documentation is updated.

Revision Note (2026-02-09 14:05Z, Codex): Initial ExecPlan created because issue `bd-1fb` had no existing ExecPlan path.
Revision Note (2026-02-09 14:08Z, Codex): Updated with completed documentation content and evidence-backed known differences.
Revision Note (2026-02-09 19:04Z, Codex): Backfilled closure markers after issue completion; commit evidence: 536aab2d.
