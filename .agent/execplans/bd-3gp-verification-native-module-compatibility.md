# Verify Native Module Compatibility on Bun (bd-3gp)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `.agents/PLANS.md` from the repository root.

## Purpose / Big Picture

This verification checks whether native-module and WASM-sensitive runtime paths still function when running the coding-agent directly with Bun. After this work, a reader can see whether clipboard integration, photon-based image processing helpers, and OAuth login flow run correctly, and which parts are blocked by environment requirements (for example GUI/browser access or platform permissions).

## Progress

- [x] (2026-02-09 13:51Z) Claimed issue `bd-3gp` and verified dependency `bd-p79` is closed.
- [x] (2026-02-09 13:52Z) Created this ExecPlan at `.agent/execplans/bd-3gp-verification-native-module-compatibility.md`.
- [x] (2026-02-09 13:56Z) Verified clipboard paths: native module loads, text copy/paste roundtrip passes, and `getImageBinary()` panics when no image data.
- [x] (2026-02-09 13:55Z) Verified photon/WASM paths via focused tests (`clipboard-image`, BMP conversion, `image-processing`) with passing results.
- [x] (2026-02-09 13:57Z) Verified OAuth-related behavior: direct `bun ... cli.ts login` enters interactive mode and treats `login` as user prompt; `/login` is available inside TTY, and auth storage/model registry tests pass.
- [x] (2026-02-09 13:57Z) Summarized outcomes, blockers, and parity impact in this plan.
- [ ] Commit issue-scoped notes and close `bd-3gp` in Beads.

## Surprises & Discoveries

- Observation: `@mariozechner/clipboard` loads under Bun, but calling `getImageBinary()` with no image present triggers a Rust panic instead of a clean empty result/error.
  Evidence: `/tmp/bd-3gp-clipboard-native.log` contains `called Result::unwrap() on an Err value: "no image data"` and `getImageBinary_error Panic in async function`.

- Observation: Clipboard text copy/paste path works in this environment.
  Evidence: `/tmp/bd-3gp-clipboard-roundtrip.log` shows `ROUNDTRIP:PASS` and matching `pbpaste_value`.

- Observation: Photon-backed image processing paths pass in focused Bun tests.
  Evidence: `/tmp/bd-3gp-native-tests.log` shows `Test Files 3 passed` and `Tests 13 passed`.

- Observation: Direct command `bun packages/coding-agent/src/cli.ts login` does not trigger OAuth login flow directly; it starts chat and treats `login` as normal input.
  Evidence: `/tmp/bd-3gp-login.log` shows the assistant response beginning with `Could you clarify what you want to do with “login”?`.

## Decision Log

- Decision: Verify the three requested compatibility areas in issue order (clipboard, WASM/photon, auth login).
  Rationale: The issue description is explicit and this ordering keeps evidence aligned with requested scope.
  Date/Author: 2026-02-09 / Codex

- Decision: Prefer existing project tests/entrypoints to validate behavior before writing ad-hoc probes.
  Rationale: Existing entrypoints best reflect production behavior and parity expectations.
  Date/Author: 2026-02-09 / Codex

- Decision: Add lightweight runtime probes alongside focused tests for clipboard/native behavior.
  Rationale: Existing tests around clipboard often mock native modules; runtime probe confirms actual Bun + native-module loading behavior.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Verification results:

1. Clipboard (`@mariozechner/clipboard`):
   - Partial pass with defect.
   - Native module loads and text clipboard roundtrip works.
   - `getImageBinary()` panics when clipboard has no image data, which is a reliability risk for native clipboard-image path.
2. Photon/WASM (`packages/coding-agent/src/utils/photon.ts` paths):
   - Pass in focused Bun tests (`clipboard-image`, BMP conversion, `image-processing`).
   - Indicates photon wrapper + conversion/resize flows are functional under Bun in source-run mode.
3. OAuth login flow:
   - Core auth logic passes (`auth-storage` and `model-registry` tests: 57 passing).
   - Direct command expectation in issue text differs from actual behavior: `bun ... cli.ts login` is interpreted as interactive prompt content, not a dedicated login subcommand.
   - `/login` exists inside interactive mode, but full browser callback completion could not be fully automated in this run.

Parity impact summary:

1. Native clipboard module behavior has a non-graceful error path (`getImageBinary` panic) when no image exists.
2. OAuth should be invoked as interactive slash command (`/login`), not positional CLI argument `login`.
3. No photon/WASM regression detected in targeted compatibility tests.

