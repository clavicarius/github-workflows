# GitHub Release

Datei:

```
.github/workflows/release-github.yml
```

---

## Zweck

Der **GitHub Release Workflow** erstellt ein GitHub Release für einen bestehenden Git Tag.

Er ist als wiederverwendbarer Workflow konzipiert und kann am Ende einer Release-Pipeline
aus anderen Repositorys eingebunden werden.

---

## Funktionen

Der Workflow:

- erstellt ein GitHub Release für einen vorhandenen Tag
- generiert Release Notes automatisch aus Commits und Pull Requests
- erlaubt eigene Release Notes
- kann Artefakte aus dem aufrufenden Workflow anhängen
- unterstützt Draft- und Prerelease-Releases
- stellt Release-Metadaten als Outputs bereit

---

## Typischer Ablauf

```
git tag v1.2.0
       |
       v
     Build
       |
       v
      Test
       |
       v
    Release
```

Build und Tests bleiben Aufgabe des aufrufenden Workflows. Dieser Workflow übernimmt nur die Release-Erstellung.

---

## Inputs

| Name | Typ | Erforderlich | Standard | Beschreibung |
|---|---|---|---|---|
| `tag` | string | ja | - | Git Tag, für den ein Release erstellt wird. Der Tag muss bereits existieren. |
| `release_name` | string | nein | Wert von `tag` | Name des Releases. |
| `draft` | boolean | nein | `false` | Erstellt das Release als Draft. |
| `prerelease` | boolean | nein | `false` | Markiert das Release als Prerelease. |
| `generate_release_notes` | boolean | nein | `true` | Generiert Release Notes automatisch. |
| `body` | string | nein | `''` | Eigene Release Notes. Wenn gesetzt, werden automatisch generierte Notes deaktiviert. |
| `artifact_name` | string | nein | `''` | Name eines einzelnen Artefakts, das an das Release angehängt wird. |
| `artifact_pattern` | string | nein | `''` | Pattern für mehrere Artefakte, die an das Release angehängt werden. |

---

## Outputs

| Name | Beschreibung |
|---|---|
| `release_url` | URL des erstellten Releases. |
| `release_id` | ID des erstellten Releases. |
| `upload_url` | Upload-URL des erstellten Releases. |

---

## Integration

Einbindung bei Tag Push:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  release:
    uses: clavicarius/github-workflows/.github/workflows/release-github.yml@v1
    with:
      tag: ${{ github.ref_name }}
```

---

## Artefakt anhängen

Ein einzelnes Artefakt aus einem vorherigen Job anhängen:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build artifact
        run: |
          mkdir -p dist
          echo "release artifact" > dist/release.txt

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: release-asset
          path: dist/release.txt

  release:
    needs: build
    uses: clavicarius/github-workflows/.github/workflows/release-github.yml@v1
    with:
      tag: ${{ github.ref_name }}
      artifact_name: release-asset
```

Mehrere Artefakte über ein Pattern anhängen:

```yaml
jobs:
  release:
    uses: clavicarius/github-workflows/.github/workflows/release-github.yml@v1
    with:
      tag: ${{ github.ref_name }}
      artifact_pattern: 'release-asset-*'
```

---

## Benötigte Berechtigungen

Das aufrufende Repository muss Schreibzugriff auf Repository-Inhalte erlauben:

```yaml
permissions:
  contents: write
```

Bedeutung:

| Permission | Zweck |
|---|---|
| `contents: write` | Erstellen des GitHub Releases und Hochladen von Assets |

---

## Voraussetzungen

Das Zielrepository benötigt:

- einen bereits vorhandenen Git Tag
- aktivierte GitHub Actions
- passende Repository-Berechtigungen für Releases
- optional vorher hochgeladene Artefakte mit `actions/upload-artifact@v4`

---

## Verhalten bei Fehlern

Der Workflow bricht ab, wenn:

- der angegebene Tag nicht existiert
- das Release bereits existiert
- die Berechtigung `contents: write` fehlt
- angeforderte Artefakte nicht gefunden werden

---

## Versionierung

Aktuelle Version:

```
v1
```

Verwendung:

```yaml
uses: clavicarius/github-workflows/.github/workflows/release-github.yml@v1
```

---

## Weiterführende Informationen

- [Release- und Tagging-Richtlinie](../RELEASING.md)
- [Release Validate Tags](release-validate-tags.md)
- [Release Validate Branch](release-validate-branch.md)
- [Quality Base Set](quality-base-set.md)

Offizielle Dokumentation:

- GitHub Releases: https://docs.github.com/en/repositories/releasing-projects-on-github
- GitHub CLI `gh release create`: https://cli.github.com/manual/gh_release_create
