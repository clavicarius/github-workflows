# Release- und Tagging-Richtlinie

## Zweck

Dieses Dokument legt die Konvention für Versions-Tags im Repository fest und
beschreibt den Prozess zum Erstellen gültiger Tags sowie die automatische
Versionierung per GitHub Action.

## Regeln (Standard: Semantic Versioning + Moving Major Alias)

### Standard-Muster (SemVer)

Standardmäßig gilt folgendes Versionierungsschema:

- **Release-Tag (immutable):** `v<major>.<minor>.<patch>`  
  Regex: `^v[0-9]+\.[0-9]+\.[0-9]+$`
- Nur diese Tags werden für die automatische Versionsberechnung berücksichtigt.
- Initialversion ist `v0.1.0`, falls noch kein passender Tag existiert.
- Neue Versionen werden automatisch aus dem höchsten vorhandenen SemVer-Tag
  berechnet (aktuell: **Patch-Increment**).

### Moving Major Alias (`vN`)

Zusätzlich wird pro Major-Linie ein beweglicher Alias gepflegt:

- Format: `v<major>` (z. B. `v0`, `v1`, `v2`)
- `vN` zeigt immer auf denselben Commit wie der neueste veröffentlichte
  `vN.x.y`-Tag.
- Beispiel: Wird `v2.4.9` veröffentlicht, zeigt `v2` anschließend auf exakt
  diesen Commit.
- Der `vN`-Alias ist **absichtlich mutable** (Force-Update durch CI), da er als
  Zeiger auf den neuesten Stand der Major-Linie dient.

### Immutabilität

- `vX.Y.Z`-Release-Tags sind **immutable** und dürfen nicht verschoben werden.
- `vN`-Alias-Tags sind **mutable by design** und werden von der CI aktualisiert.

---

## Verantwortung

- Repository-Maintainer(s) sind verantwortlich für Freigaben und Releases.
- CI automatisiert die Tag-Erzeugung und Alias-Aktualisierung.
- Bei Verstößen gegen die Richtlinie schlägt der Workflow fehl.

---

## Ort der Dokumentation

- Diese Regel steht in `docs/RELEASING.md`.
- Versioning-Verhalten (detailliert): `docs/VERSIONING.md`
- Tag-Validierung: [release-validate-tags](workflows/release-validate-tags.md)
- Tag-Immutabilität: [release-validate-tag-immutable](workflows/release-validate-tag-immutable.md)
- Branch-Validierung: [release-validate-branch](workflows/release-validate-branch.md)
- Release-Erstellung: [release-github](workflows/release-github.md)
- Orchestrierung: [quality-base-set](workflows/quality-base-set.md)

---

## Release-Prozess (Kurz-Anleitung)

### Automatisch über CI (Standard)

1. Commit nach `main` pushen.
2. Workflow berechnet den nächsten `vX.Y.Z`-Tag.
3. Workflow erstellt/pusht den neuen `vX.Y.Z`-Tag.
4. Workflow aktualisiert den zugehörigen `vN`-Alias auf denselben Commit.
5. Bei `pull_request` läuft nur Dry-Run (keine Tag-Pushes).

### Manuell (nur Ausnahmefall)

Falls manuell getaggt wird, gilt:

1. SemVer-Release-Tag setzen (z. B. `git tag v1.2.3`).
2. Tag pushen (`git push origin v1.2.3`).
3. Optional/bei Bedarf `v1` auf denselben Commit setzen (normalerweise CI).

---

## Beispiele

### Sample Release-Tags (`vX.Y.Z`)

- Gültig: `v0.1.0`, `v1.2.3`, `v10.0.7`
- Ungültig: `v1`, `v1.0`, `v01.2.3`, `version1.2.3`

### Sample Moving Major Alias (`vN`)

- Gültig: `v0`, `v1`, `v12`
- Ungültig: `v01`, `v1.0`, `v1a`

### Verhalten

- Neuer Tag: `v2.4.9`
- Danach muss `v2` auf denselben Commit zeigen wie `v2.4.9`.

---

## Automatisierte Prüfung (Kurz)

Bei Versioning-/Release-Läufen werden u. a. diese Aspekte geprüft:

1. SemVer-Format für Release-Tags (`vX.Y.Z`)
2. Branch-/Workflow-Regeln
3. Immutabilität für Release-Tags
4. Korrekte Pflege des `vN`-Major-Alias

Bei Verstößen schlägt der jeweilige Workflow fehl.

---

## Tag Protection (empfohlen)

Da `vN` absichtlich beweglich ist, sollten Tag-Regeln differenziert gesetzt
werden:

- Für **Release-Tags** (`v*.*.*`): Updates/Force-Push verhindern.
- Für **Major-Alias-Tags** (`v[0-9]+`): Update durch CI zulassen (oder
  entsprechender CI-Actor/Token erlauben).

So bleiben Release-Tags geschützt, während `vN` weiterhin korrekt auf den
neuesten Major-Stand zeigen kann.

---

## Migration vorhandener Tags

- Nicht-konforme Alt-Tags werden nicht automatisch umbenannt oder gelöscht.
- Eine Migration kann bei Bedarf separat geplant werden.
- Bei Umstellung von „Simple Major“ auf SemVer sollten bestehende Prozesse und
  Tag-Protection-Regeln auf `vX.Y.Z` + `vN`-Alias angepasst werden.

---

## Tests

Empfohlene Testfälle:

- Release-Tags:
  - `v0.1.0`, `v0.1.1`, `v1.0.0`
  - `v1`, `v1.0` (ungültig als Release-Tag)
- Alias:
  - nach `v1.2.3` zeigt `v1` auf denselben Commit
  - nach `v1.2.4` wird `v1` auf den neuen Commit weiterbewegt
- PR-Dry-Run:
  - Version wird berechnet, aber keine Tags werden gepusht.

---

## Kontakt / Fragen

- Bei Fragen oder Problemen mit Versionierung/Tagging: Issue oder Pull Request im Repository öffnen.
- Für Details zur Berechnungslogik siehe `docs/VERSIONING.md`.
