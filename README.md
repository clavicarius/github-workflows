# GitHub Workflows Repository

Dieses Repository enthält zentral verwaltete
**wiederverwendbare GitHub Actions Workflows** und **Composite Actions** für mehrere Projekte.

Ziel ist es, wiederkehrende CI/CD-Aufgaben nicht in jedem einzelnen Repository doppelt zu pflegen,
sondern sie zentral bereitzustellen und über `workflow_call` einzubinden.

Die Workflows in diesem Repository stellen eine gemeinsame CI/CD-Basis für mehrere Projekte bereit
und werden versioniert veröffentlicht.

---

# Vorteile

- ✅ Zentrale Pflege von CI/CD-Standards
- ✅ Einheitliche Workflows über mehrere Repositories hinweg
- ✅ Weniger Duplikation
- ✅ Einfachere Updates und Fehlerbehebungen
- ✅ Wiederverwendbar für private und öffentliche Projekte
- ✅ Klare Trennung zwischen Workflow-Definition und Implementierung
- ✅ Versionierbare CI/CD-Komponenten

---

# Architektur

[Details](docs/architecture.md)

---

# Workflow Layer

Der Ordner:

```bash
.github/workflows/
```

enthält ausschließlich vollständige GitHub Actions Workflows.

Diese Dateien sind die öffentlichen Einstiegspunkte für andere Repositorys.

Beispiele:

```bash
.github/workflows/

quality-link-check.yml
security-codeql.yml
release-validate-tags.yml
release-validate-branch.yml
release-github.yml
```

Ein Workflow kann von anderen Repositorys eingebunden werden:

```yaml
jobs:
  link-check:
    uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@v1
```

[Details](docs/workflows/README.md)

---

# Composite Actions

Wiederverwendbare Einzelschritte werden als Composite Actions gekapselt.

Ablage:

```bash
.github/actions/<action-name>/action.yml
```

Beispiele:

```bash
.github/actions/

quality-link-check/
quality-markdown/
release-validate-tags/
```

Composite Actions enthalten wiederverwendbare Implementierungsdetails, während Workflows die Orchestrierung übernehmen.

Beispiel:

```yaml
- name: Check links
  uses: clavicarius/github-workflows/.github/actions/quality-link-check@v1
```

---

# Verwendung

Workflows aus diesem Repository können als **Reusable Workflows** eingebunden werden.

Beispiel:

```yaml
name: Link Check

on:
  workflow_dispatch:
  schedule:
    - cron: "11 11 * * 0"

jobs:
  link-check:
    uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@v1
```

Der Workflow wird dabei im Kontext des aufrufenden Repositorys ausgeführt.

Das bedeutet:

- Das Repository mit dem Aufruf wird geprüft.
- Issues werden im aufrufenden Repository erstellt.
- Berechtigungen stammen vom aufrufenden Repository.
- Secrets müssen im aufrufenden Repository konfiguriert werden.

---

# Verfügbare Workflows

[Details](docs/workflows/README.md)

## GitHub Release

Datei:

```bash
.github/workflows/release-github.yml
```

Erzeugt ein GitHub Release für einen bestehenden Tag, generiert automatisch Release Notes
und kann Artefakte aus dem aufrufenden Workflow an das Release anhängen.

Weitere Details: `docs/workflows/release-github.md`

# Namenskonventionen

## Workflows (Naming conventions)

Workflow-Dateien verwenden folgende Struktur:

```bash
<bereich>-<funktion>.yml
```

Beispiele:

```bash
quality-link-check.yml
security-codeql.yml
release-validate-tags.yml
release-github.yml
```

Verfügbare Bereiche:

| Bereich | Beschreibung |
|---|---|
| quality | Qualitätssicherung, Tests, Linting |
| security | Sicherheitsprüfungen |
| build | Build-Prozesse |
| release | Veröffentlichungen |
| maintenance | Wartungsaufgaben |

---

