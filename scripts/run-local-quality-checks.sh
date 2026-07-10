#!/usr/bin/env bash
# Local quality checks aligned with .github/workflows/quality-base-set.yml
# Usage:
#   ./scripts/run-local-quality-checks.sh
#   ./scripts/run-local-quality-checks.sh --staged
#   ./scripts/run-local-quality-checks.sh <git-revision-range>
# Examples:
#   ./scripts/run-local-quality-checks.sh --staged
#   ./scripts/run-local-quality-checks.sh origin/main..HEAD

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

MODE="all"
REV_RANGE=""

case "${1:-}" in
  --staged)
    MODE="staged"
    ;;
  "")
    MODE="all"
    ;;
  *)
    MODE="range"
    REV_RANGE="$1"
    ;;
esac

resolve_git_ref() {
  if [ "$MODE" = "range" ] && [ -n "$REV_RANGE" ]; then
    if [[ "$REV_RANGE" == *".."* ]]; then
      echo "${REV_RANGE##*..}"
    else
      echo "$REV_RANGE"
    fi
  else
    echo "HEAD"
  fi
}

GIT_REF="$(resolve_git_ref)"

collect_changed_files() {
  local pattern="$1"

  if [ "$MODE" = "staged" ]; then
    git diff --cached --name-only --diff-filter=ACMR -- "$pattern"
  elif [ "$MODE" = "range" ] && [ -n "$REV_RANGE" ]; then
    if [[ "$REV_RANGE" == *".."* ]]; then
      git diff --name-only --diff-filter=ACMR "$REV_RANGE" -- "$pattern"
    else
      git diff-tree --no-commit-id --name-only -r "$REV_RANGE" -- "$pattern"
    fi
  else
    git ls-files -- "$pattern"
  fi
}

mapfile -t markdown_files < <(collect_changed_files 'docs' | grep -E '\.md$' | sed '/^$/d' | sort -u)
mapfile -t yaml_files < <(collect_changed_files '.github/workflows' | grep -E '\.(yml|yaml)$' | sed '/^$/d' | sort -u)

run_markdownlint() {
  if [ "${#markdown_files[@]}" -eq 0 ]; then
    echo "markdownlint: no docs Markdown files to check."
    return 0
  fi

  echo "markdownlint: checking ${#markdown_files[@]} file(s)..."
  npx --yes markdownlint-cli2 "${markdown_files[@]}"
}

run_yamllint_on_git_blob() {
  local file="$1"
  local ref="$2"
  local tmp

  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' RETURN

  if ! git show "$ref:$file" > "$tmp" 2>/dev/null; then
    echo "yamllint: could not read $ref:$file" >&2
    return 1
  fi

  yamllint -d relaxed "$tmp"
}

run_yamllint() {
  if [ "${#yaml_files[@]}" -eq 0 ]; then
    echo "yamllint: no workflow YAML files to check."
    return 0
  fi

  if ! command -v yamllint >/dev/null 2>&1; then
    echo "yamllint: not found in PATH." >&2
    echo "Install with: pip install yamllint" >&2
    return 1
  fi

  if [ "$MODE" = "staged" ]; then
    echo "yamllint: checking ${#yaml_files[@]} staged workflow file(s)..."
    yamllint -d relaxed "${yaml_files[@]}"
    return $?
  fi

  echo "yamllint: checking ${#yaml_files[@]} workflow file(s) at $GIT_REF..."

  local file
  for file in "${yaml_files[@]}"; do
    echo "  - $file"
    run_yamllint_on_git_blob "$file" "$GIT_REF"
  done
}

echo "Running local quality checks..."
case "$MODE" in
  staged) echo "Mode: staged files" ;;
  range) echo "Revision range: $REV_RANGE" ;;
  all) echo "Mode: all tracked files" ;;
esac

run_markdownlint
run_yamllint

echo "Local quality checks passed."
