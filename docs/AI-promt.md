# Projektkontext: Zentrales GitHub Actions Workflow Repository

Ich entwickle ein zentrales Repository für wiederverwendbare GitHub Actions Workflows und Composite Actions.

Repository:

```
clavicarius/github-workflows
```

Ziel:
CI/CD-Automatisierungen sollen nicht in jedem Projekt dupliziert werden, sondern zentral gepflegt, versioniert und von mehreren Repositories eingebunden werden.

---

# Architektur

Das Repository folgt einer skalierbaren Struktur:

```
.github/
├── workflows/
│   ├── quality-link-check.yml
│   ├── security-codeql.yml
│   └── release-docker.yml
│
└── actions/
    ├── quality-link-check/
    │   └── action.yml
    ├── setup-environment/
    │   └── action.yml
    └── docker-build/
        └── action.yml

docs/
├── workflows/
│   ├── README.md
│   ├── quality-link-check.md
│   ├── security-codeql.md
│   └── release-docker.md
│
└── actions/
    └── ...

scripts/
README.md
AGENTS.md
```

---

# Architekturprinzipien

## Workflows

`.github/workflows/`

Enthält nur vollständige GitHub Actions Workflows.

Aufgabe:

- Trigger definieren
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

---

## Composite Actions

`.github/actions/`

Enthält wiederverwendbare Implementierungen.

Aufgabe:

- gemeinsame Schritte kapseln
- komplexe Logik aufnehmen
- Workflows schlank halten

Beispiel:

```
.github/actions/quality-link-check/action.yml
```

---

# Dokumentationsstruktur

README.md:
- beschreibt Architektur
- beschreibt Verwendung
- beschreibt Versionierung
- beschreibt Sicherheitsregeln

AGENTS.md:
- enthält Regeln für AI-Agenten
- verhindert Architekturverletzungen
- beschreibt Namenskonventionen

Workflow-Dokumentation:

```
docs/workflows/
```

Jeder Workflow bekommt eine eigene Datei:

Beispiel:

```
docs/workflows/quality-link-check.md
```

Dokumentiert werden:

- Zweck
- Funktionen
- Voraussetzungen
- Berechtigungen
- Integration
- Verhalten
- Versionierung

---

# Namenskonventionen

Workflows:

```
<bereich>-<funktion>.yml
```

Beispiele:

```
quality-link-check.yml
security-codeql.yml
release-docker.yml
```

Bereiche:

| Bereich | Zweck |
|-|-|
| quality | Qualitätssicherung |
| security | Sicherheitsprüfungen |
| build | Build-Prozesse |
| release | Veröffentlichungen |
| maintenance | Wartung |

Composite Actions:

```
<funktion>
```

Beispiele:

```
quality-link-check
docker-build
setup-node
```

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

- Patch/kompatible Änderungen → gleiche Major-Version
- Breaking Changes → neue Major-Version

---

# Aktueller Workflow: Quality Link Check

Ziel:

Automatische Prüfung von Links in Repositorys.

Technik:

- Lychee als Link Checker
- GitHub CLI (`gh`) für Issue-Verwaltung

Funktionen:

- Markdown/Documentation Links prüfen
- Fehlerreport erzeugen
- GitHub Issue erstellen
- vorhandenes Issue aktualisieren
- behobene Fehler automatisch schließen

---

# Zielstruktur Quality Link Check

```
.github/

├── workflows/
│   └── quality-link-check.yml
│
└── actions/
    └── quality-link-check/
        └── action.yml
```

---

# Workflow

Datei:

```
.github/workflows/quality-link-check.yml
```

Aufgabe:

- workflow_call bereitstellen
- Permissions definieren
- Composite Action aufrufen

Beispiel:

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

---

# Composite Action

Datei:

```
.github/actions/quality-link-check/action.yml
```

Aufgabe:

1. Lychee ausführen
2. Report erzeugen
3. Issue erstellen oder aktualisieren
4. Issue schließen, wenn Fehler behoben

Standardwerte:

Issue Titel:

```
Link Checker Report
```

Label:

```
dead-link
```

---

# Issue-Verhalten

Wenn defekte Links vorhanden:

- Suche nach vorhandenem offenen Issue
- Falls vorhanden:
  - Body aktualisieren

- Falls nicht vorhanden:
  - neues Issue erstellen

Wenn keine defekten Links vorhanden:

- vorhandenes Issue schließen
- Kommentar hinzufügen:

```
All broken links have been fixed.
```

---

# Berechtigungen

Benötigt:

```yaml
permissions:
  contents: read
  issues: write
```

Voraussetzung:

GitHub Issues müssen im Zielrepository aktiviert sein.

---

# Regeln für AI-Agenten

AI-Agenten müssen:

- bestehende Struktur einhalten
- keine Workflows in Unterordner von `.github/workflows` legen
- neue Workflow-Dateien dokumentieren
- Composite Actions bevorzugen
- keine projektspezifische Logik im zentralen Repository hinzufügen
- keine unnötigen Permissions hinzufügen

Workflow:

```
.github/workflows/<name>.yml
```

Dokumentation:

```
docs/workflows/<name>.md
```

müssen immer zusammen gepflegt werden.

---

# Nächste mögliche Schritte

Offene Themen:

1. Finalisierung der `quality-link-check` Composite Action
2. Erstellung der Dokumentation:
   - docs/workflows/README.md
   - docs/workflows/quality-link-check.md

3. Erstellung weiterer Standard-Workflows:
   - Security Scan
   - Dependency Review
   - Code Quality
   - Docker Build
   - Release Automation

4. Release- und Tagging-Strategie für das Workflow Repository definieren
