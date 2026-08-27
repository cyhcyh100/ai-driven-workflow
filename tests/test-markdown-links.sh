#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

failed=0
while IFS=$'\t' read -r file target; do
  case "$target" in
    ''|http://*|https://*|mailto:*|'#'*) continue ;;
  esac

  target=${target%%#*}
  target=${target#<}
  target=${target%>}
  if [ ! -e "$(dirname "$file")/$target" ]; then
    echo "$file: broken local link: $target" >&2
    failed=1
  fi
done < <(
  find . -type f -name '*.md' -print0 |
    xargs -0 perl -ne 'while (/\]\(([^)]+)\)/g) { print "$ARGV\t$1\n" }'
)

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "Markdown link tests passed."
