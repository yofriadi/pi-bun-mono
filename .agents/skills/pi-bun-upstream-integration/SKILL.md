---
name: pi-bun-upstream-integration
description: >-
  Integrate upstream pi-mono changes into the Bun fork while preserving CLI behavior
  parity and Bun runtime boundaries. Use when pulling, rebasing, or merging upstream
  commits, resolving conflicts in package manifests/runtime wiring, and validating
  source-run, packed install, and compiled binary behavior.
---

# Pi Bun Upstream Integration

## Goal

Keep upstream behavior vanilla while retaining Bun-first runtime/tooling in this fork.

## Execute This Workflow

1. Capture upstream delta.

- Fetch and inspect changed files before editing.
- Classify each file into one of three buckets: safe upstream carry-over, Bun boundary hotspot, or out-of-scope divergence.

2. Apply fork boundaries before resolving conflicts.

- Keep CLI behavior, flags, prompts, auth/session semantics aligned with upstream.
- Keep runtime/tooling Bun-first for CLI/runtime packages.
- Keep `packages/web-ui` Node/Vite-scoped unless explicitly migrating that package.
- Avoid adding product features from other forks.

3. Resolve hotspot files with explicit invariants.

- Root scripts in `package.json`:
  - Use `bun run --cwd <path> <script>` form (not `bun --cwd <path> run <script>`).
  - Keep `build` runnable with the currently supported package script surface.
- `packages/coding-agent/package.json`:
  - Keep `bin.pi` pointing to `src/cli.ts`.
  - Keep `files` including `src`, docs, examples, and release notes needed by runtime/docs features.
  - Keep `build:binary` compiling from `src/cli.ts` and copying runtime assets for `dist/pi`.
- `packages/coding-agent/src/config.ts`:
  - Keep package metadata fallback for compiled binaries without companion `package.json`.
- `packages/coding-agent/src/modes/interactive/theme/theme.ts`:
  - Keep fallback to bundled `dark.json`/`light.json` imports when filesystem theme files are absent.
- `packages/web-ui/package.json`:
  - Keep build script compatible with current repo toolchain (`tsc` + tailwind).

4. Run post-integration validation.

- Run `scripts/validate-integration.sh` for standard validation.
- Run `scripts/validate-integration.sh --with-pack` before publishing or when packaging paths changed.
- Use `references/validation-matrix.md` to manually reproduce checks if needed.

5. Triage failures by signature.

- Use `references/failure-signatures.md` to map common errors to root-cause files.
- Apply minimal corrections; avoid broad rewrites.

6. Record behavior deltas.

- If behavior differs from upstream, update `PORTING_NOTES.md` with concrete, observed differences.
- Remove stale caveats when fixes land.

## Decision Rules During Integration

- Prefer small, local edits over architecture changes.
- Favor behavior parity over Bun API replacement when semantics might shift.
- Treat packaging and compiled-binary regressions as release blockers.
- Treat full `bun run check` failures in pre-existing unrelated test suites as known baseline unless the upstream pull changed those surfaces.

## References

- Validation commands and expected outcomes: `references/validation-matrix.md`
- Failure symptom to fix mapping: `references/failure-signatures.md`

## Script

Use `scripts/validate-integration.sh` to run deterministic smoke/parity checks:

- Root build
- Source-run CLI behavior
- Direct compiled binary behavior
- `build:binary` output behavior
- Optional packed-install behavior (`--with-pack`)
- Optional output parity comparison against installed `pi` if available on PATH
