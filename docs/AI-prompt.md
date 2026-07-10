# Projektkontext: Zentrales GitHub Actions Workflow Repository

Ich entwickle ein zentrales Repository für wiederverwendbare GitHub Actions
Workflows und Composite Actions.

Repository:

```
clavicarius/github-workflows
```

Ziel:
CI/CD-Automatisierungen sollen nicht in jedem Projekt dupliziert werden,
sondern zentral gepflegt, versioniert und von mehreren Repositories
eingebunden werden.

---

# Architektur

Das Repository folgt einer zweistufigen Struktur:

```
github-workflows/
├── .github/
│   ├── workflows/
│   │   ├── quality-base-set.yml
│   │   ├── quality-link-check.yml
│   │   ├── quality-markdown.yml
│   │   ├── quality-yaml.yml
│   │   ├── quality-lint.yml
│   │   ├── security-codeql.yml
│   │   ├── security-secret-scan.yml
│   │   ├── security-dependency-review.yml
│   │   ├── release-validate-tags.yml
│   │   ├── release-validate-branch.yml
│   │   ├── release-github.yml
│   │   └── maintenance-link-check.yml
│   │
│   └── actions/
│       ├── quality-link-check/
│       ├── quality-markdown/
│       ├── quality-yaml/
│       ├── quality-lint/
│       ├── security-secret-scan/
│       ├── security-dependency-review/
│       ├── release-validate-tags/
│       └── release-validate-branch/
│
├── docs/
│   ├── workflows/
│   │   ├── README.md
│   │   └── <workflow>.md
│   ├── architecture.md
│   ├── RELEASING.md
│   └── AI-prompt.md
│
├── scripts/
│   ├── validate-version-tag.sh
│   └── validate-release-branch.sh
│
├── README.md
└── AGENTS.md
```

Verantwortungstrennung:

| Schicht | Ort | Aufgabe |
|---|---|---|
| Workflow | `.github/workflows/<name>.yml` | Trigger, Permissions, Orchestrierung |
| Composite Action | `.github/actions/<name>/action.yml` | Wiederverwendbare Implementierung |
| Script | `scripts/*.sh` | Komplexe Shell-Logik |
| Dokumentation | `docs/workflows/<name>.md` | Zweck, Integration, Verhalten |

---

# Architekturprinzipien

## Workflows

`.github/workflows/`

Enthält vollständige GitHub Actions Workflows.

Aufgabe:

- Trigger definieren (`workflow_call` für wiederverwendbare Workflows)
- Permissions setzen
- Jobs orchestrieren
- Composite Actions aufrufen

Workflows sind die öffentliche API für andere Repositories.

Beispiel:

```yaml
jobs:
  check:
    uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@v1
```

Wichtig:

- Keine Unterordner unter `.github/workflows/`
- Keine projektspezifischen Annahmen in wiederverwendbaren Workflows

---

## Composite Actions

`.github/actions/<name>/action.yml`

Enthält wiederverwendbare Implementierungen.

Aufgabe:

- gemeinsame Schritte kapseln
- Workflows schlank halten
- Inputs und Outputs definieren

Beispiel:

```
.github/actions/quality-link-check/action.yml
  ↔ .github/workflows/quality-link-check.yml
```

---

## Scripts

`scripts/`

Komplexe Shell-Logik, die von Composite Actions aufgerufen wird.

Beispiele:

```
scripts/validate-version-tag.sh
scripts/validate-release-branch.sh
```

---

# Dokumentationsstruktur

| Datei | Inhalt |
|---|---|
| `README.md` | Architektur, Verwendung, Versionierung, Sicherheit |
| `AGENTS.md` | Verbindliche Regeln für AI-Agenten |
| `docs/architecture.md` | Aktuelle Repository-Struktur |
| `docs/RELEASING.md` | Tagging-Richtlinie und Release-Prozess |
| `docs/workflows/README.md` | Übersicht aller Workflows |
| `docs/workflows/<workflow>.md` | Detaildokumentation je Workflow |

Jeder Workflow benötigt eine passende Dokumentationsdatei:

```
.github/workflows/<name>.yml
docs/workflows/<name>.md
```

Dokumentiert werden:

- Zweck und Architektur
- Inputs, Outputs und Permissions
- Integration und Beispiele
- Verhalten bei Fehlern
- Versionierung (`@v1`)

---

# Verfügbare Workflows

