# Quality Lint

Datei:

```
.github/workflows/quality-lint.yml
.github/actions/quality-lint/action.yml
```

---

## Zweck

Der **Quality Lint Workflow** führt einheitliche Codequalitätsprüfungen für unterschiedliche Technologien aus.

Er erkennt automatisch passende Linter anhand von Projektdateien oder kann gezielt über Inputs aktiviert werden.

---

## Unterstützte Bereiche

| Bereich | Werkzeuge |
|---|---|
| PHP | PHP_CodeSniffer, PHPStan |
| JavaScript/TypeScript | ESLint, Prettier |
| Python | Ruff, flake8, pylint |
| YAML | yamllint |
| Markdown | markdownlint |

---

## Funktionen

Der Workflow:

- erkennt Formatierungsfehler
- prüft Coding Standards
- verhindert Qualitätsverlust durch frühe Fehlererkennung
- unterstützt Auto-Detection und manuelle Aktivierung einzelner Bereiche
- läuft im Kontext des aufrufenden Repositorys

---

## Inputs

| Name | Typ | Erforderlich | Standard | Beschreibung |
|---|---|---|---|---|
| `auto-detect` | boolean | nein | `true` | Erkennt Linter anhand von Projektdateien. |
| `php` | boolean | nein | `false` | Erzwingt PHP-Linting. |
| `javascript` | boolean | nein | `false` | Erzwingt JavaScript/TypeScript-Linting. |
| `python` | boolean | nein | `false` | Erzwingt Python-Linting. |
| `yaml` | boolean | nein | `false` | Erzwingt YAML-Linting. |
| `markdown` | boolean | nein | `false` | Erzwingt Markdown-Linting. |
| `skip-yaml` | boolean | nein | `false` | Deaktiviert YAML-Linting trotz Auto-Detection. |
| `skip-markdown` | boolean | nein | `false` | Deaktiviert Markdown-Linting trotz Auto-Detection. |
| `working-directory` | string | nein | `.` | Verzeichnis für die Lint-Ausführung. |
| `php-version` | string | nein | `8.3` | PHP-Version für PHP-Linter. |
| `node-version` | string | nein | `20` | Node.js-Version für JavaScript-Linter. |
| `python-version` | string | nein | `3.12` | Python-Version für Python-Linter. |

---

## Auto-Detection

Bei `auto-detect: true` werden Linter anhand typischer Konfigurationsdateien aktiviert:

| Linter | Erkennung |
|---|---|
| PHP_CodeSniffer | `phpcs.xml`, `phpcs.xml.dist`, Composer-Abhängigkeit |
| PHPStan | `phpstan.neon*`, Composer-Abhängigkeit |
| ESLint | `.eslintrc*`, `eslint.config.*`, `package.json` |
| Prettier | `.prettierrc*`, `prettier.config.*`, `package.json` |
| Ruff | `ruff.toml`, `pyproject.toml`, Python-Dateien |
| flake8 | `.flake8`, `setup.cfg`, `requirements.txt` |
| pylint | `.pylintrc`, `pyproject.toml`, `requirements.txt` |
| yamllint | `.yamllint*`, YAML-Dateien im Repository |
| markdownlint | `.markdownlint*`, Markdown-Dateien im Repository |

---

## Voraussetzungen

Das Ziel-Repository benötigt:

```yaml
permissions:
  contents: read
```

Je nach aktiviertem Linter sind zusätzlich Projektabhängigkeiten oder Konfigurationsdateien erforderlich, zum Beispiel:

- PHP: `composer.json` mit `squizlabs/php_codesniffer` und/oder `phpstan/phpstan`
- JavaScript: `package.json` mit `eslint` und/oder `prettier`
- Python: `pyproject.toml`, `requirements.txt` oder Python-Quelldateien
- YAML: `.yamllint` oder YAML-Dateien
- Markdown: `.markdownlint*` oder Markdown-Dateien

---

## Integration

### Standard mit Auto-Detection

```yaml
name: Quality Lint

on:
  pull_request:
  push:
    branches:
      - main

permissions:
  contents: read

jobs:
  lint:
    uses: clavicarius/github-workflows/.github/workflows/quality-lint.yml@v1
```

### Gezielte Aktivierung

```yaml
jobs:
  lint:
    uses: clavicarius/github-workflows/.github/workflows/quality-lint.yml@v1
    with:
      auto-detect: false
      php: true
      javascript: true
```

### Unterverzeichnis prüfen

```yaml
jobs:
  lint:
    uses: clavicarius/github-workflows/.github/workflows/quality-lint.yml@v1
    with:
      working-directory: apps/frontend
      javascript: true
```

---

## Benötigte Berechtigungen

| Permission | Zweck |
|---|---|
| `contents: read` | Repository auschecken und Dateien lesen |

---

## Verhalten bei Fehlern

Der Workflow schlägt fehl, wenn:

- ein aktivierter Linter Verstöße findet
- ein erzwungener Linter nicht installiert oder konfiguriert ist
- Abhängigkeiten nicht installiert werden können

Wenn kein Linter erkannt oder aktiviert wird, endet der Workflow erfolgreich ohne Prüfungen.

---

## Benötigte Komponenten

Verwendete Actions und Tools:

- `actions/checkout`
- `shivammathur/setup-php`
- `actions/setup-node`
- `actions/setup-python`
- `astral-sh/ruff-action`
- `DavidAnson/markdownlint-cli2-action`
- PHP_CodeSniffer, PHPStan, ESLint, Prettier, flake8, pylint, yamllint

---

## Versionierung

Aktuelle Version:

```
v1
```

Verwendung:

```yaml
uses: clavicarius/github-workflows/.github/workflows/quality-lint.yml@v1
```

---

## Änderungen

Breaking Changes werden über neue Major-Versionen veröffentlicht:

```
v1 → v2
```
