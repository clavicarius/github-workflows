#!/usr/bin/env bash
set -euo pipefail

ZERO_SHA='0000000000000000000000000000000000000000'

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

append_notify_user() {
  if [ -n "${NOTIFY_USER:-}" ]; then
    printf '@%s\n' "$NOTIFY_USER"
  fi
}

write_outputs() {
  local valid="$1"

  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "valid=$valid" >> "$GITHUB_OUTPUT"
  fi
}

is_tag_update() {
  local created="${TAG_CREATED:-}"
  local before="${TAG_BEFORE:-}"

  if [ "$created" = "false" ]; then
    return 0
  fi

  if [ -n "$before" ] && [ "$before" != "$ZERO_SHA" ]; then
    return 0
  fi

  return 1
}

TAG="$(resolve_tag)"

if [ -z "${TAG_CREATED:-}" ] && [ -z "${TAG_BEFORE:-}" ]; then
  echo "Skipping immutability check: no push event metadata (tag-created/tag-before)."
  write_outputs true
  exit 0
fi

echo "Checking tag immutability for: $TAG"

if is_tag_update; then
  echo "::error::Tag '$TAG' was updated. Existing tags must not be moved or force-pushed."
  if [ "${CREATE_ISSUE_ON_FAILURE:-true}" = "true" ]; then
    {
      printf 'Der Tag `%s` wurde aktualisiert (force-push oder Verschieben).\n\n' \
        "$TAG"
      printf '%s\n\n' \
        'Bereits veröffentlichte Tags dürfen nicht geändert werden. Erstelle stattdessen ein neues Tag mit einer höheren Versionsnummer.'
      printf '%s\n' 'Details:'
      printf -- '- Geprüftes Tag: `%s`\n' "$TAG"
      if [ -n "${TAG_BEFORE:-}" ] && [ "${TAG_BEFORE}" != "$ZERO_SHA" ]; then
        printf -- '- Vorheriger Commit: `%s`\n' "$TAG_BEFORE"
      fi
      if [ -n "${GITHUB_SHA:-}" ]; then
        printf -- '- Aktueller Commit: `%s`\n\n' "$GITHUB_SHA"
      fi
      append_notify_user
    } > "${RUNNER_TEMP:-/tmp}/immutable-tag-body.md"
    report_issue \
      "${ISSUE_TITLE:-Immutable version tag report}" \
      "${RUNNER_TEMP:-/tmp}/immutable-tag-body.md"
  fi
  write_outputs false
  exit 1
fi

echo "OK: tag '$TAG' is newly created."
write_outputs true
