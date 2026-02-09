# Create upstream integration skill for Bun fork (bd-1ia)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

This task adds a reusable skill so future agents can safely integrate upstream `pi-mono` changes into this Bun fork without regressing packaging, compiled binary behavior, or CLI parity. After this work, agents can run a deterministic validation script and follow clear hotspot/failure guidance.

## Progress

- [x] (2026-02-09 22:31Z) Claimed issue `bd-1ia`.
- [x] (2026-02-09 22:30Z) Initialized skill scaffold at `.agents/skills/pi-bun-upstream-integration` using `init_skill.py`.
- [x] (2026-02-09 22:31Z) Replaced scaffold placeholders with production skill content in `SKILL.md`.
- [x] (2026-02-09 22:31Z) Added references: validation matrix and failure signatures.
- [x] (2026-02-09 22:31Z) Added executable script `scripts/validate-integration.sh` for deterministic post-upstream checks.
- [x] (2026-02-09 22:31Z) Removed scaffold placeholder files/directories not needed by the skill.
- [x] (2026-02-09 22:32Z) Executed `scripts/validate-integration.sh` and `scripts/validate-integration.sh --with-pack`; both passed.
- [ ] Commit issue-scoped files, comment with commit hash, close issue, and sync state.

## Surprises & Discoveries

- Observation: The bundled `quick_validate.py` could not run in this environment because `PyYAML` is not installed.
  Evidence: `ModuleNotFoundError: No module named 'yaml'` from `python3 .agents/skills/skill-creator/scripts/quick_validate.py ...`.

## Decision Log

- Decision: Keep the skill lean (SKILL.md + references + one script) and remove unused scaffold assets.
  Rationale: The skill should provide deterministic workflow guidance with minimal context overhead.
  Date/Author: 2026-02-09 / Codex

- Decision: Encode parity checks directly in an executable script.
  Rationale: Integration regressions are repetitive and error-prone; a script is faster and more reliable than manual repetition.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

In-progress outcome:

1. New skill created at `.agents/skills/pi-bun-upstream-integration` with Bun-fork integration guidance.
2. Scripted validation confirms current workspace passes the skill's integration matrix, including packed install path.
3. Remaining work is issue commit/close workflow.

## Context and Orientation

The skill is intended for this repository's upstream integration workflow. It teaches agents where regressions commonly happen after pulling upstream code:

- root `package.json` script wiring (`bun run --cwd ... ...` form)
- `packages/coding-agent/package.json` `bin/files/scripts`
- metadata fallback in `packages/coding-agent/src/config.ts`
- built-in theme fallback in `packages/coding-agent/src/modes/interactive/theme/theme.ts`
- web-ui build script compatibility

## Plan of Work

Milestone 1 scaffolds the skill package and replaces placeholder text with repository-specific workflow guidance.

Milestone 2 adds deterministic validation resources (references + executable script) and verifies script behavior on this workspace.

Milestone 3 commits issue-scoped artifacts and closes the issue in Beads.

## Concrete Steps

Run from `/Users/ycm/Developer/oss/pi-bun-mono`:

1. Initialize skill scaffold with `init_skill.py`.
2. Author `SKILL.md` with integration workflow and hotspot invariants.
3. Add references under `references/`.
4. Add and execute `scripts/validate-integration.sh` (with and without `--with-pack`).
5. Remove scaffold placeholders.
6. Commit and close issue.

## Validation and Acceptance

Acceptance criteria:

1. Skill directory exists at `.agents/skills/pi-bun-upstream-integration`.
2. `SKILL.md` contains clear trigger description and upstream integration workflow.
3. Script `scripts/validate-integration.sh` is executable and passes in current workspace.
4. References capture expected matrix and failure signatures.

## Idempotence and Recovery

Skill file edits are idempotent. Validation script uses temp directories under `/tmp` and cleans up on exit, so repeated runs are safe.

## Artifacts and Notes

Artifacts:

1. `.agents/skills/pi-bun-upstream-integration/SKILL.md`
2. `.agents/skills/pi-bun-upstream-integration/references/validation-matrix.md`
3. `.agents/skills/pi-bun-upstream-integration/references/failure-signatures.md`
4. `.agents/skills/pi-bun-upstream-integration/scripts/validate-integration.sh`

## Interfaces and Dependencies

No product runtime interfaces are changed by this issue. The skill script depends on local `bun`, `npm`, and optionally global `pi` for parity comparison.

Revision Note (2026-02-09 22:31Z, Codex): Initial ExecPlan created for issue `bd-1ia`.
