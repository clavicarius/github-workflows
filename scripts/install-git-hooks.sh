#!/usr/bin/env bash
# Install versioned git hooks from scripts/hooks/ (core.hooksPath).
# Requires Git Bash or another POSIX shell.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

HOOKS_PATH="scripts/hooks"

if [ ! -d "$HOOKS_PATH" ]; then
  echo "install-git-hooks: directory not found: $HOOKS_PATH" >&2
  exit 1
fi

git config core.hooksPath "$HOOKS_PATH"

chmod +x "$HOOKS_PATH"/* 2>/dev/null || true
chmod +x "$ROOT/scripts/run-local-quality-checks.sh" "$ROOT/scripts/install-git-hooks.sh" 2>/dev/null || true

echo "Git hooks installed."
echo "  core.hooksPath=$HOOKS_PATH"
echo "  pre-commit  -> markdownlint (docs/*.md), yamllint (.github/workflows)"
echo "  pre-push    -> same checks for commits in the push range"
echo ""
echo "Skip once: SKIP_QUALITY_HOOKS=1 git commit|push"
echo "Manual run: ./scripts/run-local-quality-checks.sh [--staged|<range>]"
