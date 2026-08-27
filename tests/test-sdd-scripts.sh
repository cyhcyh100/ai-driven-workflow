#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
sdd="$root/skills/subagent-driven-development/scripts"
tmp_base=${TMPDIR:-/tmp}
tmp=$(mktemp -d "$tmp_base/ai-driven-workflow-sdd.XXXXXX")

cleanup() {
  case "$tmp" in
    "$tmp_base"/ai-driven-workflow-sdd.*) rm -rf -- "$tmp" ;;
    *) echo "refusing to remove unexpected test path: $tmp" >&2 ;;
  esac
}
trap cleanup EXIT

git -C "$tmp" init -q
git -C "$tmp" config user.name test
git -C "$tmp" config user.email test@example.com
mkdir -p "$tmp/docs"
printf '# Plan A\n\n### Task 1: Alpha\n\nImplement alpha.\n' > "$tmp/docs/plan-a.md"
printf '# Plan B\n\n### Task 1: Beta\n\nImplement beta.\n' > "$tmp/docs/plan-b.md"
git -C "$tmp" add docs
git -C "$tmp" commit -qm 'add plans'

cd "$tmp"
workspace_a=$("$sdd/sdd-workspace" docs/plan-a.md)
workspace_b=$("$sdd/sdd-workspace" docs/plan-b.md)

if [ "$workspace_a" = "$workspace_b" ]; then
  echo "plan workspaces must be isolated" >&2
  exit 1
fi

printf 'Task 1: complete\n' > "$workspace_a/progress.md"
if [ -e "$workspace_b/progress.md" ]; then
  echo "plan B can see plan A's progress ledger" >&2
  exit 1
fi

brief_a=$("$sdd/task-brief" docs/plan-a.md 1 | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')
brief_b=$("$sdd/task-brief" docs/plan-b.md 1 | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')
test -n "$brief_a"
test -n "$brief_b"
test "$brief_a" != "$brief_b"
grep -q 'Implement alpha' "$brief_a"
grep -q 'Implement beta' "$brief_b"

base=$(git rev-parse HEAD)
printf 'first\n' > first.txt
git add first.txt
git commit -qm 'first change'
printf 'second\n' > second.txt
git add second.txt
git commit -qm 'second change'
head=$(git rev-parse HEAD)

package_output=$("$sdd/review-package" docs/plan-a.md "$base" "$head")
package=$(printf '%s\n' "$package_output" | sed -n 's/^wrote \(.*\): [0-9][0-9]* commit(s), [0-9][0-9]* bytes$/\1/p')
test -n "$package"
case "$package" in "$workspace_a"/*) ;; *) echo "review package is outside plan A workspace" >&2; exit 1 ;; esac
grep -q 'first change' "$package"
grep -q 'second change' "$package"
grep -q 'first.txt' "$package"
grep -q 'second.txt' "$package"

echo "SDD script tests passed."
