# Quality YAML

Datei:

```
.github/workflows/quality-yaml.yml
.github/actions/quality-yaml/action.yml
```

---

## Zweck

Der **Quality YAML Workflow** prüft YAML-Dateien auf Syntax und Struktur.

Er ist besonders sinnvoll für Docker-, CI- und Kubernetes-Umgebungen und nutzt **yamllint** als Prüfwerkzeug.

---

## Prüft

- GitHub Actions YAML
- Docker Compose
- Kubernetes YAML
- weitere YAML-Dateien im Repository

---

## Funktionen

Der Workflow:

- validiert YAML-Syntax mit yamllint
- unterstützt Scan-Profile für typische Anwendungsfälle
- erlaubt eigene yamllint-Konfigurationen
- schließt Standardverzeichnisse wie `node_modules` und `.git` aus

---

## Inputs

| Name | Typ | Erforderlich | Standard | Beschreibung |
|---|---|---|---|---|
| `working-directory` | string | nein | `.` | Verzeichnis für YAML-Prüfungen. |
| `yaml-glob` | string | nein | `''` | Eigener Glob für YAML-Dateien. |
| `yamllint-config` | string | nein | `''` | Pfad zur yamllint-Konfiguration. |
| `scan-profile` | string | nein | `all` | `all`, `workflows`, `compose` oder `kubernetes`. |
| `exclude-paths` | string | nein | `.git,node_modules,vendor,.venv` | Ausgeschlossene Verzeichnisse. |
| `fail-on-findings` | boolean | nein | `true` | Workflow schlägt bei yamllint-Funden fehl. |

---

## Scan-Profile

| Profil | Ziel |
|---|---|
| `all` | Alle YAML-Dateien im Repository |
| `workflows` | GitHub Actions unter `.github/workflows/` |
| `compose` | `docker-compose*` und `compose*` Dateien |
| `kubernetes` | YAML-Dateien unter `k8s/` und `kubernetes/` |

---

## Voraussetzungen

Das Ziel-Repository benötigt:

```yaml
permissions:
  contents: read
```

Optional im Repository:

- `.yamllint`, `.yamllint.yaml` oder `.yamllint.yml`
- eigene yamllint-Regeln für projektspezifische Anforderungen

---

## Integration

### Standard für alle YAML-Dateien

```yaml
name: Quality YAML

on:
  pull_request:
  push:
    branches:
      - main

permissions:
  contents: read

jobs:
  yaml:
    uses: clavicarius/github-workflows/.github/workflows/quality-yaml.yml@v1
```

### Nur GitHub Actions Workflows

```yaml
jobs:
  yaml:
    uses: clavicarius/github-workflows/.github/workflows/quality-yaml.yml@v1
    with:
      scan-profile: workflows
```

### Docker Compose prüfen

```yaml
jobs:
  yaml:
    uses: clavicarius/github-workflows/.github/workflows/quality-yaml.yml@v1
    with:
      scan-profile: compose
```

### Kubernetes Manifeste prüfen

```yaml
jobs:
  yaml:
    uses: clavicarius/github-workflows/.github/workflows/quality-yaml.yml@v1
    with:
      scan-profile: kubernetes
      working-directory: deploy
```

---

## Benötigte Berechtigungen

| Permission | Zweck |
|---|---|
| `contents: read` | Repository auschecken und YAML-Dateien lesen |

---

## Verhalten bei Fehlern

Der Workflow schlägt fehl, wenn:

- yamllint Syntax- oder Strukturfehler findet
- `fail-on-findings: true` gesetzt ist

Der Workflow endet erfolgreich ohne Prüfung, wenn:

- keine passenden YAML-Dateien gefunden werden

---

## Benötigte Komponenten

Verwendete Actions und Tools:

- `actions/checkout`
- `yamllint`

---

## Versionierung

Aktuelle Version:

```
v1
```

Verwendung:

```yaml
uses: clavicarius/github-workflows/.github/workflows/quality-yaml.yml@v1
```

---

## Änderungen

Breaking Changes werden über neue Major-Versionen veröffentlicht:

```
v1 → v2
```
