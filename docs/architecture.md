# Architecture

Das Repository folgt einer zweistufigen Architektur:

```
github-workflows/
├── .github/
│   ├── workflows/
│   │   ├── quality-base-set.yml
│   │   ├── quality-link-check.yml
│   │   ├── quality-markdown.yml
│   │   ├── quality-yaml.yml
│   │   ├── quality-lint.yml
│   │   ├── security-codeql.yml
│   │   ├── security-secret-scan.yml
│   │   ├── security-dependency-review.yml
│   │   ├── release-validate-tags.yml
│   │   ├── release-validate-branch.yml
│   │   ├── release-github.yml
│   │   └── maintenance-link-check.yml
│   │
│   └── actions/
│       ├── quality-link-check/
│       ├── quality-markdown/
│       ├── quality-yaml/
│       ├── quality-lint/
│       ├── security-secret-scan/
│       ├── security-dependency-review/
│       ├── release-validate-tags/
│       └── release-validate-branch/
│
├── docs/
│   ├── workflows/
│   │   ├── README.md
│   │   └── <workflow>.md
│   │
│   ├── architecture.md
│   └── RELEASING.md
│
├── scripts/
│   ├── validate-version-tag.sh
│   └── validate-release-branch.sh
│
├── README.md
└── AGENTS.md
```

Damit bleibt die Verantwortung klar getrennt:

| Datei | Zweck |
|---|---|
| `README.md` | Architektur, Verwendung, Entwicklungsregeln |
| `AGENTS.md` | Regeln für AI-Agenten |
| `docs/workflows/README.md` | Übersicht aller verfügbaren Workflows |
| `docs/workflows/<workflow>.md` | Detaildokumentation eines einzelnen Workflows |
| `.github/workflows/<workflow>.yml` | Trigger, Permissions, Orchestrierung |
| `.github/actions/<action>/action.yml` | Wiederverwendbare Implementierungsschritte |
| `scripts/*.sh` | Komplexe Shell-Logik |

---

## Namenskonventionen

### Workflows

Dateiname: `<category>-<purpose>.yml`

| Kategorie | Beispiel |
|---|---|
| `quality` | `quality-link-check.yml` |
| `security` | `security-codeql.yml` |
| `release` | `release-github.yml` |
| `maintenance` | `maintenance-link-check.yml` |

### Composite Actions

Ordnername entspricht dem Workflow-Namen, wenn die Action die
Implementierung des Workflows kapselt:

```
.github/actions/release-validate-tags/action.yml
  ↔ .github/workflows/release-validate-tags.yml
```

### Scripts

```
scripts/validate-<purpose>.sh
```

Beispiele: `validate-version-tag.sh`, `validate-release-branch.sh`

---

## Release-Pipeline (Quality Base Set)

```
release-validate-tags → release-validate-branch → release-github
```

Siehe [Quality Base Set](workflows/quality-base-set.md) und
[RELEASING.md](RELEASING.md).
