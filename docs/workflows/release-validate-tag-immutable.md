# Release Validate Tag Immutable

Datei:

```
.github/workflows/release-validate-tag-immutable.yml
.github/actions/release-validate-tag-immutable/action.yml
scripts/validate-tag-immutable.sh
```

---

## Zweck

Der **Release Validate Tag Immutable Workflow** lehnt Tag-Updates ab — also
das Verschieben oder Force-Pushen eines bereits existierenden Tag-Namens.

Er ergänzt die Monotonie-Prüfung in `release-validate-tags`: Ein erneutes
Setzen von `v5` auf einen anderen Commit wird hier abgefangen, auch wenn die
Versionsnummer formal noch „größer als das Maximum ohne aktuelles Tag" wäre.

---

## Architektur

| Komponente | Verantwortung |
|---|---|
| `release-validate-tag-immutable.yml` | Trigger, Permissions, Job-Orchestrierung |
| `release-validate-tag-immutable/action.yml` | Composite Action mit Inputs und Outputs |
| `scripts/validate-tag-immutable.sh` | Prüflogik und Issue-Reporting |

---

## Funktionen

Der Workflow:

- erkennt Tag-Updates über `github.event.created` und `github.event.before`
- schlägt fehl, wenn ein Tag-Name bereits existierte und aktualisiert wurde
- erstellt oder aktualisiert ein GitHub Issue bei Verstößen
- benötigt keinen Git-Fetch (reine Push-Event-Metadaten)
- kann als wiederverwendbarer Workflow über `workflow_call` aufgerufen werden

---

## Inputs

| Input | Typ | Standard | Beschreibung |
|---|---|---|---|
| `tag` | string | aus `github.ref` | Zu prüfendes Tag |
| `tag-created` | boolean | `true` | `false` = Tag wurde aktualisiert |
| `tag-before` | string | `''` | Vorheriger Commit-SHA des Refs |
| `create-issue-on-failure` | boolean | `true` | Issue bei Fehler erstellen |
| `issue-label` | string | `invalid-tag` | Label für Issue-Reports |
| `issue-title` | string | `Immutable version tag report` | Issue-Titel |
| `notify-user` | string | `github.actor` | User für Issue-Mention |

---

## Outputs

| Output | Beschreibung |
|---|---|
| `valid` | `true`, wenn das Tag neu erstellt wurde |

---

## Integration

### Quality Base Set

Im Quality Base Set läuft der Workflow **vor** allen anderen Release-Prüfungen:

```
release-validate-tag-immutable
  → release-validate-tags
    → release-validate-branch
      → release-github
```

Beispiel-Aufruf im Base Set:

```yaml
release-validate-tag-immutable:
  uses: ./.github/workflows/release-validate-tag-immutable.yml
  with:
    tag: ${{ github.ref_name }}
    tag-created: ${{ github.event.created }}
    tag-before: ${{ github.event.before }}
    notify-user: ${{ github.actor }}
```

### Direkter Aufruf

```yaml
jobs:
  validate-immutable:
    uses: clavicarius/github-workflows/.github/workflows/release-validate-tag-immutable.yml@v1
    with:
      tag: ${{ github.ref_name }}
      tag-created: ${{ github.event.created }}
      tag-before: ${{ github.event.before }}
```

Ohne Push-Event-Metadaten (`tag-created` und `tag-before` leer) wird die
Prüfung übersprungen (für manuelle `workflow_call`-Tests).

---

## Fehlerverhalten

Bei einem Tag-Update schlägt der Job fehl. Nachfolgende Release-Jobs werden
nicht ausgeführt. Optional wird ein Issue mit Hinweis erstellt.

---

## Tag Protection (zusätzliche Absicherung)

Die CI-Prüfung erkennt Tag-Updates beim Push. Für vollständigen Schutz vor
lokalem Force-Push sollten zusätzlich **Tag Protection Rules** in den
Repository-Einstellungen aktiviert werden (siehe [RELEASING.md](../RELEASING.md)).

---

## Siehe auch

- [RELEASING.md](../RELEASING.md)
- [Quality Base Set](quality-base-set.md)
- [Release Validate Tags](release-validate-tags.md)
- [Release Validate Branch](release-validate-branch.md)
- [Release GitHub](release-github.md)
