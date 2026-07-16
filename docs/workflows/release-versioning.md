# Release Versioning

Datei:

```
.github/workflows/release-versioning.yml
```

---

## Zweck

Der **Release Versioning Workflow** berechnet automatisch das nächste semantische Versions-Tag
und erstellt es auf dem `main` Branch.

Zusätzlich wird ein Major-Alias-Tag (z.B. `v1`) auf das neueste SemVer-Tag verschoben,
damit Konsumenten dieser CI-Platform über `@v1` stets die neueste kompatible Version erhalten.

---

## Trigger

| Event | Verhalten |
|---|---|
| `push` nach `main` | Berechnet und setzt das nächste SemVer-Tag + aktualisiert Major-Alias |
| `pull_request` | Dry-run: zeigt das nächste Tag an, setzt es nicht |

---

## Tagging-Schema

Es wird ausschließlich **Semantic Versioning** verwendet:

```
v<major>.<minor>.<patch>
```

Beispiele: `v0.1.0`, `v1.2.3`

Zusätzlich wird ein **Major-Alias-Tag** gepflegt:

```
v<major>
```

Dieses Tag zeigt stets auf das neueste SemVer-Tag des jeweiligen Major-Versions-Zweigs
und wird mit `--force` aktualisiert.

---

## Ablauf

```
push -> main
      |
      v
Compute next SemVer tag (release-semver-versioning)
      |
      v
Existiert NEXT_TAG bereits? -> Ja -> Exit (idempotent)
      |
      v
git tag <NEXT_TAG>
git push origin <NEXT_TAG>
      |
      v
git tag --force v<major>
git push origin --force v<major>
```

---

## Benötigte Berechtigungen

```yaml
permissions:
  contents: write
```

---

## Schutz vor Rekursion

Der Workflow enthält einen Bot-Guard und läuft nur, wenn der Auslöser nicht
`github-actions[bot]` ist:

```yaml
github.actor != 'github-actions[bot]'
```

---

## Weiterführende Dokumentation

- [Release- und Tagging-Richtlinie](../RELEASING.md)
- [Release GitHub](release-github.md)
- [Release Validate Tags](release-validate-tags.md)
- [Release Validate Branch](release-validate-branch.md)
