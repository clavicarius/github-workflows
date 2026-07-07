# Broken Link Checker Workflow

This repository uses a GitHub Actions workflow to automatically detect broken links in the documentation and keep track of them using GitHub Issues.

## Features

- Runs automatically every Sunday at **11:11 UTC**
- Can also be started manually from the **Actions** tab
- Checks all supported files for broken links using [Lychee](https://github.com/lycheeverse/lychee)
- Creates a GitHub issue when broken links are found
- Updates the existing issue instead of creating duplicates
- Automatically closes the issue once all broken links have been fixed

## Workflow

The workflow performs the following steps:

1. Check out the repository.
2. Run the Lychee link checker.
3. If broken links are found:
   - Create a new issue titled **"Link Checker Report"** if none exists.
   - Otherwise update the existing issue with the latest report.
4. If no broken links are found:
   - Automatically close the existing **"Link Checker Report"** issue.

## Schedule

The workflow is configured to run weekly:

```yaml
schedule:
  - cron: "11 11 * * 0"
```

This corresponds to:

- **Sunday**
- **11:11 UTC**

It can also be triggered manually using **workflow_dispatch**.

## Required Permissions

The workflow requires the following permissions:

```yaml
permissions:
  contents: read
  issues: write
```

These permissions allow the workflow to:

- Read the repository contents
- Create, update, and close GitHub issues

## Issue Management

The workflow maintains a single issue with the title:

> **Link Checker Report**

Behavior:

| Link check result | Action |
|-------------------|--------|
| Broken links found | Create or update the issue |
| No broken links found | Close the existing issue |

This prevents duplicate issues while keeping the latest report available.

## Dependencies

- GitHub Actions
- Ubuntu runner
- `claustrarius/lychee-action`
- GitHub CLI (`gh`), which is preinstalled on GitHub-hosted runners
