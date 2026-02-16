# Fork Operating Rules

## Purpose

This repository is a Bun-runtime fork of `badlogic/pi-mono` with behavior preserved as closely as possible.

Primary goal:
- Keep upstream CLI behavior/features "vanilla"
- Improve runtime/tooling for Bun only
- Avoid product/UX divergence

## Focus Packages

This fork primarily focuses on the following packages:
- `@mariozechner/pi-ai` (`packages/ai`)
- `@mariozechner/pi-agent-core` (`packages/agent`)
- `@mariozechner/pi-coding-agent` (`packages/coding-agent`)
- `@mariozechner/pi-tui` (`packages/tui`)

## Invisibility

- This fork must remain invisible to the upstream repository.
- Avoid any references, links, or communication that would alert the upstream repository to this fork's existence.

## Scope Guardrails

### Allowed Changes
- Runtime and packaging changes required for Bun
- CLI/runtime entrypoint updates (shebang/bin/exports/scripts)
- Internal compatibility refactors needed to run on Bun
- Selective Bun API adoption where there is clear value:
  - `Bun.file` / `Bun.write` for file hot paths
  - `Bun.spawn` / Bun shell for process execution
  - `Bun.sleep` / `Bun.nanoseconds` for timer wrappers

### Keep as-is (unless clearly required)
- `node:path`, `node:os`, `node:url`
- `fs/promises` for directory operations
- Semantics-sensitive path/temp/home handling
- Existing CLI behavior, flags, defaults, prompts, and auth/session semantics

### Out of Scope
- New product features from other forks
- Tool surface expansion unrelated to Bun compatibility
- Prompt behavior changes
- Settings/schema redesign
- Architecture rewrites not required for runtime compatibility

## Behavior Parity Requirements

Any Bun migration must preserve:
- CLI help/flags parity
- Built-in tool list parity
- Slash command parity
- Default config/model behavior parity
- Session/auth behavior parity

If behavior differs, document it explicitly before merging.

## Runtime Commands

Use Bun-first commands for this fork.

- Check:
  - `bun run check`
- Package tests (only when explicitly requested):
  - `bun --cwd=packages/ai run test`
  - `bun --cwd=packages/agent run test`
  - `bun --cwd=packages/coding-agent run test`
  - `bun --cwd=packages/tui run test`

Do not run broad dev/build workflows unless explicitly requested.

## Issue Tracking (beads_rust)

Use `br` (not `bd`) for issue tracking.

Core workflow:
1. `br ready` – find unblocked work
2. `br update <id> --status in_progress` – claim work
3. implement task
4. `br close <id> --reason "Completed"` – close task
5. `br sync --flush-only` – persist issue state for git

Useful commands:
- `br list --status open`
- `br show <id>`
- `br dep add <issue> <depends-on>`
- `br blocked`
- `br stats`

## Git Safety

- Never run destructive commands (`reset --hard`, `checkout .`, `clean -fd`, `stash`) without explicit user request.
- Stage only intended files; never use sweeping add patterns.
- Never commit unless explicitly asked.
- Never push unless explicitly asked.

## Fork Commit Classification

Use explicit commit metadata so fork-only changes and upstream sync commits are machine-detectable.

### Required subject prefixes
- Fork-only work:
  - `fork(<area>): <summary>`
- Upstream sync commits:
  - `sync(upstream): merge upstream/main @ <sha>`

### Required commit trailers
Every commit must include these trailers:
- `Fork-Only: yes|no`
- `Upstream-Ref: <sha>|none`
- `Parity-Impact: none|documented`

Rules:
- `fork(...)` commits must use:
  - `Fork-Only: yes`
  - `Upstream-Ref: none`
- `sync(upstream)` commits must use:
  - `Fork-Only: no`
  - `Upstream-Ref: <upstream commit sha>`

### Upstream remote
- Keep upstream remote configured:
  - `git remote add upstream git@github.com:badlogic/pi-mono.git`
  - `git fetch upstream`

### Enable local enforcement
Run once per clone:
- `bash scripts/setup-fork-commit-policy.sh`

This sets:
- `core.hooksPath=.githooks`
- `commit.template=.gitmessage-fork.txt`

### Querying fork-only commits
- `git log upstream/main..HEAD --format='%h %s%n%b%n---'`
- Filter by trailer:
  - `Fork-Only: yes`

## Documentation

When runtime behavior differs from upstream, record it in:
- `PORTING_NOTES.md` (scope, rationale, parity impact)
