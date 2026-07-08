# Security CodeQL

Datei:

```
.github/workflows/security-codeql.yml
```

---

## Zweck

Der **Security CodeQL Workflow** führt automatisierte Sicherheitsanalysen des Quellcodes durch.

Er verwendet die statische Code-Analyseplattform **CodeQL** von GitHub, um potenzielle Sicherheitsprobleme und Schwachstellen im Code zu erkennen.

Der Workflow ist als wiederverwendbarer Workflow konzipiert und kann von mehreren Repositorys eingebunden werden.

---

## Funktionen

Der Workflow:

- analysiert Quellcode automatisiert
- erkennt bekannte Sicherheitsmuster
- erstellt Security Alerts bei gefundenen Problemen
- integriert Ergebnisse in GitHub Security
- unterstützt Pull-Request-Prüfungen
- kann regelmäßig automatisch ausgeführt werden
- erkennt Sprachen automatisch oder nutzt eine explizite Sprachkonfiguration

---

## Unterstützte Sprachen

CodeQL unterstützt unter anderem:

- C/C++
- C#
- Go
- Java
- JavaScript / TypeScript
- Kotlin
- Python
- Ruby
- Swift

Die tatsächlich analysierten Sprachen werden automatisch anhand des Repository-Inhalts erkannt oder können explizit über den Input `languages` konfiguriert werden.

---

## Inputs

| Name | Typ | Erforderlich | Standard | Beschreibung |
|---|---|---|---|---|
| `languages` | string | nein | `''` | JSON-Array der zu analysierenden Sprachen, z. B. `'["javascript", "python"]'. Leer = automatische Erkennung. |
| `codeql-config-path` | string | nein | `''` | Optionaler Pfad zu einer CodeQL-Konfigurationsdatei. |
| `build-command` | string | nein | `''` | Optionaler manueller Build-Befehl für kompilierte Sprachen. Überschreibt Autobuild. |

---

## Integration

Einbindung in ein Projekt:

```yaml
name: Security CodeQL

on:
  workflow_dispatch:

permissions:
  actions: read
  contents: read
  security-events: write

jobs:
  codeql:
    uses: clavicarius/github-workflows/.github/workflows/security-codeql.yml@v1
```

Explizite Sprachauswahl:

```yaml
jobs:
  codeql:
    uses: clavicarius/github-workflows/.github/workflows/security-codeql.yml@v1
    with:
      languages: '["csharp", "javascript"]'
```

Mit manuellem Build-Befehl:

```yaml
jobs:
  codeql:
    uses: clavicarius/github-workflows/.github/workflows/security-codeql.yml@v1
    with:
      languages: '["java"]'
      build-command: |
        make bootstrap
        make release
```

---

## Ausführung

Der Workflow kann auf verschiedene Arten gestartet werden:

### Manuell

Über:

```
GitHub Repository
└── Actions
    └── Security CodeQL
        └── Run workflow
```

---

### Zeitgesteuert

Empfohlen ist eine regelmäßige Prüfung:

Beispiel:

```yaml
schedule:
  - cron: "30 3 * * 1"
```

Ausführung:

```
Montag
03:30 UTC
```

---

### Pull Requests

Optional kann der Workflow bei Änderungen am Code ausgeführt werden:

```yaml
pull_request:
  branches:
    - main
```

Dadurch werden Sicherheitsprobleme bereits vor dem Merge erkannt.

---

## Benötigte Berechtigungen

Der Workflow benötigt:

```yaml
permissions:
  actions: read
  contents: read
  security-events: write
```

Bedeutung:

| Permission | Zweck |
|---|---|
| `actions: read` | Zugriff auf Workflow-Metadaten |
| `contents: read` | Lesen des Quellcodes |
| `security-events: write` | Schreiben von CodeQL-Ergebnissen |

---

## Voraussetzungen

Das Zielrepository benötigt:

- aktivierte GitHub Security Features
- aktivierte Code Scanning Funktion
- passende Repository-Berechtigungen

---

## Beispiel Ablauf

```
Repository
    |
    v
Checkout Code
    |
    v
CodeQL Initialisierung
    |
    v
Build / Analyse
    |
    v
Security Scan
    |
    v
Upload Ergebnisse
    |
    v
GitHub Security Dashboard
```

---

## Verhalten bei Fehlern

Wenn CodeQL Sicherheitsprobleme erkennt:

- werden Findings im Security Dashboard angezeigt
- können Pull Requests blockiert werden (optional)
- können Security Policies greifen

Der Workflow sollte standardmäßig nicht nur als Build-Fehler betrachtet werden, sondern als Sicherheitsbericht.

---

## Sicherheitsrichtlinien

Empfohlen:

- CodeQL regelmäßig ausführen
- Ergebnisse zeitnah bearbeiten
- Workflow nicht mit unnötigen Berechtigungen ausstatten
- Drittanbieter-Actions versioniert einbinden

---

## Versionierung

Aktuelle Version:

```
v1
```

Verwendung:

```yaml
uses: clavicarius/github-workflows/.github/workflows/security-codeql.yml@v1
```

---

## Änderungen

Breaking Changes werden über neue Major-Versionen veröffentlicht:

```
v1 → v2
```

Beispiele:

- Änderung der benötigten Permissions
- Änderung der Eingabeparameter
- Änderung des Analyseverhaltens

---

## Weiterführende Informationen

Offizielle Dokumentation:

- GitHub CodeQL: https://codeql.github.com/
- GitHub Code Scanning: https://docs.github.com/en/code-security/code-scanning
