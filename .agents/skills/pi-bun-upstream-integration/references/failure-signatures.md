# Failure Signatures

## `Cannot find module './main'` after packed install

Likely cause:

- `packages/coding-agent/package.json` publishes `src/cli.ts` as bin but does not include full `src` in `files`.

Check:

- `packages/coding-agent/package.json` `bin.pi`
- `packages/coding-agent/package.json` `files`

## `ENOENT ... package.json` when running compiled binary

Likely cause:

- Runtime metadata load assumes companion `package.json` on disk.

Check:

- `packages/coding-agent/src/config.ts` metadata loading fallback logic.

## `ENOENT ... theme/dark.json` when running compiled binary

Likely cause:

- Built-in theme loader requires filesystem files without fallback.

Check:

- `packages/coding-agent/src/modes/interactive/theme/theme.ts` fallback imports for `dark.json`/`light.json`.
- `packages/coding-agent/package.json` `copy-binary-assets` script if relying on copied files.

## Root `bun run build` fails with script lookup/help output

Likely cause:

- Incorrect Bun script invocation ordering.

Check:

- Use `bun run --cwd <path> <script>` form in root `package.json` scripts.

## `build:binary` fails before compile due broad TypeScript errors

Likely cause:

- `build:binary` depends on transpile pipeline that is stricter/broader than required for Bun source runtime.

Check:

- `packages/coding-agent/package.json` `build` and `build:binary` scripts.
- Ensure `build:binary` compiles from `src/cli.ts` and copies required runtime assets.
