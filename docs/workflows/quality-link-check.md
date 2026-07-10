# Quality Link Check

Datei:

```
.github/workflows/quality-link-check.yml
.github/actions/quality-link-check/action.yml
```

---

## Zweck

Dieser Workflow überprüft automatisch externe und interne Links eines Repositorys.

Er wird eingesetzt, um defekte Links in:

- Markdown-Dokumentationen
- README-Dateien
- Projektinformationen

frühzeitig zu erkennen.

---

## Funktionen

Der Workflow:

- prüft URLs mit Lychee
- erstellt bei Fehlern einen GitHub Issue Report
- aktualisiert vorhandene Reports
- vermeidet doppelte Issues
- schließt behobene Reports automatisch

---

## Voraussetzungen

Das Ziel-Repository benötigt:

```yaml
permissions:
  contents: read
  issues: write
```

Außerdem müssen GitHub Issues aktiviert sein.

---

## Integration

Beispiel:

```yaml
name: Link Check

on:
  workflow_dispatch:
  schedule:
    - cron: "11 11 * * 0"

permissions:
  contents: read
  issues: write

jobs:

  link-check:
    uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@v1
```

---

## Ausführung

Der Workflow läuft:

- manuell über `workflow_dispatch`
- automatisch gemäß Zeitplan

Standard:

```
Sonntag 11:11 UTC
```

---

## Fehlerbehandlung

Wenn defekte Links gefunden werden:

1. Lychee erzeugt einen Report.
2. Ein Issue mit dem Titel:

```
Link Checker Report
```

wird erstellt oder aktualisiert.

Label:

```
dead-link
```

---

Wenn alle Links wieder funktionieren:

- das bestehende Issue wird automatisch geschlossen.

---

## Benötigte Komponenten

Verwendete Actions:

- `actions/checkout`
- `lycheeverse/lychee-action`
- GitHub CLI (`gh`)

---

## Beispielausgabe

Ein Fehler erzeugt ein Issue:

```
Link Checker Report

Broken links:

- https://example.invalid
- https://old-documentation.example
```

---

## Versionierung

Aktuelle Version:

```
v1
```

Verwendung:

```yaml
uses: clavicarius/github-workflows/.github/workflows/quality-link-check.yml@v1
```

---

## Änderungen

Breaking Changes werden über neue Major-Versionen veröffentlicht:

```
v1 → v2
```
