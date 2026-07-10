# Release Validate Tags

Datei:

```
.github/workflows/release-validate-tags.yml
```

---

## Zweck

Der **Release Validate Tags Workflow** prüft automatisch, ob ein neu gesetztes
Git-Tag dem vorgeschriebenen Versionsformat entspricht und monoton steigend ist.

Er verhindert ungültige Releases durch fehlerhafte Tag-Namen und benachrichtigt
den PR-Autor / Trigger-Auslöser bei Verstößen über ein GitHub Issue.

---

## Funktionen

Der Workflow:

- validiert das Tag-Format gegen ein konfigurierbares Regex-Pattern
- unterstützt zwei vordefinierte Muster: **Simple** und **Semver**
- prüft bei Simple-Versionierung, ob das neue Tag größer ist als alle vorhandenen gültigen Tags
- erstellt automatisch ein GitHub Issue bei Regelverstößen
- kann als wiederverwendbarer Workflow über `workflow_call` aufgerufen werden

---

## Vordefinierte Versionierungsmuster

### Simple (Standard)

**Name:** `simple`  
**Regex:** `^v[1-9][0-9]*$`  
**Beschreibung:** Einfache Major-Versionierung ohne Dezimalpunkte.

| Beispiel | Gültig | Grund |
|---|---|---|
| `v1` | ja | Erste Version |
| `v2`, `v10`, `v123` | ja | Monoton steigend |
| `v0` | nein | Kleinste erlaubte Version ist v1 |
| `v01` | nein | Führende Nullen verboten |

Lücken sind erlaubt (z. B. `v1` → `v4` ist gültig, sofern `v4` > höchstes existierendes Tag).

### Semver

**Name:** `semver`  
**Regex:** Vollständige Semantic Versioning Spezifikation  
**Beschreibung:** Professionelle Semantic Versioning nach [semver.org](https://semver.org/).

| Beispiel | Gültig | Grund |
|---|---|---|
| `v1.0.0` | ja | Standard semver |
| `v1.2.3` | ja | Standard semver |
| `v2.0.0-rc.1` | ja | Prerelease |
| `v1.0.0+build.1` | ja | Build-Metadaten |
| `v1.0` | nein | Patch-Version erforderlich |
| `v1` | nein | Minor und Patch erforderlich |

### Custom Pattern

Sie können jedes gültige Regex-Pattern übergeben, z. B.:

- `^v[0-9]+\.[0-9]+$` für Major.Minor-only
- `^release-\d{4}-\d{2}$` für Datum-basierte Tags

---

## Inputs

| Name | Typ | Erforderlich | Standard | Beschreibung |
|---|---|---|---|---|
| `tag` | string | nein | `''` | Tag zum Validieren. Leer = aus `github.ref` abgeleitet (bei Push). |
| `version-pattern` | string | nein | `'simple'` | Versionierungsmuster: `simple`, `semver`, oder custom Regex. |

---

## Benötigte Berechtigungen

```yaml
permissions:
  contents: read
  issues: write
```

---

## Integration

### Automatisch bei Tag-Push

Der Workflow läuft automatisch bei jedem `v*`-Tag-Push mit dem Standard-Muster (Simple):

```
git tag v2
git push origin v2
  |
  v
release-validate-tags läuft (mit version-pattern=simple)
  |
  +-- OK  --> weiter
  +-- Fehler --> Issue wird erstellt, Workflow schlägt fehl
```

### Als wiederverwendbarer Workflow mit Custom Pattern

```yaml
jobs:
  validate-tag:
    uses: clavicarius/github-workflows/.github/workflows/release-validate-tags.yml@v1
    with:
      tag: ${{ github.ref_name }}
      version-pattern: 'semver'
```

oder mit Custom Regex:

```yaml
jobs:
  validate-tag:
    uses: clavicarius/github-workflows/.github/workflows/release-validate-tags.yml@v1
    with:
      tag: ${{ github.ref_name }}
      version-pattern: '^v[0-9]+\.[0-9]+$'
```

---

## Verhalten bei Fehlern

Wenn das Tag ungültig ist:

- schlägt der Workflow-Job mit einem `::error::`-Annotation fehl
- wird automatisch ein GitHub Issue erstellt, das **den Autor / Trigger-Auslöser** benachrichtigt
- wird kein Release erstellt (nachgelagerte Jobs mit `needs:` werden blockiert)

---

## Weiterführende Dokumentation

- [Release- und Tagging-Richtlinie](../RELEASING.md)
- [Semantic Versioning](https://semver.org/)
- [Quality Base Set](quality-base-set.md)

---

## Versionierung

```
v1
```

```yaml
uses: clavicarius/github-workflows/.github/workflows/release-validate-tags.yml@v1
```
