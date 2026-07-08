# AGENTS.md

## Purpose

This document defines mandatory rules for AI agents and automated coding assistants working with this repository.

The repository contains centrally managed GitHub Actions Workflows and Composite Actions.

AI agents MUST preserve the architecture and conventions described below.

---

# Repository Architecture Rules

The repository follows this structure:

```
.github/
├── workflows/
└── actions/

docs/

scripts/
```

---

# Workflow Rules

## Location

Reusable workflows MUST be stored directly in:

```
.github/workflows/
```

Do NOT create subdirectories below:

```
.github/workflows/
```

Invalid:

```
.github/workflows/security/codeql.yml
```

Valid:

```
.github/workflows/security-codeql.yml
```

---

## Workflow Naming

Workflow files MUST follow:

```
<category>-<purpose>.yml
```

Examples:

```
quality-link-check.yml
security-codeql.yml
release-docker.yml
```

---

## Reusability

Every reusable workflow SHOULD use:

```yaml
on:
  workflow_call:
```

Workflows MUST NOT contain assumptions about a single consuming repository.

---

# Composite Action Rules

Reusable step collections SHOULD be implemented as Composite Actions.

Location:

```
.github/actions/<action-name>/action.yml
```

Examples:

```
.github/actions/
├── lychee-check/
├── docker-build/
└── setup-node/
```

---

# Separation of Responsibilities

AI agents MUST keep the following separation:

## Workflow

Responsible for:

- triggers
- permissions
- job orchestration
- calling actions

## Composite Action

Responsible for:

- reusable implementation steps
- shared logic

## Scripts

Responsible for:

- complex shell logic
- helper automation

---

# Security Rules

AI agents MUST:

- use least privilege permissions
- avoid adding unnecessary write permissions
- never commit secrets
- avoid hardcoded credentials

Preferred:

```yaml
permissions:
  contents: read
```

---

# Versioning Rules

References to this repository SHOULD use release tags.

Preferred:

```yaml
@v1
```

Avoid:

```yaml
@main
```

for production usage.

---

# Documentation Rules

Every workflow MUST have a corresponding documentation file:

Workflow:
.github/workflows/<name>.yml

Documentation:
docs/workflows/<name>.md

AI agents MUST update documentation when adding or modifying workflows.

---
---

# Change Management

AI agents MUST:

1. Check existing conventions before adding files.
2. Avoid unnecessary workflow duplication.
3. Prefer extending existing actions.
4. Update documentation when adding new workflows.
5. Mention breaking changes.

---

# Forbidden Changes

AI agents MUST NOT:

- move workflow files into subdirectories
- create project-specific workflows here
- duplicate existing functionality
- remove documentation without replacement
- change naming conventions without approval

---

# Before Creating a New Workflow

AI agents MUST verify:

1. Does an existing workflow already solve this?
2. Can the requirement be implemented as a Composite Action?
3. Is the workflow reusable?
4. Is documentation required?

---

# Expected Output Quality

Changes should be:

- minimal
- consistent
- reusable
- documented
- compatible with existing consumers
