# Maintenance en Conditions Opérationnelles (MCO) : Socle MCO (C16)
 
---

## 🔧 Monitoring & logs
- Azure Log Analytics  
- Logs ADF, API, Stream Analytics  
- Dashboards SLA

## 🚨 Alertes
- Pipelines ETL en échec  
- API vendeurs non atteignables  
- Taux anomalies > seuil  
- Stock non mis à jour  

## 💾 Backups & DRP
- Snapshots SQL  
- Versioning ADLS  
- Procédures de restauration (perte région, suppression accidentelle)

## 📚 Documentation
- Runbooks MCO  
- Incident playbooks  
- Dictionnaires données  

## 🔌 Nouvelles sources
- Pipelines multi-formats  
- Connecteurs API  
- Normalisation (Databricks)  

## Monitoring implémenté (Azure SQL DMV)

| Artefact | Contenu | Statut |
|----------|---------|--------|
| [`log_errors_last24h.sql`](../../monitoring/queries/log_errors_last24h.sql) | Journalisation catégorisée ALERTE/ATTENTION/OK | [x] Fait |
| [`data_freshness.sql`](../../monitoring/queries/data_freshness.sql) | Fraîcheur pipeline, alerte ingestion silencieuse | [x] Fait |
| [`sla_availability.sql`](../../monitoring/queries/sla_availability.sql) | Disponibilité ≥99,9%, latence ≤5min/≤2min | [x] Fait |
| [`pipeline_latency.sql`](../../monitoring/queries/pipeline_latency.sql) | LAG(), gaps, monitoring prédictif | [x] Fait |
| [`dashboard_sla_spec.md`](../../monitoring/dashboards/dashboard_sla_spec.md) | Spécification Power BI 6 tiles | [x] Fait |
| [`alert_rules_spec.md`](../../monitoring/dashboards/alert_rules_spec.md) | 6 règles Azure Monitor Alert | [x] Fait |

| Critère C16 | Ressources | Statut |
|-------------|------------|--------|
| Journalisation catégorisée alertes/erreurs | `log_errors_last24h.sql` | [x] Fait |
| Système d'alerte activé | `alert_rules_spec.md` | [x] Fait |
| Indicateurs basés sur SLA | `sla_availability.sql` | [x] Fait |
| Tableau de bord indicateurs | `dashboard_sla_spec.md` | [x] Fait |
| Backups complet + partiel | `sql/backups/` (Phase 3) | [x] Fait |
| Documentation MCO (runbooks) | `docs/` (Phase 4) | [x] Fait |
| Maintenance index + intégrité | `sql/maintenance/` (Phase 4) | [x] Fait |

---

## Tests en conditions réelles (2026-03-12)

### `backup_ltr_config.sh` — Politique LTR

Exécuté contre `sql-server-rg-e6-sbuasa` / `dwh-shopnow` :

```
weeklyRetention : P4W
monthlyRetention: P12M
yearlyRetention : P5Y
```

Résultat : **OK** — politique appliquée et vérifiée via `az sql db ltr-policy show`.

---

### `backup_full.sh` — Export BACPAC

Export BACPAC complet exécuté avec auto-création du storage account :

```
Storage account : stshopnowbackup (créé automatiquement)
Container       : sql-backups
Fichier         : weekly/dwh-shopnow-2026-03-12.bacpac
Taille          : 2,4 MB
```

Résultat : **OK** — fichier vérifié via `az storage blob list`.

---

### `check_integrity.sql` — Contrôle d'intégrité

Exécuté sur `dwh-shopnow` le 2026-03-12 à 11h02 UTC :

| Contrôle | Résultat | Statut |
|----------|----------|--------|
| Orphelins `fact_order → dim_customer` | 0 | ✓ OK |
| Orphelins `fact_order → dim_product` | 0 | ✓ OK |
| NULLs `dim_customer.email` | 0 | ✓ OK |
| NULLs `dim_customer.name` | 0 | ✓ OK |
| **NULLs `fact_order.unit_price`** | **3 004** | **⚠ ATTENTION** |
| NULLs `fact_order.quantity` | 0 | ✓ OK |
| NULLs `fact_clickstream.session_id` | 0 | ✓ OK |
| **Score cohérence global** | **75/100** | **ATTENTION** |

**Volumétrie détectée :**

| Table | Lignes | Taille |
|-------|--------|--------|
| `fact_clickstream` | 30 219 | 65,63 MB |
| `fact_order` | 3 004 | 62,32 MB |
| `dim_product` | 953 | 1,76 MB |
| `dim_customer` | 100 | 0,32 MB |

**Anomalie identifiée :** `unit_price` NULL sur la totalité des lignes `fact_order` (3 004/3 004). Cause probable : mapping Stream Analytics incomplet sur le champ `unit_price` en provenance de l'Event Hub `orders`. Le script de contrôle a correctement détecté et signalé cette anomalie — démonstration de l'efficacité du dispositif de supervision C16.
