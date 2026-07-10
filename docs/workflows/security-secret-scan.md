# Security Secret Scan

Datei:

```
.github/workflows/security-secret-scan.yml
.github/actions/security-secret-scan/action.yml
```

---

## Zweck

Der **Security Secret Scan Workflow** verhindert das versehentliche Committen von Secrets.

Er kombiniert:

- **Gitleaks** für proaktive Secret-Erkennung in Commits und Pull Requests
- **GitHub Secret Scanning** zur Prüfung offener Plattform-Alerts

---

## Erkennt

- API Keys
- Tokens
- Passwörter
- Private Keys
- weitere bekannte Secret-Muster

---

## Typischer Ablauf

```
Commit
   |
   v
Secret Scan
   |
   +-- OK -> Merge erlaubt
   |
   +-- Secret gefunden -> Block
```

---

## Inputs

| Name | Typ | Erforderlich | Standard | Beschreibung |
|---|---|---|---|---|
| `gitleaks-config` | string | nein | `''` | Pfad zu einer eigenen Gitleaks-Konfiguration. |
| `scan-mode` | string | nein | `auto` | `auto`, `full` oder `diff`. |
| `check-github-alerts` | boolean | nein | `true` | Prüft offene GitHub Secret Scanning Alerts. |
| `enable-gitleaks-comments` | boolean | nein | `true` | Aktiviert Gitleaks-Kommentare in Pull Requests. |
| `fail-on-findings` | boolean | nein | `true` | Workflow schlägt bei Funden fehl. |

---

## Scan-Modi

| Modus | Verhalten |
|---|---|
| `auto` | Gitleaks scannt abhängig vom Event (Push, Pull Request). |
| `full` | Gitleaks scannt die gesamte Repository-Historie. |
| `diff` | Gitleaks scannt nur Änderungen (Pull Request / Diff). |

---

## Voraussetzungen

Das Ziel-Repository benötigt:

```yaml
permissions:
  contents: read
  pull-requests: read
  security-events: read
```

Optional:

- `gitleaks.toml` oder `.gitleaks.toml` im Repository-Root
- aktiviertes GitHub Secret Scanning für die Alert-Prüfung
- `GITLEAKS_LICENSE` Secret für Organisationen mit Gitleaks Action

---

## Integration

### Pull Request Gate

```yaml
name: Security Secret Scan

on:
  pull_request:
  push:
    branches:
      - main

permissions:
  contents: read
  pull-requests: read
  security-events: read

jobs:
  secret-scan:
    uses: clavicarius/ci-platform/.github/workflows/security-secret-scan.yml@v1
```

### Vollständiger Repository-Scan

```yaml
jobs:
  secret-scan:
    uses: clavicarius/ci-platform/.github/workflows/security-secret-scan.yml@v1
    with:
      scan-mode: full
```

### Nur Gitleaks ohne GitHub-Alerts

```yaml
jobs:
  secret-scan:
    uses: clavicarius/ci-platform/.github/workflows/security-secret-scan.yml@v1
    with:
      check-github-alerts: false
```

---

## Benötigte Berechtigungen

| Permission | Zweck |
|---|---|
| `contents: read` | Repository auschecken und Dateien scannen |
| `pull-requests: read` | Pull Request Kontext für Gitleaks |
| `security-events: read` | Offene GitHub Secret Scanning Alerts abfragen |

---

## Verhalten bei Fehlern

Der Workflow schlägt fehl, wenn:

- Gitleaks Secrets in Commits oder der Historie findet
- offene GitHub Secret Scanning Alerts existieren (wenn aktiviert)
- `fail-on-findings: true` gesetzt ist

Der Workflow gibt eine Warnung aus und läuft weiter, wenn:

- GitHub Secret Scanning im Repository nicht aktiviert ist
- die Berechtigung `security-events: read` fehlt

---

## Benötigte Komponenten

Verwendete Actions und Tools:

- `actions/checkout`
- `gitleaks/gitleaks-action`
- Gitleaks CLI (für `scan-mode: full`)
- GitHub CLI (`gh`) für Secret Scanning Alerts

---

## Versionierung

Aktuelle Version:

```
v1
```

Verwendung:

```yaml
uses: clavicarius/ci-platform/.github/workflows/security-secret-scan.yml@v1
```

---

## Änderungen

Breaking Changes werden über neue Major-Versionen veröffentlicht:

```
v1 → v2
```
