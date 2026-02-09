# Decide web-ui runtime boundary for Bun fork (bd-37y)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

This task resolves runtime ambiguity for `packages/web-ui` in a Bun-focused monorepo. After this change, contributors can clearly see that web-ui remains a Node/Vite-focused package for browser bundling while CLI/runtime packages continue Bun migration. The decision is encoded in package metadata and documented in fork notes, reducing accidental migration churn.

## Progress

- [x] (2026-02-09 14:08Z) Confirmed issue `bd-37y` is in progress and the only remaining ready/open item.
- [x] (2026-02-09 14:09Z) Verified no existing ExecPlan path exists for `bd-37y`.
- [x] (2026-02-09 14:10Z) Created this ExecPlan at `.agent/execplans/bd-37y-risk-web-ui-package-decision.md`.
- [x] (2026-02-09 14:10Z) Captured current `packages/web-ui` and `packages/web-ui/example` runtime/build scripts and identified Vite/Node dependency surface.
- [x] (2026-02-09 14:09Z) Applied runtime-boundary decision in package metadata by adding `engines.node >=20.19.0` to web-ui manifests.
- [x] (2026-02-09 14:09Z) Updated `PORTING_NOTES.md` with explicit web-ui Node/Vite boundary policy.
- [x] (2026-02-09 14:09Z) Validated touched files: JSON manifests parse and `PORTING_NOTES.md` contains web-ui boundary note.
- [x] (2026-02-09 19:04Z) Commit, comment on Beads issue, close issue, and flush Beads sync state.

## Surprises & Discoveries

- Observation: `packages/web-ui/package.json` currently has no `engines` field, unlike all Bun-migrated CLI packages in this repository.
  Evidence: `rg -n "\"engines\"" packages/*/package.json` matches all major packages except `packages/web-ui/package.json`.

## Decision Log

- Decision: Keep `packages/web-ui` on Node/Vite for now instead of migrating to Bun bundling.
  Rationale: The issue recommendation prefers low-risk separation because web-ui is browser-bundling oriented and not part of CLI runtime parity scope.
  Date/Author: 2026-02-09 / Codex

- Decision: Encode the decision in two places: package metadata (`engines.node`) and fork-level notes (`PORTING_NOTES.md`).
  Rationale: Metadata prevents ambiguity for maintainers and package consumers, while notes preserve fork policy rationale.
  Date/Author: 2026-02-09 / Codex

- Decision: Set Node floor to `>=20.19.0` for `packages/web-ui` and `packages/web-ui/example`.
  Rationale: This aligns with the Vite 7 runtime baseline and avoids under-specifying Node support for web-ui workflows.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Completed outcome:

1. Runtime boundary decision has been codified in metadata and docs.
2. Issue closure workflow (validation, commit, Beads comment/close/sync) was completed.

## Context and Orientation

Relevant files:

1. `packages/web-ui/package.json`: root package metadata for web-ui library build/development scripts.
2. `packages/web-ui/example/package.json`: Vite-based example app used by web-ui development.
3. `PORTING_NOTES.md`: repository-level migration scope and known differences.

web-ui differs from CLI packages because it targets browser assets and Vite workflows. This issue asks for a decision between Bun migration and keeping Node/Vite. The recommended path is to keep Node/Vite and defer migration.

## Plan of Work

Milestone 1 records this task state in a self-contained ExecPlan and confirms repository context.

Milestone 2 updates web-ui package metadata to explicitly state Node runtime requirements and adds documentation text to `PORTING_NOTES.md` capturing the package boundary decision.

Milestone 3 verifies changed files, commits only issue-related files, posts issue update with commit hash, closes the issue, and flushes Beads state.

## Concrete Steps

Run from `/Users/ycm/Developer/oss/pi-bun-mono`:

1. Inspect `packages/web-ui/package.json` and `packages/web-ui/example/package.json`.
2. Add explicit `engines.node` constraints to those package manifests.
3. Update `PORTING_NOTES.md` with a short section indicating web-ui remains Node/Vite-scoped for now.
4. Validate JSON formatting and documentation consistency.
5. Stage only issue files, commit with issue id, comment on Beads issue with commit reference, close issue, run `br sync --flush-only`, and check `br ready --json`.

## Validation and Acceptance

Acceptance criteria:

1. `packages/web-ui/package.json` includes explicit Node runtime requirement via `engines`.
2. `packages/web-ui/example/package.json` includes explicit Node runtime requirement via `engines`.
3. `PORTING_NOTES.md` documents that web-ui is intentionally kept on Node/Vite currently.
4. Beads issue `bd-37y` is commented, closed, and synced.

## Idempotence and Recovery

These metadata and documentation changes are idempotent and can be rerun safely. If a Node version floor needs adjustment later, update both manifests and keep `PORTING_NOTES.md` consistent with the final policy.

## Artifacts and Notes

Artifacts to capture:

1. Plan file path.
2. Manifest/doc diffs.
3. Commit hash.
4. Beads comment/close/sync output.

## Interfaces and Dependencies

No code interfaces are changed. Affected surfaces are package metadata and repository documentation only.

Revision Note (2026-02-09 14:10Z, Codex): Initial ExecPlan created because issue `bd-37y` had no existing ExecPlan path.
Revision Note (2026-02-09 14:09Z, Codex): Updated progress and decisions after applying web-ui Node/Vite boundary edits.
Revision Note (2026-02-09 14:09Z, Codex): Marked validation complete after manifest parse checks and documentation grep confirmation.
Revision Note (2026-02-09 19:04Z, Codex): Backfilled closure markers after issue completion; commit evidence: e33dc87c.
