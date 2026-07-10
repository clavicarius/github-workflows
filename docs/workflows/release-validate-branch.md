# Release Validate Branch

Datei:

```
.github/workflows/release-validate-branch.yml
actions/release-validate-branch/action.yml
scripts/validate-release-branch.sh
```

---

## Zweck

Der **Release Validate Branch Workflow** prüft, ob ein Release-Tag auf einen
Commit zeigt, der auf dem konfigurierten Release-Branch (Standard: `main`)
liegt.

Er verhindert Releases von Feature-Branches oder anderen nicht freigegebenen
Branches.

---

## Architektur

| Komponente | Verantwortung |
|---|---|
| `release-validate-branch.yml` | Trigger, Permissions, Job-Orchestrierung |
| `release-validate-branch/action.yml` | Composite Action mit Inputs |
| `scripts/validate-release-branch.sh` | Git-Prüfung gegen `origin/<branch>` |

---

## Funktionen

Der Workflow:

- prüft, ob der Tag-Commit auf `origin/main` (oder einem anderen Branch)
  enthalten ist
- schlägt fehl, wenn der Commit nicht auf dem Release-Branch liegt
- kann als wiederverwendbarer Workflow über `workflow_call` aufgerufen werden

---

## Inputs

| Input | Typ | Standard | Beschreibung |
|---|---|---|---|
| `commit-sha` | string | `github.sha` | Commit SHA des Tags |
| `branch` | string | `main` | Erforderlicher Release-Branch |

---

## Integration

### Quality Base Set

Im Quality Base Set wird der Workflow nach `release-validate-tags` und vor
`release-github` ausgeführt:

```
release-validate-tag-immutable
  → release-validate-tags
    → release-validate-branch
      → release-github
```

### Direkter Aufruf

```yaml
jobs:
  validate-branch:
    uses: clavicarius/ci-platform/.github/workflows/release-validate-branch.yml@v1
```

---

## Fehlerverhalten

Wenn der Tag-Commit nicht auf dem Release-Branch liegt, schlägt der Job mit
einer Fehlermeldung fehl. Das nachfolgende `release-github` wird nicht
ausgeführt.

---

## Siehe auch

- [Quality Base Set](quality-base-set.md)
- [Release Validate Tags](release-validate-tags.md)
- [Release GitHub](release-github.md)
