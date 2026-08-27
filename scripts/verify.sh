#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

echo "[1/5] Bash syntax"
for file in scripts/*.sh tests/*.sh skills/brainstorming/scripts/*.sh \
  skills/subagent-driven-development/scripts/*; do
  bash -n "$file"
done

echo "[2/5] Node.js syntax"
for file in skills/brainstorming/scripts/*.js skills/brainstorming/scripts/*.cjs; do
  node --check "$file"
done

echo "[3/5] Brainstorming server unit tests"
node --test tests/brainstorm-server.test.cjs

echo "[4/5] SDD script integration tests"
tests/test-sdd-scripts.sh

echo "[5/5] Markdown links"
tests/test-markdown-links.sh

echo "All checks passed."
