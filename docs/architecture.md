# Architecture

Das Repository folgt einer zweistufigen Architektur:

```
github-workflows/
├── .github/
│   ├── workflows/
│   │   ├── quality-link-check.yml
│   │   ├── security-codeql.yml
│   │   └── release-docker.yml
│   │
│   └── actions/
│       └── ...
│
├── docs/
│   ├── workflows/
│   │   ├── README.md
│   │   ├── quality-link-check.md
│   │   ├── security-codeql.md
│   │   └── release-docker.md
│   │
│   ├── actions/
│   │   └── ...
│   │
│   ├── architecture.md
│   ├── quality.md
│   ├── security.md
│   └── release.md

├── scripts/
│   ├── helper scripts
│   └── automation tools
│
├── README.md
└── AGENTS.md
```

Damit bleibt die Verantwortung klar getrennt:

| Datei                          | Zweck                                         |
| ------------------------------ | --------------------------------------------- |
| `README.md`                    | Architektur, Verwendung, Entwicklungsregeln   |
| `AGENTS.md`                    | Regeln für AI-Agenten                         |
| `docs/workflows/README.md`     | Übersicht aller verfügbaren Workflows         |
| `docs/workflows/<workflow>.md` | Detaildokumentation eines einzelnen Workflows |

