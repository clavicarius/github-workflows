# Release Validate Tags

Datei:

```
.github/workflows/release-validate-tags.yml
.github/actions/release-validate-tags/action.yml
scripts/validate-version-tag.sh
```

---

## Zweck

Der **Release Validate Tags Workflow** prüft automatisch, ob ein neu gesetztes
Git-Tag dem vorgeschriebenen Versionsformat entspricht und bei Simple-
Versionierung monoton steigend ist.

Er verhindert ungültige Releases durch fehlerhafte Tag-Namen und benachrichtigt
den Trigger-Auslöser bei Verstößen über ein GitHub Issue.

---

## Architektur

| Komponente | Verantwortung |
|---|---|
| `release-validate-tags.yml` | Trigger, Permissions, Job-Orchestrierung |
| `release-validate-tags/action.yml` | Composite Action mit Inputs und Outputs |
| `scripts/validate-version-tag.sh` | Validierungslogik und Issue-Reporting |

---

## Funktionen

Der Workflow:

- validiert das Tag-Format gegen ein konfigurierbares Regex-Pattern
- unterstützt zwei vordefinierte Muster: **Simple** und **Semver**
- prüft bei Simple-Versionierung optional die Monotonie
- erstellt oder aktualisiert ein GitHub Issue bei Regelverstößen
- kann als wiederverwendbarer Workflow über `workflow_call` aufgerufen werden

---

## Vordefinierte Versionierungsmuster

### Simple (Standard)

**Name:** `simple`  
**Regex:** `^v[1-9][0-9]*$`  
**Monotonie:** ja (wenn `check-monotonicity: true`)

| Beispiel | Gültig | Grund |
|---|---|---|
| `v1` | ja | Erste Version |
| `v2`, `v10`, `v123` | ja | Monoton steigend |
| `v0` | nein | Kleinste erlaubte Version ist v1 |
| `v01` | nein | Führende Nullen verboten |

Lücken sind erlaubt (z. B. `v1` → `v4` ist gültig, sofern `v4` > höchstes existierendes Tag).

### Semver

**Name:** `semver`  
**Regex:** Vollständige Semantic Versioning Spezifikation  
**Monotonie:** nein — es wird nur das Regex-Format geprüft

| Beispiel | Gültig | Grund |
|---|---|---|
| `v1.0.0` | ja | Standard semver |
| `v1.2.3` | ja | Standard semver |
| `v2.0.0-rc.1` | ja | Prerelease |
| `v1.0.0+build.1` | ja | Build-Metadaten |
| `v1.0` | nein | Patch-Version erforderlich |
| `v1` | nein | Minor und Patch erforderlich |

### Custom Pattern

Sie können jedes gültige Regex-Pattern übergeben, z. B.:

- `^v[0-9]+\.[0-9]+$` für Major.Minor-only
- `^release-\d{4}-\d{2}$` für Datum-basierte Tags

Bei Custom Patterns wird keine Monotonie-Prüfung durchgeführt.

---

## Inputs

| Name | Typ | Erforderlich | Standard | Beschreibung |
|---|---|---|---|---|
| `tag` | string | nein | `''` | Tag zum Validieren. Leer = aus `github.ref` abgeleitet. |
| `version-pattern` | string | nein | `'simple'` | `simple`, `semver`, oder Custom-Regex. |
| `check-monotonicity` | boolean | nein | `true` | Monotonie nur für `simple`. |
| `create-issue-on-failure` | boolean | nein | `true` | Issue bei Fehlern erstellen/aktualisieren. |
| `issue-label` | string | nein | `invalid-tag` | Label für Issue-Reports. |
| `invalid-format-issue-title` | string | nein | `Invalid version tag report` | Titel bei Formatfehlern. |
| `not-monotonic-issue-title` | string | nein | `Invalid version tag (not monotonic) report` | Titel bei Monotoniefehlern. |
| `notify-user` | string | nein | `github.actor` | GitHub-User für Issue-Mentions. |

---

## Outputs

| Name | Beschreibung |
|---|---|
| `valid` | `true`, wenn das Tag gültig ist |
| `max_tag` | Höchstes gültiges Simple-Tag (z. B. `v5`) |
| `tag` | Geprüftes Tag |

---

## Benötigte Berechtigungen

```yaml
permissions:
  contents: read
  issues: write
```

---

## Integration

### Über Quality Base Set (dieses Repository)

```yaml
release-validate-tags:
  uses: ./.github/workflows/release-validate-tags.yml
  with:
    tag: ${{ github.ref_name }}
```

### Als wiederverwendbarer Workflow

```yaml
on:
  push:
    tags:
      - 'v*'

jobs:
  validate-tag:
    uses: clavicarius/github-workflows/.github/workflows/release-validate-tags.yml@v1
    with:
      tag: ${{ github.ref_name }}
      version-pattern: 'semver'
```

### Nur die Composite Action

```yaml
steps:
  - uses: actions/checkout@v4
    with:
      fetch-depth: 0
  - uses: clavicarius/github-workflows/.github/actions/release-validate-tags@v1
    with:
      tag: ${{ github.ref_name }}
      notify-user: ${{ github.actor }}
```

---

## Verhalten bei Fehlern

Wenn das Tag ungültig ist:

- schlägt der Workflow-Job mit einem `::error::`-Annotation fehl
- wird ein GitHub Issue erstellt oder aktualisiert
- der Trigger-Auslöser wird im Issue erwähnt
- nachgelagerte Jobs mit `needs:` werden blockiert

---

## Weiterführende Dokumentation

- [Release- und Tagging-Richtlinie](../RELEASING.md)
- [Semantic Versioning](https://semver.org/)
- [Quality Base Set](quality-base-set.md)

---

## Versionierung

```
v1
```

```yaml
uses: clavicarius/github-workflows/.github/workflows/release-validate-tags.yml@v1
```
