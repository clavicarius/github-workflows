#!/usr/bin/env bash
set -euo pipefail

resolve_tag() {
  if [ -n "${INPUT_TAG:-}" ]; then
    printf '%s' "$INPUT_TAG"
    return
  fi

  if [ -n "${GITHUB_REF:-}" ]; then
    printf '%s' "${GITHUB_REF#refs/tags/}"
    return
  fi

  echo "No tag provided and GITHUB_REF is empty." >&2
  exit 1
}

resolve_pattern() {
  case "${VERSION_PATTERN:-simple}" in
    simple)
      PATTERN='^v[1-9][0-9]*$'
      PATTERN_NAME='simple major versioning'
      ;;
    semver)
      PATTERN='^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)'
      PATTERN="${PATTERN}(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)"
      PATTERN="${PATTERN}(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?"
      PATTERN="${PATTERN}(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"
      PATTERN_NAME='semantic versioning (semver)'
      ;;
    *)
      PATTERN="${VERSION_PATTERN}"
      PATTERN_NAME='custom pattern'
      ;;
  esac
}

create_or_update_issue() {
  local title="$1"
  local body_file="$2"
  local label="$3"

  local issue_number
  issue_number=$(gh issue list \
    --state open \
    --label "$label" \
    --search "in:title \"$title\"" \
    --json number \
    --jq '.[0].number // empty')

  if [ -n "$issue_number" ]; then
    echo "Updating issue #$issue_number"
    gh issue edit "$issue_number" --body-file "$body_file"
  else
    echo "Creating new issue"
    gh issue create \
      --title "$title" \
      --body-file "$body_file" \
      --label "$label"
  fi
}

report_issue() {
  local title="$1"
  local body_file="$2"

  if [ "${CREATE_ISSUE_ON_FAILURE:-true}" != "true" ]; then
    return
  fi

  create_or_update_issue "$title" "$body_file" "${ISSUE_LABEL:-invalid-tag}"
}

write_outputs() {
  local valid="$1"
  local max_tag="$2"
  local tag="$3"

  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    {
      echo "valid=$valid"
      echo "max_tag=$max_tag"
      echo "tag=$tag"
    } >> "$GITHUB_OUTPUT"
  fi
}

TAG="$(resolve_tag)"
resolve_pattern

MAX_TAG=''
CHECK_MONOTONICITY="${CHECK_MONOTONICITY:-true}"

echo "Validating tag: $TAG"
echo "Pattern: $PATTERN_NAME"

if ! echo "$TAG" | grep -qEP "$PATTERN"; then
  echo "::error::Tag '$TAG' does not match expected format ($PATTERN_NAME)"
  if [ "${CREATE_ISSUE_ON_FAILURE:-true}" = "true" ]; then
    {
      printf 'Der Tag `%s` ist ungültig.\n\n' "$TAG"
      printf 'Erwartetes Format: `%s`\n' "$PATTERN_NAME"
      printf 'Regex: `%s`\n\n' "$PATTERN"
      printf '%s\n\n' \
        'Bitte erstelle ein neues Tag mit korrektem Format.'
      printf '@%s\n' "${NOTIFY_USER:-}"
    } > "${RUNNER_TEMP:-/tmp}/invalid-tag-body.md"
    report_issue \
      "${INVALID_FORMAT_ISSUE_TITLE:-Invalid version tag report}" \
      "${RUNNER_TEMP:-/tmp}/invalid-tag-body.md"
  fi
  write_outputs false '' "$TAG"
  exit 1
fi

git fetch --tags --prune 2>/dev/null || true

if [ "$PATTERN_NAME" = "simple major versioning" ] \
  && [ "$CHECK_MONOTONICITY" = "true" ]; then
  MAX=0
  while IFS= read -r t; do
    n="${t#v}"
    if (( n > MAX )); then
      MAX="$n"
    fi
  done < <(
    git tag -l 'v[1-9]*' \
      | grep -E '^v[1-9][0-9]*$' \
      | grep -v "^${TAG}$" || true
  )

  MAX_TAG="v${MAX}"
  CUR="${TAG#v}"
  if (( CUR <= MAX )); then
    echo "::error::Tag $TAG is not greater than existing maximum v${MAX}"
    if [ "${CREATE_ISSUE_ON_FAILURE:-true}" = "true" ]; then
      {
        printf 'Der Tag `%s` ist ungültig, weil er nicht größer ist als ' \
          'das aktuell größte existierende Tag (`v%s`).\n\n' "$TAG" "$MAX"
        printf '%s\n\n' \
          'Neue Tags müssen numerisch größer sein als das derzeit größte `vNNN`. Lücken sind erlaubt.'
        printf '%s\n' 'Details:'
        printf -- '- Geprüftes Tag: `%s`\n' "$TAG"
        printf -- '- Größtes bestehendes gültiges Tag: `v%s`\n\n' "$MAX"
        printf '%s\n\n' \
          'Bitte setze ein neues Tag mit einer größeren Nummer.'
        printf '@%s\n' "${NOTIFY_USER:-}"
      } > "${RUNNER_TEMP:-/tmp}/not-monotonic-body.md"
      report_issue \
        "${NOT_MONOTONIC_ISSUE_TITLE:-Invalid version tag (not monotonic) report}" \
        "${RUNNER_TEMP:-/tmp}/not-monotonic-body.md"
    fi
    write_outputs false "$MAX_TAG" "$TAG"
    exit 1
  fi

  echo "Tag $TAG is valid (greater than v${MAX})."
  write_outputs true "$MAX_TAG" "$TAG"
  exit 0
fi

echo "Tag $TAG matches $PATTERN_NAME pattern."
write_outputs true "$MAX_TAG" "$TAG"
