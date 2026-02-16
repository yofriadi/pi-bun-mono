#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

git -C "$repo_root" config core.hooksPath .githooks
git -C "$repo_root" config commit.template .gitmessage-fork.txt

chmod +x "$repo_root/.githooks/commit-msg"

echo "Configured git policy for fork commit classification:"
echo "  core.hooksPath=.githooks"
echo "  commit.template=.gitmessage-fork.txt"
echo ""
echo "Next commits must use:"
echo "  fork(<area>): <summary>"
echo "  sync(upstream): merge upstream/main @ <sha>"
