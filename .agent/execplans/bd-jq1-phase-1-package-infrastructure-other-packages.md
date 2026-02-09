# Migrate Remaining Package Manifests to Bun Source Paths (bd-jq1)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

After this change, the remaining runtime packages (`ai`, `agent`, `tui`, `mom`, `pods`) will declare Bun engine requirements and expose source TypeScript entrypoints instead of `dist` build output in their package manifests. A contributor can inspect each package manifest and confirm that runtime entry surfaces and export maps target `src/*.ts` paths, and that build-oriented scripts are removed as requested.

## Progress

- [x] (2026-02-09 12:49Z) Claimed issue `bd-jq1` and collected baseline package manifest content for the five target packages.
- [x] (2026-02-09 12:49Z) Created this ExecPlan at `.agent/execplans/bd-jq1-phase-1-package-infrastructure-other-packages.md`.
- [x] (2026-02-09 12:51Z) Edited all target package manifests for Bun engines, source entry surfaces, explicit `exports`, and build-script removal.
- [x] (2026-02-09 12:51Z) Validated all edited manifests with JSON parse checks and captured focused diffs.
- [ ] Commit issue-scoped files and add Beads progress note with commit hash.
- [ ] Close `bd-jq1`, flush Beads sync, and fetch next READY issue.

## Surprises & Discoveries

- Observation: Several target packages do not currently define `exports` despite issue text asking for export-path migration.
  Evidence: `packages/ai/package.json`, `packages/agent/package.json`, `packages/tui/package.json`, `packages/mom/package.json`, and `packages/pods/package.json` contain `main`/`bin` fields but no `exports` object.

- Observation: `packages/mom/src` has `main.ts` but no top-level `index.ts`.
  Evidence: `rg --files packages/mom/src | rg 'index\.ts$|main\.ts$'` returns `packages/mom/src/main.ts` (plus nested `tools/index.ts`) and no `packages/mom/src/index.ts`.

## Decision Log

- Decision: Add an explicit `exports` map to each target package pointing `"."` to a source TypeScript entrypoint.
  Rationale: The issue explicitly requires exports to point to `src/` paths; packages lacking `exports` must add one to satisfy this requirement directly.
  Date/Author: 2026-02-09 / Codex

- Decision: For `@mariozechner/pi-mom`, map primary entry/export to `./src/main.ts`.
  Rationale: This package has no top-level `src/index.ts`, and `src/main.ts` is the existing executable entrypoint.
  Date/Author: 2026-02-09 / Codex

- Decision: Retain non-build helper/test scripts where present (`generate-models`, `test`).
  Rationale: The issue asks to remove build scripts while keeping behavior/metadata drift minimal; non-build utility/test scripts are not build lifecycle scripts.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Milestones 1 and 2 are complete. The five manifests now declare Bun engines and source entry surfaces, with build lifecycle scripts removed, while dependency blocks remain unchanged. Remaining work is commit/tracker closure.

## Context and Orientation

This issue edits only these files:

- `packages/ai/package.json`
- `packages/agent/package.json`
- `packages/tui/package.json`
- `packages/mom/package.json`
- `packages/pods/package.json`

Each file currently declares `engines.node` and includes build lifecycle scripts. Each also currently uses `dist/*` entrypoints (via `main`, `types`, or `bin`) or omits explicit export maps. The requested migration is package metadata only; no runtime source modules are changed.

## Plan of Work

Milestone 1 performs all manifest edits. For each package, switch engine declaration to Bun (`>=1.3.7`), rewrite entrypoint surfaces to corresponding `src/*.ts` files (`main`, `types`, `bin` where present), add/update `exports` to source paths, and remove build scripts (`clean`, `build`, `dev`, `dev:tsc`, `prepublishOnly`, and other script entries that exist solely for build pipeline orchestration).

Milestone 2 validates each edited file by JSON parsing and by reviewing focused diffs.

Milestone 3 stages only issue files plus this plan, commits changes, records Beads comment with commit hash, closes the issue, syncs Beads, and returns to READY queue.

## Concrete Steps

Run from repository root `/Users/ycm/Developer/oss/pi-bun-mono`.

1. Edit all five package manifests listed above.

2. Validate JSON and inspect changes:

       bun --print "JSON.parse(require('node:fs').readFileSync('packages/ai/package.json','utf8')).engines"
       bun --print "JSON.parse(require('node:fs').readFileSync('packages/agent/package.json','utf8')).engines"
       bun --print "JSON.parse(require('node:fs').readFileSync('packages/tui/package.json','utf8')).engines"
       bun --print "JSON.parse(require('node:fs').readFileSync('packages/mom/package.json','utf8')).engines"
       bun --print "JSON.parse(require('node:fs').readFileSync('packages/pods/package.json','utf8')).engines"
       git diff -- packages/ai/package.json packages/agent/package.json packages/tui/package.json packages/mom/package.json packages/pods/package.json

3. Commit and tracker operations:

       git add packages/ai/package.json packages/agent/package.json packages/tui/package.json packages/mom/package.json packages/pods/package.json .agent/execplans/bd-jq1-phase-1-package-infrastructure-other-packages.md
       git commit -m "chore(packages): migrate remaining manifests to bun source paths"
       br comments add bd-jq1 --message "Implemented package manifest Bun migration for ai/agent/tui/mom/pods. Commit: <hash>"
       br close bd-jq1 --reason "Completed"
       br sync --flush-only
       br ready --json

## Validation and Acceptance

Acceptance criteria for this issue are met when all of the following are true:

- Each target package (`ai`, `agent`, `tui`, `mom`, `pods`) declares `engines.bun = ">=1.3.7"` and no `engines.node`.
- Each target package has source-based entry/export mapping (entrypoint fields and `exports` map) pointing to `src/*.ts`.
- Build scripts are removed from each target package manifest.
- No dependencies are added, removed, or version-modified in these manifests.
- JSON parse checks run successfully for all five manifests.

## Idempotence and Recovery

All manifest edits are idempotent key/value updates. If any file fails to parse, rerun JSON parse checks and correct syntax locally before staging. If unrelated files become staged, unstage and restage explicit path list only.

## Artifacts and Notes

Artifacts to capture:

- Focused diffs for all five package manifests.
- Commit hash for Beads traceability.
- `br close` output confirming issue closure.

## Interfaces and Dependencies

This issue changes package-manifest metadata interfaces only (`scripts`, `engines`, `main`, `types`, `bin`, `exports`) across the five package JSON files. It preserves dependency declarations exactly as requested.

Revision Note (2026-02-09 12:49Z, Codex): Initial ExecPlan created because issue `bd-jq1` had no existing ExecPlan path and requires multi-package self-contained guidance.
Revision Note (2026-02-09 12:51Z, Codex): Updated progress and decisions after completing multi-package manifest edits and validation.
