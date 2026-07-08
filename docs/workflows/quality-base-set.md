# Quality Base Set

Datei:

```
.github/workflows/quality-base-set.yml
```

---

## Zweck

Der **Quality Base Set Workflow** ist der interne CI-Gate für dieses Repository.

Er führt vor einem Merge nach `main` die vereinheitlichten Qualitäts- und Sicherheitsprüfungen aus und nutzt dafür die wiederverwendbaren Workflows aus diesem Repository.

Zusätzlich wird bei Git Tags ein GitHub Release über `release-github.yml` erstellt.

---

## Enthaltene Workflows

| Workflow | Trigger | Zweck |
|---|---|---|
| `quality-link-check.yml` | Pull Request | Linkprüfung mit Issue-Report |
| `quality-yaml.yml` | Pull Request | YAML-Syntax und Struktur |
| `quality-markdown.yml` | Pull Request | Markdown-Syntax und Struktur |
| `security-secret-scan.yml` | Pull Request | Secret- und Leak-Prüfung |
| `security-dependency-review.yml` | Pull Request | Dependency-Sicherheit im PR |
| `quality-lint.yml` | Pull Request | Zusätzliche Linter nach Auto-Detect |
| `release-github.yml` | Tag `v*` | GitHub Release für neue Versionen |

---

## Trigger

### Pull Request nach `main`

Alle Qualitäts- und Sicherheitsjobs laufen parallel als Required Checks.

### Tag Push `v*`

Beispiel:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Dadurch wird automatisch ein GitHub Release erstellt.

---

## Konfiguration im Base Set

### YAML-Prüfung

Für dieses Repository wird der Scan auf GitHub Actions Workflows fokussiert:

```yaml
scan-profile: workflows
```

### Markdown-Prüfung

Linkprüfung ist in `quality-markdown` deaktiviert, weil `quality-link-check` diese Aufgabe übernimmt:

```yaml
enable-link-check: false
```

### Linting

`quality-lint` nutzt Auto-Detect für vorhandene Toolchains, prüft aber keine YAML- oder Markdown-Dateien erneut:

```yaml
auto-detect: true
yaml: false
markdown: false
```

---

## Benötigte Berechtigungen

```yaml
permissions:
  contents: read
  issues: write
  pull-requests: write
  security-events: read
```

Für Release-Jobs:

```yaml
permissions:
  contents: write
```

---

## Ablauf bei Pull Requests

```
Pull Request -> main
      |
      +-- quality-link-check
      +-- quality-yaml
      +-- quality-markdown
      +-- security-secret-scan
      +-- security-dependency-review
      +-- quality-lint
      |
      v
Alle Checks grün -> Merge erlaubt
```

---

## Ablauf bei Releases

```
git tag v1.0.0
      |
      v
release-github
      |
      v
GitHub Release erstellt
```

---

## Verhalten bei Fehlern

Der Pull Request wird blockiert, wenn mindestens einer der Jobs fehlschlägt:

- defekte Links
- ungültiges YAML
- Markdown-Probleme
- erkannte Secrets
- unsichere Dependencies
- Lint-Fehler

---

## Hinweis

Dieser Workflow ist **repository-intern** und dient als Referenzimplementierung für das Basis-Set v1.

Externe Projekte binden die einzelnen Workflows direkt ein:

```yaml
jobs:
  link-check:
    uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@v1
```

---

## Weiterführende Dokumentation

- [Quality Link Check](quality-link-check.md)
- [Quality YAML](quality-yaml.md)
- [Quality Markdown](quality-markdown.md)
- [Quality Lint](quality-lint.md)
- [Security Secret Scan](security-secret-scan.md)
- [Security Dependency Review](security-dependency-review.md)
- [Release GitHub](release-github.md)
