# Validation Matrix

Run from repository root.

## Fast path

1. `bun run build`
2. `bun packages/coding-agent/src/cli.ts --version`
3. `bun packages/coding-agent/src/cli.ts --help`
4. `bun build --compile packages/coding-agent/src/cli.ts --outfile dist/pi`
5. `./dist/pi --version`
6. `./dist/pi --help`
7. `bun run --cwd packages/coding-agent build:binary`
8. `packages/coding-agent/dist/pi --version`

Expected:

- All commands exit 0.
- Version prints current package version.
- Help output is present and includes install/remove/update/list commands.

## Packaging path

1. `cd packages/coding-agent`
2. `npm pack --pack-destination /tmp/pi-pack-check`
3. `npm install --prefix /tmp/pi-pack-install /tmp/pi-pack-check/<tarball>.tgz`
4. `/tmp/pi-pack-install/node_modules/.bin/pi --version`
5. `/tmp/pi-pack-install/node_modules/.bin/pi --help`

Expected:

- Packed install command runs without `Cannot find module './main'`.

## Optional parity comparison (when global `pi` exists)

Compare outputs between:

- `pi`
- `bun packages/coding-agent/src/cli.ts`
- `./dist/pi`
- packed install binary (`/tmp/pi-pack-install/node_modules/.bin/pi`)

Compare at least:

- `--version`
- `--help`
- `list --help`
- `install --help`
- `list`

For `-p "hello"`, provider/auth errors can be environment-dependent; compare shape/signature, not only success.

## Known baseline caveat

`bun run check` may fail due pre-existing `packages/tui/test/*` TypeScript issues unrelated to upstream integration work.
