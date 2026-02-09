# Replace Timer Wrappers with Bun.sleep (bd-2j5)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

This task replaces Promise-based `setTimeout` delay wrappers with `Bun.sleep` where safe, reducing timer boilerplate and aligning with Bun-native APIs while preserving CLI behavior. After this work, delay/sleep utility paths in this repo use Bun-native timer semantics directly.

## Progress

- [x] (2026-02-09 14:01Z) Claimed issue `bd-2j5`.
- [x] (2026-02-09 14:01Z) Created this ExecPlan at `.agent/execplans/bd-2j5-phase-4c-bun-api-adoption-timer-wrappers.md`.
- [x] (2026-02-09 14:03Z) Enumerated Promise-wrapped `setTimeout` patterns across source files and filtered to pure delay wrappers (no signal/cancellation semantics).
- [x] (2026-02-09 14:04Z) Replaced safe delay wrappers with `Bun.sleep` in seven source locations across `ai`, `mom`, `pods`, `tui`, and `coding-agent`.
- [x] (2026-02-09 14:04Z) Ran `bun run check`; command fails in current workspace due many pre-existing `packages/tui/test` TypeScript issues unrelated to changed files.
- [ ] Update plan outcomes and close issue with commit.

## Surprises & Discoveries

- Observation: Most remaining `setTimeout` usages in `src` are not pure sleep wrappers (timeouts, cancellation, UI scheduling, or cleanup), so replacing them with `Bun.sleep` would change behavior.
  Evidence: filtered search results show signal-aware wrappers in `packages/ai/src/providers/*` and `packages/coding-agent/src/utils/sleep.ts`, plus non-delay callback timers.

- Observation: `bun run check` currently fails on existing `packages/tui/test` typing/import-extension errors unrelated to timer-wrapper edits.
  Evidence: `/tmp/bd-2j5-check.log` shows TS7006/TS2835 errors in many `packages/tui/test/*.ts` files and no error references to edited source paths.

## Decision Log

- Decision: Restrict changes to explicit delay wrappers (`new Promise(... setTimeout ...)`) and avoid altering timeout APIs with cancellation/extra behavior.
  Rationale: Issue scope is low-risk, straightforward Bun API replacement.
  Date/Author: 2026-02-09 / Codex

- Decision: Leave signal-aware sleep helpers unchanged (for example wrappers that store timeout IDs and clear them on abort).
  Rationale: `Bun.sleep` replacement there would remove cancellation semantics and risk behavior regressions.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Completed outcome:

1. Files changed:
   - `packages/ai/src/utils/oauth/google-antigravity.ts`
   - `packages/ai/src/utils/oauth/google-gemini-cli.ts`
   - `packages/ai/src/utils/oauth/openai-codex.ts`
   - `packages/coding-agent/src/modes/rpc/rpc-client.ts`
   - `packages/mom/src/events.ts`
   - `packages/pods/src/commands/models.ts`
   - `packages/tui/src/terminal.ts`
2. Replacements performed:
   - `new Promise(... setTimeout ...)` delay wrappers replaced by `Bun.sleep(...)`.
   - No changes made to signal-aware or callback-scheduling timers.
3. Validation:
   - `bun run check` executed but fails due pre-existing unrelated TypeScript errors in `packages/tui/test`.

## Context and Orientation

The repository is a Bun-runtime fork where Bun-native API adoption is allowed when behavior remains equivalent. The targeted pattern is:

- `await new Promise(resolve => setTimeout(resolve, ms))`

The desired replacement is:

- `await Bun.sleep(ms)`

This should only be applied when the wrapper is purely a sleep/delay and does not depend on timeout IDs, cancellation, or additional callback logic.

## Plan of Work

Milestone 1 searches for `setTimeout` wrappers and identifies safe replacements.

Milestone 2 applies code edits with minimal surface area.

Milestone 3 runs `bun run check`, documents outcome, commits, and closes issue.

## Concrete Steps

Run from `/Users/ycm/Developer/oss/pi-bun-mono`:

1. Search:
   - `rg -n \"new Promise\\(|setTimeout\\(\" packages`
2. Inspect candidates and replace only pure delay wrappers.
3. Validate:
   - `bun run check`
4. Record updated findings in this plan and close issue.

## Validation and Acceptance

Acceptance for this issue is complete when:

1. All identified pure delay wrappers in scope are migrated to `Bun.sleep`.
2. Behavior-sensitive timeout uses remain unchanged.
3. `bun run check` succeeds.

## Idempotence and Recovery

Search and replacement steps are repeatable. If `bun run check` fails, revert only problematic local edit(s) and re-run validation until green.

## Artifacts and Notes

Artifacts to capture:

1. File list of replacements.
2. Validation output summary (`bun run check`).
3. Commit hash and Beads close/sync confirmation.

Captured artifacts:

1. Diff covering seven source files listed in Outcomes.
2. Validation log: `/tmp/bd-2j5-check.log` (`__EXIT:2`, unrelated pre-existing test TS errors).
3. Commit hash and Beads close/sync confirmation (pending).

## Interfaces and Dependencies

No public interface changes expected. Dependency is Bun runtime providing `Bun.sleep`.

Revision Note (2026-02-09 14:01Z, Codex): Initial ExecPlan created because issue `bd-2j5` had no existing ExecPlan path.
Revision Note (2026-02-09 14:04Z, Codex): Updated with completed Bun.sleep replacements, rationale for excluded timers, and validation outcome.
