# Release- und Tagging-Richtlinie

## Zweck

Dieses Dokument legt die Konvention für Versions-Tags im Repository fest und
beschreibt den Prozess zum Erstellen gültiger Tags sowie die automatische
Prüfung per GitHub Action.

## Regeln (Standard: Simple Major Versioning)

### Standard-Muster (Simple)

Standardmäßig gilt folgendes Versionierungsschema:

- Format: `vNNN` (Regex: `^v[1-9][0-9]*$`)
  - Keine führenden Nullen (z. B. `v01` ist ungültig).
  - Erste zulässige Version ist `v1` (`v0` ist nicht erlaubt).
- Monoton steigend: Neue Tags müssen numerisch größer sein als die aktuell
  größte existierende Version. Lücken sind erlaubt (z. B. `v1` → `v4` ist
  zulässig, solange `v4` > höchstes existierendes Tag).
- Bereits veröffentlichte Tags dürfen nicht verändert (forciert neu gesetzt)
  werden. Das Neusetzen bereits verwendeter Tag-Namen wird abgelehnt.

### Alternative: Semantic Versioning

Repositories können auf **Semantic Versioning** (semver) wechseln, z. B. `v1.2.3-rc.1+build`.
Dies wird durch den Parameter `version-pattern: 'semver'` im Workflow konfiguriert.

Weitere Informationen: [semver.org](https://semver.org/)

### Custom Patterns

Für spezialisierte Anforderungen können eigene Regex-Muster verwendet werden.

---

## Verantwortung

- Repository-Maintainer(s) sind verantwortlich für die Freigabe neuer Tags.
- Bei Verstößen gegen die Tagging-Richtlinie wird **der PR-Autor / Trigger-Auslöser** automatisch über ein GitHub Issue benachrichtigt.

---

## Ort der Dokumentation

- Diese Regel steht in `docs/RELEASING.md`.
- Workflow-Dokumentation: `docs/workflows/release-validate-tags.md`

---

## Wie man ein gültiges Tag setzt (Kurz-Anleitung)

### Mit Simple Versioning (Standard)

1. Lokales Commit erstellen und pushen.
2. Lokales Tag erstellen: `git tag vN` (z. B. `git tag v5`) — wähle N so,
   dass N > höchste existierende `vNNN`.
3. Tag pushen: `git push origin v5`
4. Wenn ein Release erstellt wird, wähle dasselbe Tag (`v5`).
5. Die GitHub Action prüft das Tag automatisch; bei Fehlern schlägt der
   Release-/Tag-Workflow fehl und der Autor wird benachrichtigt.

### Mit Semantic Versioning

1. Lokales Commit erstellen und pushen.
2. Lokales Tag erstellen: `git tag v1.2.3` oder mit Prerelease: `git tag v2.0.0-rc.1`
3. Tag pushen: `git push origin v1.2.3`
4. Die GitHub Action prüft das Tag automatisch gegen das semver-Muster.

---

## Beispiele

### Simple Major Versioning

- Gültig: `v1`, `v2`, `v10`, `v123`
- Ungültig: `v0`, `v01`, `v001`, `v1.0`, `version1`, `v1a`

### Semantic Versioning

- Gültig: `v1.0.0`, `v2.1.3-alpha`, `v1.0.0+build.1`
- Ungültig: `v1.0`, `v1`, `v1.0.0-`, `version1.0.0`

---

## Automatisierte Prüfung (Kurz)

- Eine GitHub Action (`.github/workflows/release-validate-tags.yml`) prüft
  Tag-Pushes und Release-Publishes.
- Sie validiert Format, Monotonität (bei Simple) und andere Aspekte.
- Bei Verstößen schlägt der Workflow fehl und ein Issue wird **dem Autor** erstellt.
- Das verwendete Versionierungsmuster ist konfigurierbar (siehe `version-pattern`-Input).

---

## Migration vorhandener Tags

- Bestehende nicht-konforme Tags werden nicht automatisch umbenannt oder
  gelöscht. Eine separate Migration kann bei Bedarf geplant werden.

---

## Tests

- Testfälle (lokal/test-Repo) sollten u. a. enthalten (für Simple):
  - `v1`, `v2`, `v10`
  - `v01` (ungültig), `v0` (ungültig)
  - Versuch, `v2` erneut zu setzen (abweisen)

- Testfälle (für Semver):
  - `v1.0.0`, `v1.2.3`
  - `v2.0.0-rc.1`, `v1.0.0+build`
  - `v1.0` (ungültig), `v1` (ungültig)

---

## Kontakt / Fragen

- Bei Fragen oder Problemen mit Tagging-Validierung wird automatisch ein Issue erstellt und der Autor benachrichtigt.
- Zur allgemeinen Diskussion: Issue oder Pull Request im Repository öffnen.
