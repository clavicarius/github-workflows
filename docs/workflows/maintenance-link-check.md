# Maintenance Link Check

Datei:

```
.github/workflows/maintenance-link-check.yml
```

> **Breaking change (v1):** Umbenannt von
> `check-broken-links-in-markdown.yml`. Betrifft nur dieses Repository
> (kein `workflow_call`). Externe Consumer, die den Dateipfad direkt
> referenziert haben, müssen auf den neuen Namen umstellen.

---

## Zweck

Der **Maintenance Link Check Workflow** führt eine geplante wöchentliche
Linkprüfung für dieses Repository aus.

Er ist **repository-intern** und nicht als wiederverwendbarer `workflow_call`
konzipiert. Für einbindbare Linkprüfungen in anderen Repositories siehe
[Quality Link Check](quality-link-check.md).

---

## Trigger

| Trigger | Beschreibung |
|---|---|
| `schedule` | Sonntags um 11:11 UTC |
| `workflow_dispatch` | Manueller Start |

---

## Verhalten

- prüft Links mit Lychee
- erstellt oder aktualisiert ein Issue bei defekten Links
- schließt das Issue automatisch, wenn alle Links wieder gültig sind

---

## Siehe auch

- [Quality Link Check](quality-link-check.md)
- [Quality Base Set](quality-base-set.md)
