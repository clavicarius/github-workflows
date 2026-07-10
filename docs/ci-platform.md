# CI Platform Repository

Zentrales Repository für wiederverwendbare GitHub Actions, Reusable Workflows, gemeinsame CI/CD-Skripte und organisatorische Standards.

Dieses Dokument beschreibt das **Soll-Zielbild** der internen CI/CD-Plattform für alle Projekte der Organisation. Es definiert den gewünschten Endzustand — unabhängig vom aktuellen Ist-Stand.

Repository: [clavicarius/ci-platform](https://github.com/clavicarius/ci-platform/)

---

# Ziele

Die CI-Plattform verfolgt folgende Ziele:

- Standardisierung von CI/CD-Prozessen
- Wiederverwendbarkeit von Build-, Test- und Release-Logik
- Zentralisierte Wartung von Pipelines
- Konsistente Security- und Compliance-Standards
- Vereinfachung neuer Projekt-Setups
- Versionierte und stabile CI-Komponenten

---

# Architektur-Schichten

Die Plattform folgt einem geschichteten Modell:

```text
Basis-Set (quality + security)
    ↓ optional
Pipeline-Bausteine (build, test, release, docker)
    ↓
Consumer-Repositories
```

## Basis-Set

Empfohlener Einstieg für Consumer-Repositories. Enthält Quality- und Security-Workflows als gemeinsame Grundlage:

- Link- und Markdown-Prüfungen
- YAML- und Lint-Validierung
- Secret Scanning
- Dependency Review
- CodeQL

Optional als Bundle (`quality-base-set`) einbindbar.

## Pipeline-Bausteine

Optionale Erweiterungen für projektspezifische Anforderungen:

- Build (z. B. Node, Java, Docker)
- Test
- Release
- Docker Build & Publish

## Plattform-intern vs. Consumer-API

| Typ | Zweck | Einbindbar per `uses:` |
|---|---|---|
| **Consumer-Workflows** | Öffentliche API für andere Repositories | Ja (`workflow_call`) |
| **Plattform-interne Workflows** | PR-Gates, Validierung, Wartung des ci-platform-Repos | Nein |

**Consumer-Workflow** — Kriterien:

- `on.workflow_call` definiert
- Keine Annahmen über ein einzelnes Consumer-Repository
- In `docs/workflows/<name>.md` als Consumer-tauglich dokumentiert

**Plattform-intern** — Beispiele:

- `quality-base-set.yml` — PR-Gate und Release-Orchestrierung für ci-platform
- `validate-platform.yml` — Plattform-eigene Validierung
- `maintenance-*.yml` — Geplante Wartungsaufgaben (repository-intern)

---

# Repository-Struktur

```text
ci-platform/
├── .github/
│   └── workflows/
│       ├── quality-base-set.yml          # plattform-intern
│       ├── quality-link-check.yml        # consumer
│       ├── quality-lint.yml
│       ├── quality-markdown.yml
│       ├── quality-yaml.yml
│       ├── security-codeql.yml
│       ├── security-secret-scan.yml
│       ├── security-dependency-review.yml
│       ├── release-github.yml
│       ├── release-validate-tags.yml
│       ├── release-validate-branch.yml
│       ├── release-validate-tag-immutable.yml
│       ├── validate-platform.yml         # plattform-intern
│       ├── maintenance-link-check.yml    # plattform-intern
│       ├── build-<purpose>.yml           # pipeline-bausteine (geplant)
│       └── release-docker.yml            # pipeline-bausteine (geplant)
│
├── actions/
│   ├── quality-link-check/
│   │   ├── action.yml
│   │   └── README.md
│   ├── quality-markdown/
│   ├── security-secret-scan/
│   ├── docker-build/                     # geplant
│   └── setup-node/                       # geplant
│
├── scripts/
│   ├── lib/
│   │   ├── logging.sh
│   │   ├── git.sh
│   │   └── docker.sh
│   ├── release/
│   │   └── create-release.sh
│   └── validation/
│       └── validate-yaml.sh
│
├── docs/
│   ├── ci-platform.md                    # dieses Dokument (Soll-Überblick)
│   └── workflows/
│       ├── README.md
│       └── <workflow-name>.md
│
├── examples/                             # Phase 2
│   ├── node-service/
│   ├── java-service/
│   └── docker-service/
│
├── tests/                                # Phase 2
│   ├── workflow-tests/
│   ├── integration/
│   └── fixtures/
│
├── CHANGELOG.md
├── CODEOWNERS
├── LICENSE
└── README.md
```

---

# Komponenten

## Reusable Workflows

Reusable Workflows kapseln vollständige Pipeline-Logik und werden organisationsweit wiederverwendet.

Ablageort:

```text
.github/workflows/
```

Namenskonvention: `<category>-<purpose>.yml`

| Kategorie | Beschreibung | Beispiel |
|---|---|---|
| `quality` | Qualitätssicherung, Linting, Validierung | `quality-link-check.yml` |
| `security` | Sicherheitsprüfungen | `security-codeql.yml` |
| `release` | Veröffentlichungen, Tag-Validierung | `release-github.yml` |
| `build` | Build-Prozesse | `build-node.yml` |
| `maintenance` | Wartungsaufgaben (meist plattform-intern) | `maintenance-link-check.yml` |

Beispielverwendung:

```yaml
jobs:
  link-check:
    uses: clavicarius/ci-platform/.github/workflows/quality-link-check.yml@v1
```

---

## Composite Actions

Composite Actions kapseln wiederverwendbare Schrittfolgen innerhalb eines Jobs.

Ablageort:

```text
actions/<name>/action.yml
```

Namenskonvention: `<category>-<purpose>`

Beispiele:

- `quality-link-check`
- `security-secret-scan`
- `docker-build`
- `setup-node`

Beispielverwendung:

```yaml
steps:
  - uses: clavicarius/ci-platform/actions/docker-build@v1
```

---

## Gemeinsame Skripte

Shell- und Utility-Skripte für die **interne Implementierung** in Actions und Workflows.

Ablageort:

```text
scripts/
```

Beispiele:

- Logging Utilities (`scripts/lib/logging.sh`)
- Git Helper (`scripts/lib/git.sh`)
- Release Automation (`scripts/release/`)
- Validierungsskripte (`scripts/validation/`)

**Nutzungsregel:** `scripts/` sind nicht Teil der Consumer-API. Consumer-Repositories greifen nicht direkt auf Skripte zu, sondern nutzen sie indirekt über Composite Actions oder Reusable Workflows.

Ziel:

- Reduktion duplizierter Logik innerhalb der Plattform
- Konsistentes CLI-Verhalten
- Vereinfachte Wartung

---

# Consumer-Integration

Consumer-Repositories binden die Plattform flexibel ein — als Einzelworkflows oder als Bundle.

## Einzelworkflows

Jeder Consumer-Workflow wird individuell referenziert:

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read
  issues: write

jobs:
  link-check:
    uses: clavicarius/ci-platform/.github/workflows/quality-link-check.yml@v1

  secret-scan:
    uses: clavicarius/ci-platform/.github/workflows/security-secret-scan.yml@v1
```

## Basis-Set-Bundle

Alternativ bindet ein Bundle mehrere Checks in einem Schritt ein:

```yaml
jobs:
  quality:
    uses: clavicarius/ci-platform/.github/workflows/quality-base-set.yml@v1
```

Details und verfügbare Inputs: `docs/workflows/quality-base-set.md`

## Permissions und Secrets

Reusable Workflows laufen im Kontext des **aufrufenden Repositories**:

- Das Consumer-Repository wird geprüft (nicht ci-platform)
- Issues und Artefakte entstehen im Consumer-Repository
- Berechtigungen werden im Consumer-Workflow deklariert
- Secrets müssen im Consumer-Repository hinterlegt sein

```yaml
permissions:
  contents: read
  issues: write
  security-events: write   # nur wenn vom Workflow benötigt
```

Secrets werden nicht aus ci-platform übernommen. Erforderliche Secrets sind in der jeweiligen Workflow-Dokumentation (`docs/workflows/<name>.md`) aufgeführt.

## Version-Bindung

Consumer binden immer eine Major-Version:

```yaml
uses: clavicarius/ci-platform/.github/workflows/quality-link-check.yml@v1
```

Nicht für Produktion:

```yaml
uses: clavicarius/ci-platform/.github/workflows/quality-link-check.yml@main
```

Detaildokumentation pro Workflow: `docs/workflows/<name>.md`

---

# Versionierung

Alle öffentlichen CI-Komponenten werden versioniert.

## Semantic Versioning

Releases folgen Semantic Versioning:

```text
vMAJOR.MINOR.PATCH
```

Beispiele:

```text
v1.0.0
v1.2.3
v2.0.0-rc.1
```

## Floating Major für Consumer

Consumer binden an Major-Versionen (`@v1`, `@v2`). Der Major-Tag ist ein **Floating Alias** auf das jeweils neueste kompatible Release innerhalb dieser Major-Linie:

```text
@v1  →  zeigt auf neuestes v1.x.x
@v2  →  zeigt auf neuestes v2.x.x
```

## Automatische Major-Alias-Tags

Der Release-Workflow erzeugt bei jedem Release:

1. Semver-Tag (`v1.2.3`)
2. Major-Alias-Tag (`v1`) — zeigt auf den neuesten Stand der Major-Linie

Alias-Tag-Updates sind eine **bewusste Ausnahme** zur Tag-Immutabilität. Sie erfolgen ausschließlich durch den automatisierten Release-Workflow — nicht durch manuellen Force-Push.

## Breaking Changes

Breaking Changes dürfen ausschließlich in neuen Major-Versionen eingeführt werden.

Beispiele:

- Entfernte Inputs oder Outputs
- Neue Pflichtparameter
- Verändertes Verhalten bestehender Actions oder Workflows

## Sunset-Policy (Deprecation)

Veraltete Komponenten durchlaufen einen dokumentierten Lebenszyklus:

1. **Markierung** — Workflow/Action als `deprecated` in Dokumentation und ggf. im Workflow selbst kennzeichnen
2. **Kommunikation** — Eintrag in CHANGELOG, GitHub Issue oder Release Notes
3. **Support-Zeitraum** — Deprecated-Komponenten bleiben mindestens **2 Major-Versionen** erhalten
4. **Entfernung** — Erst nach Ablauf des Support-Zeitraums; nur in neuem Major

---

# Release-Prozess

## Workflow

```text
Feature Branch
    ↓
Pull Request
    ↓
Validation Pipeline (validate-platform / quality-base-set)
    ↓
Review
    ↓
Merge
    ↓
Automatischer Release-Workflow
    ↓
Semver-Tag (v1.2.3)
    ↓
Major-Alias-Tag (v1)
    ↓
GitHub Release + CHANGELOG
```

## Release-Artefakte

Jeder Release enthält:

- Semver Git-Tag (`v1.2.3`)
- Major-Alias-Tag (`v1`)
- GitHub Release mit Release Notes
- CHANGELOG-Eintrag
- Versionierte Actions und Workflows

---

# Qualitätsstandards

Alle Änderungen müssen validiert werden.

## Pflichtprüfungen

- YAML Validation
- actionlint
- shellcheck
- Workflow-Syntaxprüfung
- Integrationstests (Phase 2)

---

# Sicherheit

## Grundregeln

- Keine Secrets im Repository
- Least-Privilege-Prinzip
- Verwendung offizieller Actions bevorzugen
- Gepinnte Action-Versionen (Tag oder Commit-SHA)
- Keine unkontrollierten `latest`-Tags

Beispiel — gepinnt:

```yaml
uses: actions/checkout@v4
```

Noch sicherer:

```yaml
uses: actions/checkout@<commit-sha>
```

---

# Dokumentation

Jede Action und jeder Workflow muss dokumentiert sein.

## Struktur

| Dokument | Zweck |
|---|---|
| `docs/ci-platform.md` | Soll-Zielbild und Plattform-Überblick (dieses Dokument) |
| `docs/workflows/<name>.md` | Detaildokumentation pro Workflow |
| `docs/workflows/README.md` | Übersicht aller verfügbaren Workflows |
| `actions/<name>/README.md` | Kurzdokumentation pro Action |

## Pflichtinhalte pro Workflow/Action

- Zweck
- Inputs und Outputs
- Benötigte Permissions und Secrets
- Beispielintegration
- Voraussetzungen
- Bekannte Einschränkungen
- Consumer-tauglich oder plattform-intern

---

# Governance

## CODEOWNERS

Alle Änderungen an zentralen CI-Komponenten benötigen Reviews durch die Plattformverantwortlichen.

Datei: `CODEOWNERS` (Pflicht)

## CHANGELOG

Jede Version wird in `CHANGELOG.md` dokumentiert (Pflicht).

## LICENSE

Lizenzierung ist in `LICENSE` festgelegt (Pflicht).

## Branch Protection

Empfohlen für `main`:

- Pflichtreviews
- Erfolgreiche CI-Checks
- Keine direkten Pushes
- Signierte Commits optional
- Tag Protection für `v*`-Tags

---

# Naming Conventions

## Workflows

```text
<category>-<purpose>.yml
```

Beispiele:

```text
quality-link-check.yml
security-codeql.yml
release-github.yml
build-node.yml
```

## Actions

```text
<category>-<purpose>
```

Ordnername entspricht dem Workflow-Namen, wenn die Action die Workflow-Implementierung kapselt:

```text
.github/workflows/quality-link-check.yml
  ↔ actions/quality-link-check/action.yml
```

## Scripts

```text
scripts/<bereich>/<zweck>.sh
scripts/validate-<purpose>.sh
```

---

# Best Practices

## Reusable Workflows verwenden für

- vollständige Pipelines
- Build-, Test- und Release-Prozesse
- komplexe Job-Orchestrierung
- Consumer-API mit `workflow_call`

## Composite Actions verwenden für

- wiederverwendbare Schrittfolgen
- Setup-Logik
- technische Hilfsfunktionen innerhalb eines Jobs

## Skripte verwenden für

- komplexe Bash-Logik
- gemeinsam genutzte Funktionen innerhalb der Plattform
- CLI-Utilities (nur intern, nicht für Consumer)

---

# Roadmap

## Tag 1 (Soll-Zielbild Kern)

- `actions/` an Repository-Root (Migration von `.github/actions/`)
- Kategorie-basierte Workflow-Namen (`quality-`, `security-`, `release-`)
- Semver-Versionierung mit Floating Major (`@v1`) und automatischen Alias-Tags
- Explizite Trennung plattform-intern / Consumer-API
- Consumer-Dokumentation pro Workflow (`docs/workflows/<name>.md`)
- Governance-Artefakte: CHANGELOG, CODEOWNERS, LICENSE

## Phase 2

- `examples/` — vollständige Consumer-Integrationen (Node, Java, Docker, Monorepo)
- `tests/` — Workflow-Tests, Integrationstests, Fixtures
- Pipeline-Bausteine: `build-*`, `test-*`, `release-docker`
- Integrationstests als Pflichtprüfung in validate-platform

---

# Zielbild

Die CI-Plattform soll:

- wartbar
- versionierbar
- dokumentiert
- standardisiert
- sicher
- organisationsweit wiederverwendbar

sein.

Langfristig dient das Repository als zentrale Grundlage für sämtliche CI/CD-Prozesse innerhalb der Organisation. Consumer-Repositories wählen flexibel zwischen Einzelworkflows und Basis-Set-Bundles und binden über stabile Major-Versionen (`@v1`) ein.
