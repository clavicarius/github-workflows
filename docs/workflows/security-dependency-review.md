# Security Dependency Review

Datei:

```
.github/workflows/security-dependency-review.yml
```

---

## Zweck

Der **Security Dependency Review Workflow** prüft neue oder geänderte Dependencies in Pull Requests auf bekannte Sicherheitsprobleme.

Er dient als PR-Gate, damit unsichere Abhängigkeiten vor dem Merge erkannt werden.

---

## Erkennt

- bekannte CVEs
- unsichere Paketversionen
- problematische Abhängigkeiten
- Lizenzverstöße (optional konfigurierbar)

---

## Besonders wichtig für

- Composer (PHP)
- npm (JavaScript/TypeScript)
- NuGet (.NET)
- pip (Python)

---

## Funktionen

Der Workflow:

- analysiert Dependency-Änderungen im Pull Request
- nutzt `actions/dependency-review-action@v4`
- kann bei konfigurierter Schwere fehlschlagen
- kann optional eine Zusammenfassung als PR-Kommentar hinterlassen

---

## Inputs

| Name | Typ | Erforderlich | Standard | Beschreibung |
|---|---|---|---|---|
| `fail-on-severity` | string | nein | `moderate` | Minimale Schwere für einen Fehler (`low`, `moderate`, `high`, `critical`). |
| `fail-on-scopes` | string | nein | `''` | Scopes, die fehlschlagen sollen (z. B. `runtime,development`). |
| `deny-licenses` | string | nein | `''` | Verbotene SPDX-Lizenzen. |
| `allow-licenses` | string | nein | `''` | Explizit erlaubte SPDX-Lizenzen. |
| `config-file` | string | nein | `''` | Pfad zu einer externen Dependency-Review-Konfiguration. |
| `external-repo-token` | string | nein | `''` | Token für externe Konfigurationsdateien. |
| `comment-summary-in-pr` | boolean | nein | `true` | Schreibt eine Zusammenfassung in den Pull Request. |
| `retry-on-snapshot-warnings` | boolean | nein | `false` | Wiederholt die Prüfung bei Snapshot-Warnungen. |

---

## Voraussetzungen

Das Ziel-Repository benötigt:

```yaml
permissions:
  contents: read
```

Zusätzlich:

- Der aufrufende Workflow muss auf `pull_request` laufen
- Dependency Graph sollte für das Repository aktiviert sein
- für private Repositories ggf. GitHub Advanced Security

---

## Integration

### Standard PR-Gate

```yaml
name: Security Dependency Review

on:
  pull_request:

permissions:
  contents: read

jobs:
  dependency-review:
    uses: clavicarius/github-workflows/.github/workflows/security-dependency-review.yml@v1
```

### Strengere Schwere

```yaml
jobs:
  dependency-review:
    uses: clavicarius/github-workflows/.github/workflows/security-dependency-review.yml@v1
    with:
      fail-on-severity: high
```

### Lizenzprüfung

```yaml
jobs:
  dependency-review:
    uses: clavicarius/github-workflows/.github/workflows/security-dependency-review.yml@v1
    with:
      fail-on-severity: moderate
      deny-licenses: GPL-3.0, AGPL-3.0
```

### Externe Konfigurationsdatei

```yaml
jobs:
  dependency-review:
    uses: clavicarius/github-workflows/.github/workflows/security-dependency-review.yml@v1
    with:
      config-file: ./.github/dependency-review-config.yml
```

---

## Typischer Ablauf

```
Pull Request
     |
     v
Dependency Review
     |
     +-- OK -> Merge erlaubt
     |
     +-- CVE/Lizenzproblem -> Block
```

---

## Benötigte Berechtigungen

| Permission | Zweck |
|---|---|
| `contents: read` | Repository und Dependency-Änderungen lesen |

---

## Verhalten bei Fehlern

Der Workflow schlägt fehl, wenn:

- neue oder geänderte Dependencies bekannte Schwachstellen enthalten
- die konfigurierte `fail-on-severity` erreicht oder überschritten wird
- verbotene Lizenzen erkannt werden
- konfigurierte Scope-Regeln verletzt werden

Der Workflow ist nicht sinnvoll einsetzbar, wenn:

- er außerhalb eines `pull_request`-Events aufgerufen wird

---

## Benötigte Komponenten

Verwendete Actions:

- `actions/checkout`
- `actions/dependency-review-action@v4`

---

## Versionierung

Aktuelle Version:

```
v1
```

Verwendung:

```yaml
uses: clavicarius/github-workflows/.github/workflows/security-dependency-review.yml@v1
```

---

## Änderungen

Breaking Changes werden über neue Major-Versionen veröffentlicht:

```
v1 → v2
```
