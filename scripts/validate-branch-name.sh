#!/usr/bin/env bash
set -euo pipefail

BRANCH_NAME="${BRANCH_NAME:-}"
BRANCH_REGEX="${BRANCH_REGEX:-^(feature|enhancement|bugfix|hotfix|release|chore|copilot)/[a-z0-9._-]+$}"

if [[ -z "${BRANCH_NAME}" ]]; then
  echo "::error::Unable to determine source branch name (github.head_ref is empty)."
  exit 1
fi

if [[ "${BRANCH_NAME}" =~ ${BRANCH_REGEX} ]]; then
  echo "✅ Branch name '${BRANCH_NAME}' is valid."
  exit 0
fi

echo "::error::Invalid branch name '${BRANCH_NAME}'."
echo "::error::Expected format: <prefix>/<name>."
echo "::error::Allowed prefixes: feature, enhancement, bugfix, hotfix, release, chore, copilot."
echo "::error::Allowed characters in <name>: lowercase letters, numbers, dot, underscore, hyphen."
echo "::error::Required regex: ${BRANCH_REGEX}"
exit 1
