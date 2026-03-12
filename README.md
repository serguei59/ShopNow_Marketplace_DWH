# E6 — DWH Marketplace ShopNow

**Certification RNCP 37638 — Expert en infrastructures de données massives**
Épreuve E6 — Étude de cas : Maintenance et évolution d'un Data Warehouse
Auteur : Serge Buasa

---

## Contexte

ShopNow pivote vers un modèle Marketplace multi-vendeurs. Ce projet couvre l'évolution du Data Warehouse existant pour répondre aux exigences de la certification :

- **C16** — Gérer l'entrepôt de données (MCO, supervision, sauvegardes, RGPD, SLA)
- **C17** — Implémenter les Slowly Changing Dimensions (SCD2 `dim_vendor`, ETL adapté)

---

## Architecture

```
Python producers (ACI Faker) → Event Hubs → Stream Analytics → Azure SQL (dwh-shopnow)
                                                                      ↑
                                                 Batch SCD2 (sp_merge_dim_vendor)
```

| Ressource | Nom |
|-----------|-----|
| Azure SQL Database | `dwh-shopnow` (S0, francecentral) |
| Event Hubs | orders / clickstream / products |
| Stream Analytics | `asa-shopnow` |
| Infrastructure | Terraform azurerm v4.54.0 |

---

## Scores de validation E6

| Compétence | Score |
|-----------|-------|
| C16 — MCO | 13/13 — 100% |
| C17 — SCD2 | 6/6 — 100% |

Tests réalisés en conditions réelles le **2026-03-12**.

---

## Structure du dépôt

```
docs/               Documentation technique complète (MkDocs)
docs_rapport/       Livrable certifiant condensé (MkDocs + PDF)
sql/
  backups/          Scripts BACPAC + LTR
  maintenance/      check_integrity.sql, index_maintenance.sql
  scd2/             dim_vendor, sp_merge_dim_vendor, fact_vendor_stock
monitoring/         Requêtes SQL supervision + specs dashboards
security/           RGPD registre + RBAC mapping
terraform/          IaC — modules Azure
_events_producers/  Producteurs Python Faker (ACI)
```

---

## Documentation

- **Site complet** : `https://serguei59.github.io/ShopNow_Marketplace_DWH/`
- **Livrable E6** : `https://serguei59.github.io/ShopNow_Marketplace_DWH/rapport/`

Déployé automatiquement sur GitHub Pages à chaque push sur `main`.

---

## Lancer localement

```bash
pip install mkdocs mkdocs-material pymdown-extensions
mkdocs serve --config-file mkdocs.yaml         # site complet → http://localhost:8000
mkdocs serve --config-file mkdocs_rapport.yaml # livrable E6  → http://localhost:8000
```
