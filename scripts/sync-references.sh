#!/usr/bin/env bash
# Refreshes the two reference pages bundled with the skill from the Molt repository, and stamps
# each with where it came from. Needs the GitHub CLI (`gh`), logged in.
#
# Usage: bash scripts/sync-references.sh [git-ref]      (default: develop)
set -euo pipefail

REPO="micheltlutz/molt"
REF="${1:-develop}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/plugins/molt-framework/skills/using-molt-framework/references"

sha="$(gh api "repos/$REPO/commits/$REF" --jq '.sha[0:7]')"
today="$(date +%F)"

for name in capabilities pitfalls; do
  body="$(gh api "repos/$REPO/contents/docs/$name.md?ref=$REF" --jq .content | base64 -d)"
  {
    printf '> Snapshot of the Molt repository'"'"'s `docs/%s.md` at `%s` (%s), taken %s.\n' "$name" "$REF" "$sha" "$today"
    printf '> Check on crates.io whether a published version already ships it: if the project'"'"'s installed\n'
    printf '> version has `docs/%s.md`, read that copy instead. Links in it are relative to the Molt crate\n' "$name"
    printf '> and do not resolve here.\n\n'
    printf '%s\n' "$body"
  } > "$DEST/$name.md"
  echo "wrote references/$name.md  ($REF @ $sha, $(wc -l < "$DEST/$name.md" | tr -d ' ') lines)"
done