## Context and Orientation

This repository is a Bun-runtime fork. The issue asks for verification only, not feature development. The native-module/WASM/auth areas map to coding-agent code paths:

1. Clipboard integration via `@mariozechner/clipboard` (copy/paste helper behavior).
2. Photon image processing utility in `packages/coding-agent/src/utils/photon.ts` (WASM or native-backed image operations).
3. OAuth login flow from coding-agent CLI, expected to involve a local callback server and browser interaction.

Verification may be constrained by host capabilities. Clipboard and browser-backed OAuth often require an interactive desktop session; local model/WASM paths may require optional binaries or runtime assets.

## Plan of Work

Milestone 1 identifies the exact command/test entrypoints used by clipboard and photon utilities and runs them to capture pass/fail evidence.

Milestone 2 runs OAuth login verification through the CLI entrypoint and records whether the callback server and browser handoff can be initiated under Bun.

Milestone 3 updates this plan with concrete outcomes, blockers, and parity implications, then commits and closes the issue.

## Concrete Steps

Run from `/Users/ycm/Developer/oss/pi-bun-mono`:

1. Locate clipboard and photon usage/tests:
   - search for `@mariozechner/clipboard`
   - inspect `packages/coding-agent/src/utils/photon.ts`
   - search for tests that exercise these paths
2. Execute identified verification commands/tests under Bun and capture outputs.
3. Run OAuth login check:
   - `bun packages/coding-agent/src/cli.ts login`
4. Record result class for each area:
   - pass
   - fail (behavior regression)
   - blocked (environment prerequisite unavailable)
5. Update this ExecPlan and close the issue with evidence.

Executed commands and outcomes:

1. `bun -e 'import { clipboard } from "./packages/coding-agent/src/utils/clipboard-native"; ...'`
   Outcome: module present; `hasImage false`; `getImageBinary` panic captured.
2. `bun -e 'import { copyToClipboard } from "./packages/coding-agent/src/utils/clipboard"; ...'` + `pbpaste`
   Outcome: clipboard text roundtrip pass.
3. `bun --cwd=packages/coding-agent run test test/clipboard-image.test.ts test/clipboard-image-bmp-conversion.test.ts test/image-processing.test.ts`
   Outcome: `__EXIT:0`, `Test Files 3 passed`, `Tests 13 passed`.
4. `bun --cwd=packages/coding-agent run test test/auth-storage.test.ts test/model-registry.test.ts`
   Outcome: `__EXIT:0`, `Test Files 2 passed`, `Tests 57 passed`.
5. `bun packages/coding-agent/src/cli.ts login`
   Outcome: enters interactive TUI and treats `login` as prompt input rather than a CLI subcommand; long-running session terminated after capturing behavior.

## Validation and Acceptance

Acceptance for this issue is complete when all requested areas have concrete evidence:

1. Clipboard path: tested and classified as pass/fail/blocked with reason.
2. Photon WASM path: tested and classified as pass/fail/blocked with reason.
3. OAuth login path: tested and classified as pass/fail/blocked with reason.
4. Any non-passing case includes explicit error output and parity impact note.

## Idempotence and Recovery

Verification commands are safe to re-run. If OAuth or clipboard checks are blocked by host environment, capture the blocker and continue to remaining checks without modifying unrelated files. If a command hangs waiting for interaction, terminate it safely and record the exact point reached.

## Artifacts and Notes

Artifacts captured:

1. `/tmp/bd-3gp-clipboard-native.log`
2. `/tmp/bd-3gp-clipboard-roundtrip.log`
3. `/tmp/bd-3gp-native-tests.log`
4. `/tmp/bd-3gp-auth-tests.log`
5. `/tmp/bd-3gp-login.log`
6. Final commit hash and Beads close/sync confirmation (pending).

## Interfaces and Dependencies

No code interface changes are required for this issue unless a minimal compatibility fix is required to complete verification. Dependencies are existing coding-agent modules and CLI entrypoints already present in this repository.

Revision Note (2026-02-09 13:52Z, Codex): Initial ExecPlan created because issue `bd-3gp` had no existing ExecPlan path.
Revision Note (2026-02-09 13:57Z, Codex): Updated with clipboard/photon/auth verification outcomes, observed behavior differences, and concrete command artifacts.
