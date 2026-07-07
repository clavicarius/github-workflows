# GitHub Workflows Repository

Dieses Repository enthält zentral verwaltete **wiederverwendbare GitHub Actions Workflows** für mehrere Projekte.

Ziel ist es, wiederkehrende CI/CD-Aufgaben nicht in jedem einzelnen Repository doppelt zu pflegen, sondern sie zentral bereitzustellen und über `workflow_call` einzubinden.

## Vorteile

- ✅ Zentrale Pflege von CI/CD-Standards
- ✅ Einheitliche Workflows über mehrere Repositories hinweg
- ✅ Weniger Duplikation
- ✅ Einfachere Updates und Fehlerbehebungen
- ✅ Wiederverwendbar für private und öffentliche Projekte

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
    uses: claustrarius/github-workflows/.github/workflows/link-check.yml@main
```

Der Workflow wird dabei im Kontext des aufrufenden Repositorys ausgeführt.

Das bedeutet:

- Das Repository mit dem Aufruf wird geprüft.
- Issues werden im aufrufenden Repository erstellt.
- Berechtigungen stammen vom aufrufenden Repository.
- Secrets müssen im aufrufenden Repository konfiguriert werden.

---

# Repository Struktur

Die empfohlene Struktur:

```
.github/
└── workflows/
    ├── link-check.yml
    ├── code-quality.yml
    ├── security-scan.yml
    └── release.yml
```

Jeder Workflow ist eigenständig und kann von anderen Repositories eingebunden werden.

---

# Verfügbare Workflows

## Link Checker

Datei:

```
.github/workflows/link-check.yml
```

Prüft automatisch Links im Repository und erstellt bei Problemen ein GitHub Issue.

### Funktionen

- Prüfung von Markdown-Dateien und Dokumentation
- Erkennung nicht erreichbarer URLs
- Automatische Issue-Erstellung
- Aktualisierung bestehender Reports
- Automatisches Schließen behobener Reports

### Beispiel Einbindung

```yaml
jobs:
  link-check:
    uses: claustrarius/github-workflows/.github/workflows/link-check.yml@main
```

---

# Versionierung

Für produktive Projekte sollte nicht direkt ein Branch verwendet werden:

```yaml
uses: claustrarius/github-workflows/.github/workflows/link-check.yml@main
```

sondern ein stabiler Tag:

```yaml
uses: claustrarius/github-workflows/.github/workflows/link-check.yml@v1
```

Beispiel:

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
    uses: claustrarius/github-workflows/.github/workflows/link-check.yml@v1
```

---

# Secrets

Falls ein Workflow Secrets benötigt, müssen diese im jeweiligen Ziel-Repository hinterlegt werden:

```
Repository
└── Settings
    └── Secrets and variables
        └── Actions
```

Secrets werden nicht automatisch aus dem Workflow-Repository übernommen.

---

# Entwicklung neuer Workflows

Neue Workflows sollten:

1. Eine klare Aufgabe erfüllen
2. Über `workflow_call` aufrufbar sein
3. Keine projektspezifischen Annahmen enthalten
4. Dokumentiert werden
5. Versioniert veröffentlicht werden

Beispiel:

```yaml
name: Example Workflow

on:
  workflow_call:

jobs:
  example:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Example step
        run: echo "Reusable workflow"
```

---

# Aktualisierung bestehender Workflows

Änderungen werden zentral entwickelt:

```text
Workflow Repository
        |
        |
        v
Neue Version erstellen
        |
        |
        v
Tag veröffentlichen
        |
        |
        v
Projekte aktualisieren auf neue Version
```

Beispiel:

Alt:

```yaml
uses: claustrarius/github-workflows/.github/workflows/link-check.yml@v1
```

Neu:

```yaml
uses: claustrarius/github-workflows/.github/workflows/link-check.yml@v2
```

---

# Sicherheitsrichtlinien

Empfehlungen:

- Drittanbieter-Actions möglichst auf feste Versionen pinnen
- Keine unnötigen Schreibrechte vergeben
- Secrets niemals im Workflow-Code speichern
- Änderungen über Pull Requests durchführen

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

# Lizenz

Dieses Repository enthält wiederverwendbare Automatisierungen für GitHub Actions.

Die Nutzung und Weitergabe erfolgt gemäß der im Repository hinterlegten Lizenz.

---

# Wartung

Verantwortlich für dieses Repository:

**claustrarius**

Bei Fehlern oder Verbesserungsvorschlägen bitte ein Issue erstellen.
