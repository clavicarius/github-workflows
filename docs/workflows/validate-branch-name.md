# Validate Branch Name

Datei:

```
.github/workflows/validate-branch-name.yml
actions/validate-branch-name/action.yml
scripts/validate-branch-name.sh
```

---

## Zweck

Der **Validate Branch Name Workflow** prüft bei Pull Requests, ob der
Source-Branch die verbindliche Namenskonvention erfüllt.

Er ist **repository-intern** und dient als PR-Gate für geschützte Branches.

---

## Architektur

| Komponente | Verantwortung |
|---|---|
| `validate-branch-name.yml` | Trigger, Permissions, Job-Orchestrierung |
| `validate-branch-name/action.yml` | Composite Action mit Inputs |
| `scripts/validate-branch-name.sh` | Regex-Validierung und Fehlermeldungen |

---

## Trigger

| Trigger | Beschreibung |
|---|---|
| `pull_request` auf `main`, `develop` | Validiert `github.head_ref` gegen die Konvention |

---

## Validierungsregel

Erlaubte Präfixe:

- `feature/`
- `enhancement/`
- `bugfix/`
- `hotfix/`
- `release/`
- `chore/`
- `copilot/`

Der Branch-Typ `copilot/` ist für von Agenten erzeugte Pull Requests vorgesehen.

Regex:

```regex
^(feature|enhancement|bugfix|hotfix|release|chore|copilot)\/[a-z0-9._-]+$
```

---

## Verhalten bei Fehlern

Bei ungültigem Branch-Namen schlägt der Job fehl und gibt eine klare
Fehlermeldung mit:

- gefundenem Branch-Namen
- erlaubten Präfixen
- erwarteter Struktur
- verwendetem Regex

---

## Branch Protection

Für geschützte Branches (`main`, `develop`) den Check
**Validate Branch Name / Validate branch name** als Required Status Check
konfigurieren.

---

## Siehe auch

- [Quality Base Set](quality-base-set.md)