## Composite Actions (Naming conventions)

Composite Actions verwenden:

```bash
<category>-<purpose>
```

Beispiele:

```bash
quality-link-check
quality-markdown
release-validate-tags
release-validate-branch
```

---

# Versionierung

Für produktive Projekte sollte nicht direkt ein Branch verwendet werden.

Nicht empfohlen:

```yaml
uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@main
```

Empfohlen:

```yaml
uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@v1
```

Versionen werden über Git Tags verwaltet:

```bash
git tag v1
git push origin v1
```

Vorteile:

- Reproduzierbare Builds
- Kontrollierte Updates
- Keine unerwarteten Änderungen durch neue Commits

---

# Berechtigungen

Reusable Workflows benötigen explizite Berechtigungen.

Beispiel:

```yaml
permissions:
  contents: read
  issues: write
```

Die Berechtigungen werden im aufrufenden Repository vergeben.

Beispiel:

```yaml
name: Link Check

on:
  workflow_dispatch:

permissions:
  contents: read
  issues: write

jobs:
  check:
    uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@v1
```

---

# Secrets

Falls ein Workflow Secrets benötigt, müssen diese im jeweiligen Ziel-Repository hinterlegt werden:

```bash
Repository
└── Settings
    └── Secrets and variables
        └── Actions
```

Secrets werden nicht automatisch aus dem Workflow-Repository übernommen.

---

# Entwicklung neuer Workflows

Neue Workflows müssen:

1. Eine klar definierte Aufgabe erfüllen
2. Über `workflow_call` aufrufbar sein
3. Keine projektspezifischen Annahmen enthalten
4. Dokumentiert werden
5. Versioniert veröffentlicht werden

Vor Erstellung eines neuen Workflows prüfen:

- Gibt es bereits einen passenden Workflow?
- Kann die Funktion als Composite Action umgesetzt werden?
- Ist die Lösung für mehrere Projekte nutzbar?

---

# Entwicklungsprozess

Änderungen erfolgen grundsätzlich über Pull Requests.

Ablauf:

```bash
Feature Branch
      |
      v
Pull Request
      |
      v
Review
      |
      v
Merge
      |
      v
Release Tag
```

---

# Aktualisierung bestehender Workflows

Änderungen werden zentral entwickelt:

```bash
Workflow Repository
        |
        v
Neue Version erstellen
        |
        v
Tag veröffentlichen
        |
        v
Projekte aktualisieren
```

Beispiel:

Alt:

```yaml
uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@v1
```

Neu:

```yaml
uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@v2
```

---

# Sicherheitsrichtlinien

Alle Workflows sollen:

- minimale Berechtigungen verwenden
- Secrets niemals im Repository speichern
- Drittanbieter-Actions möglichst versioniert einbinden
- unnötige Schreibrechte vermeiden

Beispiel:

Gut:

```yaml
uses: actions/checkout@v4
```

Noch sicherer:

```yaml
uses: actions/checkout@<commit-sha>
```

---

# AI-Agenten und Automatisierung

Dieses Repository enthält zusätzlich eine Datei:

```bash
AGENTS.md
```

Diese beschreibt verbindliche Regeln für AI-Agenten und Coding-Assistenten.

AI-Tools müssen insbesondere beachten:

- Workflow-Dateien niemals in Unterordner von `.github/workflows` verschieben
- bestehende Architektur einhalten
- Composite Actions bevorzugen
- keine projektspezifische Logik hinzufügen
- Dokumentation aktualisieren

---

# Lizenz

Dieses Repository enthält wiederverwendbare Automatisierungen für GitHub Actions.

Die Nutzung und Weitergabe erfolgt gemäß der im Repository hinterlegten Lizenz.

---

# Wartung

Verantwortlich für dieses Repository:

**clavicarius** (https://github.com/clavicarius/github-workflows/)

Bei Fehlern oder Verbesserungsvorschlägen bitte ein Issue erstellen.
