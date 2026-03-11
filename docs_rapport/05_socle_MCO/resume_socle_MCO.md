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
| Backups complet + partiel | `sql/backups/` (Phase 3) | [ ] À faire |
| Documentation MCO (runbooks) | `docs/` (Phase 4) | [ ] À faire |