| Workflow | Kategorie | Dokumentation |
|---|---|---|
| `quality-base-set` | quality | [quality-base-set.md](workflows/quality-base-set.md) |
| `quality-link-check` | quality | [quality-link-check.md](workflows/quality-link-check.md) |
| `quality-markdown` | quality | [quality-markdown.md](workflows/quality-markdown.md) |
| `quality-yaml` | quality | [quality-yaml.md](workflows/quality-yaml.md) |
| `quality-lint` | quality | [quality-lint.md](workflows/quality-lint.md) |
| `security-codeql` | security | [security-codeql.md](workflows/security-codeql.md) |
| `security-secret-scan` | security | [security-secret-scan.md](workflows/security-secret-scan.md) |
| `security-dependency-review` | security | [security-dependency-review.md](workflows/security-dependency-review.md) |
| `release-validate-tags` | release | [release-validate-tags.md](workflows/release-validate-tags.md) |
| `release-validate-branch` | release | [release-validate-branch.md](workflows/release-validate-branch.md) |
| `release-github` | release | [release-github.md](workflows/release-github.md) |
| `maintenance-link-check` | maintenance | [maintenance-link-check.md](workflows/maintenance-link-check.md) |

Übersicht: [docs/workflows/README.md](workflows/README.md)

---

# Release-Pipeline (Quality Base Set)

Internes Repository-Gate bei Tag-Pushes (`v*`):

```
release-validate-tags → release-validate-branch → release-github
```

Details:

- [quality-base-set.md](workflows/quality-base-set.md)
- [RELEASING.md](RELEASING.md)

---

# Namenskonventionen

## Workflow-Dateien

Dateiname:

```
<category>-<purpose>.yml
```

Beispiele:

```
quality-link-check.yml
security-codeql.yml
release-validate-tags.yml
release-github.yml
maintenance-link-check.yml
```

Kategorien:

| Kategorie | Zweck |
|---|---|
| `quality` | Qualitätssicherung, Linting, Strukturprüfungen |
| `security` | Sicherheitsprüfungen |
| `release` | Veröffentlichungen und Tag-Validierung |
| `maintenance` | Geplante Wartungsaufgaben (repository-intern) |

Workflow-`name:` in Title Case, z. B. `Quality Link Check`,
`Release Validate Tags`.

---

## Composite-Action-Ordner

```
<category>-<purpose>
```

Beispiele:

```
quality-link-check
quality-markdown
release-validate-tags
release-validate-branch
```

Wenn ein Workflow eine Composite Action nutzt, sollen Namen übereinstimmen.

---

## Script-Dateien

```
scripts/validate-<purpose>.sh
```

---

# Referenzbeispiel: Quality Link Check

Etabliertes Muster für Workflow + Composite Action:

```
.github/workflows/quality-link-check.yml
.github/actions/quality-link-check/action.yml
```

Workflow (Orchestrierung):

```yaml
name: Quality Link Check

on:
  workflow_call:

permissions:
  contents: read
  issues: write

jobs:
  link-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: clavicarius/github-workflows/.github/actions/quality-link-check@v1
```

Composite Action (Implementierung):

- Lychee ausführen
- Report erzeugen
- Issue erstellen, aktualisieren oder schließen

Standard-Issue:

- Titel: `Link Checker Report`
- Label: `dead-link`

---

# Referenzbeispiel: Release Validate Tags

Muster mit Script + Composite Action + Workflow:

```
.github/workflows/release-validate-tags.yml
.github/actions/release-validate-tags/action.yml
scripts/validate-version-tag.sh
```

Funktionen:

- Tag-Format prüfen (Simple, Semver, Custom)
- Monotonie bei Simple-Versionierung
- GitHub Issue bei Fehlern
- Outputs: `valid`, `max_tag`, `tag`

---

# Versionierung

Produktive Projekte sollen nicht auf Branches zeigen.

Nicht:

```yaml
uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@main
```

Sondern:

```yaml
uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@v1
```

Versionierung über Git Tags:

```bash
git tag v1
git push origin v1
```

Regel:

- kompatible Änderungen → gleiche Major-Version
- Breaking Changes → neue Major-Version

---

# Berechtigungen

Grundsatz: Least Privilege.

Beispiel Link Check:

```yaml
permissions:
  contents: read
  issues: write
```

Release GitHub benötigt zusätzlich `contents: write` im aufrufenden Job.

---

# Regeln für AI-Agenten

Verbindliche Regeln stehen in `AGENTS.md`. Kurzfassung:

- bestehende Struktur einhalten
- keine Workflows in Unterordner von `.github/workflows/`
- Workflow und Dokumentation immer zusammen pflegen
- Composite Actions und Scripts für Implementierungslogik nutzen
- keine projektspezifische Logik im zentralen Repository
- keine unnötigen Permissions
- interne CI mit `./.github/actions/...`, externe Nutzung mit `@v1`

Pflicht bei neuen Workflows:

```
.github/workflows/<name>.yml
docs/workflows/<name>.md
```

---

# Hinweise für neue Arbeit

Vor Erstellung eines neuen Workflows prüfen:

1. Gibt es bereits einen passenden Workflow?
2. Kann die Logik als Composite Action umgesetzt werden?
3. Ist die Lösung für mehrere Projekte nutzbar?
4. Ist Dokumentation in `docs/workflows/` erforderlich?

Offene Erweiterungen (Beispiele, nicht abschließend):

- weitere `quality-*` Workflows nach Bedarf
- zusätzliche `release-*` Schritte
- weitere `security-*` Prüfungen
