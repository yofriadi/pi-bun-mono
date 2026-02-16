# PORTING_NOTES

## Scope

This repository is a Bun-runtime fork of upstream `badlogic/pi-mono`.

Porting scope is intentionally narrow:

- Preserve upstream CLI behavior/features as closely as possible.
- Make runtime/tooling changes required for Bun.
- Avoid product/UX divergence from upstream.

When behavior differs from upstream, document the difference here before merge.

## Allowed Changes

Allowed in this fork:

- Runtime and packaging changes required for Bun.
- CLI/runtime entrypoint updates (`shebang`, `bin`, `exports`, scripts).
- Internal compatibility refactors needed to run on Bun.
- Selective Bun API adoption where there is clear value:
  - `Bun.file` and `Bun.write` for file hot paths.
  - `Bun.spawn` and Bun shell for process execution.
  - `Bun.sleep` and `Bun.nanoseconds` for timer wrappers/high-resolution timing.

Prefer keeping semantics stable over maximizing Bun API usage.

## Forbidden Changes

Out of scope in this fork:

- New product features from other forks.
- Tool surface expansion unrelated to Bun compatibility.
- Prompt behavior changes.
- Settings/schema redesign.
- Architecture rewrites not required for runtime compatibility.

Also keep these areas unchanged unless clearly required for compatibility:

- `node:path`, `node:os`, `node:url`.
- `fs/promises` directory operations.
- Semantics-sensitive path/temp/home handling.
- Existing CLI flags/defaults/prompts/auth/session behavior.

## Package Boundary Note: web-ui

`packages/web-ui` remains Node/Vite scoped for now and is not part of the Bun runtime migration surface for CLI packages.

Current policy for web-ui:

- Keep Vite-based browser bundling workflow.
- Keep Node runtime requirement explicit in package metadata.
- Revisit Bun bundling migration only if a concrete compatibility or maintenance need arises.

## Node to Bun API Mapping

| Node / Legacy Pattern | Bun Pattern | Usage Rule |
| --- | --- | --- |
| `fs.readFileSync` / `fs.promises.readFile` hot-path reads | `Bun.file(path).text()` / `.bytes()` | Use only where behavior is equivalent and path handling is unchanged. |
| `fs.writeFileSync` / `fs.promises.writeFile` hot-path writes | `Bun.write(path, data)` | Use for high-volume write paths; keep directory/permission semantics unchanged. |
| `child_process.spawn` shell command wrappers | `Bun.spawn([...])` | Use where process lifecycle/stdio semantics are preserved. |
| Promise delay wrappers: `await new Promise(resolve => setTimeout(resolve, ms))` | `await Bun.sleep(ms)` | Use only for pure delays (no timeout handle/cancel semantics). |
| High-resolution timers (`process.hrtime` wrappers) | `Bun.nanoseconds()` | Use for monotonic measurement wrappers only. |
| Timeout wrappers with abort/cancel (`setTimeout` + `clearTimeout` + `AbortSignal`) | Keep Node timeout pattern | Do not replace with `Bun.sleep` if cancellation semantics would change. |

## Release Pipeline Notes (Observed 2026-02-16)

These differences are currently intentional for this fork’s binary release pipeline and should be considered during upstream sync/merge work:

1. `scripts/build-binaries.sh` dependency bootstrap:
   - Uses `npm install` instead of `npm ci`.
   - Reason: this fork uses `bun.lock` (no committed `package-lock.json`), and `npm ci` fails without a lockfile in GitHub Actions.
2. `.github/workflows/build-binaries.yml` Bun runtime:
   - Uses Bun `1.3.7` for release builds.
   - Reason: aligns with package engine constraints and avoids older Bun release-path issues seen in CI during workspace dependency materialization.
3. Cross-platform native dependency step remains npm-based:
   - `npm install --no-save --force` is retained for optional, platform-scoped native packages required by cross-compilation.

Parity impact:
- None on CLI runtime behavior (build/release tooling only).

Merge guidance:
- Re-evaluate these choices if upstream adopts lockfile strategy changes, or when Bun/npm behavior in CI is stable enough to simplify the pipeline.

## Testing Instructions

Use Bun-first verification commands:

- Repository check:
  - `bun run check`
- Package tests (run only when explicitly requested):
  - `bun --cwd=packages/ai run test`
  - `bun --cwd=packages/agent run test`
  - `bun --cwd=packages/coding-agent run test`
  - `bun --cwd=packages/tui run test`

Behavior parity areas to verify after runtime changes:

- CLI help/flags parity.
- Built-in tool list parity.
- Slash command parity.
- Default config/model parity.
- Session/auth behavior parity.

## Known Differences from Upstream (Observed 2026-02-09)

The items below are currently observed in this fork/workspace verification:

1. `tools` positional invocation behavior:
   - `bun packages/coding-agent/src/cli.ts tools` enters interactive flow with `"tools"` as prompt input instead of printing a standalone tool list command response.
2. `login` positional invocation behavior:
   - `bun packages/coding-agent/src/cli.ts login` is treated as prompt input; OAuth login is available via interactive slash command `/login`.
3. Native clipboard module edge case:
   - `@mariozechner/clipboard` loads under Bun, but calling `getImageBinary()` with no image present currently panics in native code.
4. Compiled binary verification status:
   - Direct compile command `bun build --compile packages/coding-agent/src/cli.ts --outfile dist/pi` produces an artifact, but it fails at runtime in this workspace due missing expected companion assets (`dist/package.json`).
5. `build:binary` script status:
   - `bun --cwd=packages/coding-agent run build:binary` currently fails in this workspace during pre-compile TypeScript build checks.
6. Full test-suite status caveat:
   - `packages/coding-agent` full test run currently reports many failures (`Bun is not defined`) in this workspace context; some verification suites are environment/provider dependent.

These are tracked as verification outcomes and should be revisited as Bun migration stabilizes.
