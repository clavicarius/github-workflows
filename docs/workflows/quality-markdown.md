# Quality Markdown

Datei:

```
.github/workflows/quality-markdown.yml
.github/actions/quality-markdown/action.yml
```

---

## Zweck

Der **Quality Markdown Workflow** prüft die Qualität von Markdown-Dokumentation.

Er ist besonders sinnvoll für Dokumentations-Repositories und kombiniert:

- **markdownlint** für Syntax, Überschriften und Tabellen
- **Lychee** für Link-Validierung

---

## Prüft

- Markdown-Syntax
- Links
- Tabellen
- Überschriften

---

## Funktionen

Der Workflow:

- validiert Markdown-Dateien mit markdownlint
- prüft interne und externe Links mit Lychee
- kann bei Link-Fehlern optional GitHub Issues erstellen
- unterstützt gezielte Verzeichnisse und eigene Konfigurationsdateien

---

## Inputs

| Name | Typ | Erforderlich | Standard | Beschreibung |
|---|---|---|---|---|
| `working-directory` | string | nein | `.` | Verzeichnis für Markdown-Prüfungen. |
| `markdown-glob` | string | nein | `''` | Glob für Markdown-Dateien. |
| `markdownlint-config` | string | nein | `''` | Pfad zur markdownlint-Konfiguration. |
| `enable-markdownlint` | boolean | nein | `true` | Aktiviert markdownlint. |
| `enable-link-check` | boolean | nein | `true` | Aktiviert Lychee Link-Checks. |
| `fail-on-link-errors` | boolean | nein | `true` | Workflow schlägt bei defekten Links fehl. |
| `lychee-args` | string | nein | `''` | Zusätzliche Lychee-Argumente. |
| `create-link-issue` | boolean | nein | `false` | Erstellt oder aktualisiert ein Issue bei Link-Fehlern. |
| `issue-title` | string | nein | `Markdown Link Checker Report` | Titel des Link-Issues. |
| `issue-label` | string | nein | `dead-link` | Label des Link-Issues. |
| `link-report-file` | string | nein | `./lychee/out.md` | Lychee-Reportdatei. |

---

## Voraussetzungen

Mindestberechtigungen:

```yaml
permissions:
  contents: read
```

Für Issue-Reports zusätzlich:

```yaml
permissions:
  issues: write
```

Optional im Repository:

- `.markdownlint.json`, `.markdownlint.yaml` oder `.markdownlint-cli2.yaml`
- `.lycheeignore` für ausgeschlossene URLs

---

## Integration

### Pull Request Gate

```yaml
name: Quality Markdown

on:
  pull_request:
  push:
    branches:
      - main

permissions:
  contents: read

jobs:
  markdown:
    uses: clavicarius/github-workflows/.github/workflows/quality-markdown.yml@v1
```

### Nur Dokumentationsverzeichnis

```yaml
jobs:
  markdown:
    uses: clavicarius/github-workflows/.github/workflows/quality-markdown.yml@v1
    with:
      working-directory: docs
```

### Geplanter Link-Report mit Issue

```yaml
name: Markdown Link Monitor

on:
  schedule:
    - cron: "11 11 * * 0"
  workflow_dispatch:

permissions:
  contents: read
  issues: write

jobs:
  markdown:
    uses: clavicarius/github-workflows/.github/workflows/quality-markdown.yml@v1
    with:
      fail-on-link-errors: false
      create-link-issue: true
```

### Nur markdownlint ohne Link-Check

```yaml
jobs:
  markdown:
    uses: clavicarius/github-workflows/.github/workflows/quality-markdown.yml@v1
    with:
      enable-link-check: false
```

---

## Benötigte Berechtigungen

| Permission | Zweck |
|---|---|
| `contents: read` | Repository auschecken und Markdown-Dateien lesen |
| `issues: write` | Optional für automatische Link-Issue-Reports |

---

## Verhalten bei Fehlern

Der Workflow schlägt fehl, wenn:

- markdownlint Regelverstöße findet
- Lychee defekte Links findet und `fail-on-link-errors: true` ist

Der Workflow kann weiterlaufen und ein Issue erzeugen, wenn:

- `fail-on-link-errors: false` und `create-link-issue: true` gesetzt sind

---

## Unterschied zu Quality Link Check

| Workflow | Fokus |
|---|---|
| `quality-markdown.yml` | Gesamtqualität von Markdown inkl. Syntax und Struktur |
| `quality-link-check.yml` | Link-Monitoring mit dauerhaftem Issue-Reporting |

---

## Benötigte Komponenten

Verwendete Actions und Tools:

- `actions/checkout`
- `DavidAnson/markdownlint-cli2-action`
- `lycheeverse/lychee-action`
- GitHub CLI (`gh`) für optionale Issue-Verwaltung

---

## Versionierung

Aktuelle Version:

```
v1
```

Verwendung:

```yaml
uses: clavicarius/github-workflows/.github/workflows/quality-markdown.yml@v1
```

---

## Änderungen

Breaking Changes werden über neue Major-Versionen veröffentlicht:

```
v1 → v2
```
