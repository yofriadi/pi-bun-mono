#!/usr/bin/env bash
set -euo pipefail

WITH_PACK=0
if [[ "${1:-}" == "--with-pack" ]]; then
  WITH_PACK=1
elif [[ "${1:-}" != "" ]]; then
  echo "Usage: $0 [--with-pack]" >&2
  exit 2
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TMP_DIR="$(mktemp -d /tmp/pi-upstream-validate.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

log() {
  echo "[validate] $*"
}

run_cmd() {
  local name="$1"
  shift
  local out="$TMP_DIR/${name}.out"
  local err="$TMP_DIR/${name}.err"
  if (cd "$ROOT" && "$@") >"$out" 2>"$err"; then
    log "OK: $name"
  else
    log "FAIL: $name"
    echo "--- stdout ($name) ---" >&2
    sed -n '1,120p' "$out" >&2 || true
    echo "--- stderr ($name) ---" >&2
    sed -n '1,200p' "$err" >&2 || true
    exit 1
  fi
}

run_shell() {
  local name="$1"
  shift
  local out="$TMP_DIR/${name}.out"
  local err="$TMP_DIR/${name}.err"
  if (cd "$ROOT" && /bin/zsh -lc "$*") >"$out" 2>"$err"; then
    log "OK: $name"
  else
    log "FAIL: $name"
    echo "--- stdout ($name) ---" >&2
    sed -n '1,120p' "$out" >&2 || true
    echo "--- stderr ($name) ---" >&2
    sed -n '1,200p' "$err" >&2 || true
    exit 1
  fi
}

compare_outputs() {
  local left="$1"
  local right="$2"
  local label="$3"
  if diff -u "$TMP_DIR/${left}.out" "$TMP_DIR/${right}.out" >"$TMP_DIR/diff-${label}.txt"; then
    log "MATCH: $label"
  else
    log "DIFF: $label"
    sed -n '1,120p' "$TMP_DIR/diff-${label}.txt"
    exit 1
  fi
}

log "Root: $ROOT"

run_shell root_build 'bun run build'

run_shell src_version 'bun packages/coding-agent/src/cli.ts --version'
run_shell src_help 'bun packages/coding-agent/src/cli.ts --help'
run_shell src_list_help 'bun packages/coding-agent/src/cli.ts list --help'
run_shell src_install_help 'bun packages/coding-agent/src/cli.ts install --help'
run_shell src_list 'bun packages/coding-agent/src/cli.ts list'

DIRECT_BIN="$TMP_DIR/direct-pi"
run_shell direct_compile "bun build --compile packages/coding-agent/src/cli.ts --outfile $DIRECT_BIN"
run_shell direct_version "$DIRECT_BIN --version"
run_shell direct_help "$DIRECT_BIN --help"
run_shell direct_list_help "$DIRECT_BIN list --help"
run_shell direct_install_help "$DIRECT_BIN install --help"
run_shell direct_list "$DIRECT_BIN list"

run_shell build_binary_script 'bun run --cwd packages/coding-agent build:binary'
run_shell dist_version 'packages/coding-agent/dist/pi --version'

if command -v pi >/dev/null 2>&1; then
  log "Detected installed pi on PATH; running parity comparisons"
  run_shell global_version 'pi --version'
  run_shell global_help 'pi --help'
  run_shell global_list_help 'pi list --help'
  run_shell global_install_help 'pi install --help'
  run_shell global_list 'pi list'

  compare_outputs global_version src_version global-vs-src-version
  compare_outputs global_version direct_version global-vs-direct-version
  compare_outputs global_help src_help global-vs-src-help
  compare_outputs global_help direct_help global-vs-direct-help
  compare_outputs global_list_help src_list_help global-vs-src-list-help
  compare_outputs global_list_help direct_list_help global-vs-direct-list-help
  compare_outputs global_install_help src_install_help global-vs-src-install-help
  compare_outputs global_install_help direct_install_help global-vs-direct-install-help
  compare_outputs global_list src_list global-vs-src-list
  compare_outputs global_list direct_list global-vs-direct-list
else
  log "No global pi found on PATH; skipping parity comparison"
fi

if [[ "$WITH_PACK" == "1" ]]; then
  PACK_DIR="$TMP_DIR/pack"
  INSTALL_DIR="$TMP_DIR/install"
  mkdir -p "$PACK_DIR"

  run_shell npm_pack "cd packages/coding-agent && npm pack --pack-destination $PACK_DIR"
  TARBALL="$(ls -1 "$PACK_DIR"/*.tgz | head -n 1)"
  if [[ "$TARBALL" == "" ]]; then
    log "FAIL: npm pack did not produce tarball"
    exit 1
  fi

  run_shell npm_install_pack "npm install --prefix $INSTALL_DIR $TARBALL"
  PACK_BIN="$INSTALL_DIR/node_modules/.bin/pi"
  run_shell pack_version "$PACK_BIN --version"
  run_shell pack_help "$PACK_BIN --help"
  run_shell pack_list_help "$PACK_BIN list --help"
  run_shell pack_install_help "$PACK_BIN install --help"
  run_shell pack_list "$PACK_BIN list"

  if [[ -f "$TMP_DIR/global_version.out" ]]; then
    compare_outputs global_version pack_version global-vs-pack-version
    compare_outputs global_help pack_help global-vs-pack-help
    compare_outputs global_list_help pack_list_help global-vs-pack-list-help
    compare_outputs global_install_help pack_install_help global-vs-pack-install-help
    compare_outputs global_list pack_list global-vs-pack-list
  fi
fi

log "All integration checks passed"
