# Available Workflows

Dieses Verzeichnis dokumentiert alle verfügbaren wiederverwendbaren GitHub Actions Workflows.

Jeder Workflow wird separat dokumentiert und beschreibt:

- Zweck
- Einsatzgebiet
- Voraussetzungen
- benötigte Berechtigungen
- Konfiguration
- Beispielintegration
- Verhalten bei Fehlern

---

# Workflow Übersicht

| Workflow | Beschreibung |
|---|---|
| [Quality Base Set](quality-base-set.md) | Interner PR-Gate und Release-Orchestrierung für dieses Repository |
| [Quality Link Check](quality-link-check.md) | Prüft Links und verwaltet automatisch Reports |
| [Quality Lint](quality-lint.md) | Führt einheitliche Codequalitätsprüfungen durch |
| [Quality Markdown](quality-markdown.md) | Prüft Markdown-Syntax, Struktur und Links |
| [Quality YAML](quality-yaml.md) | Prüft YAML-Dateien auf Syntax und Struktur |
| [Release GitHub](release-github.md) | Erstellt GitHub Releases für bestehende Git Tags |
| [Release Validate Tags](release-validate-tags.md) | Prüft Tag-Format und Monotonie |
| [Release Validate Branch](release-validate-branch.md) | Prüft, ob Tag auf dem Release-Branch liegt |
| [Security CodeQL](security-codeql.md) | Führt statische Sicherheitsanalysen durch |
| [Security Dependency Review](security-dependency-review.md) | Prüft neue Dependencies in Pull Requests |
| [Security Secret Scan](security-secret-scan.md) | Verhindert das versehentliche Committen von Secrets |
| [Maintenance Link Check](maintenance-link-check.md) | Geplante Linkprüfung (repository-intern) |

---

# Verwendung

Workflows werden direkt aus dem Repository eingebunden:

```yaml
jobs:
  example:
    uses: claustrarius/github-workflows/.github/workflows/<workflow>.yml@v1
```

Beispiel:

```yaml
jobs:
  link-check:
    uses: claustrarius/github-workflows/.github/workflows/quality-link-check.yml@v1
```

---

# Versionierung

Produktive Projekte sollten immer eine stabile Version verwenden:

```yaml
@v1
```

Nicht:

```yaml
@main
```

---

# Neue Workflows

Beim Hinzufügen eines neuen Workflows muss erstellt werden:

```
.github/workflows/<workflow>.yml
docs/workflows/<workflow>.md
```

Die Dokumentation ist Bestandteil des Workflows.
