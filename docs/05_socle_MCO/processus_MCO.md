# Processus MCO

**Implémentation :** voir [`sql/maintenance/`](../../sql/maintenance/) et [`monitoring/`](../../monitoring/)

## Cycle de maintenance hebdomadaire

| Jour | Action | Script / Outil |
|------|--------|---------------|
| Lundi | Contrôle d'intégrité DWH | [`check_integrity.sql`](../../sql/maintenance/check_integrity.sql) |
| Mercredi | Analyse fragmentation index | [`index_maintenance.sql`](../../sql/maintenance/index_maintenance.sql) |
| Dimanche 02h00 | Backup BACPAC complet | [`backup_full.sh`](../../sql/backups/backup_full.sh) |
| Dimanche 03h00 | Vérification alertes Azure Monitor | [`alert_rules_spec.md`](../../monitoring/dashboards/alert_rules_spec.md) |

## Processus de gestion d'incident

### 1. Détection
- Azure Monitor déclenche une alerte (6 règles configurées)
- Ou anomalie détectée via tableau de bord Power BI
- Ou requête de supervision manuelle (`log_errors_last24h.sql`)

### 2. Qualification
Exécuter dans Azure SQL Query Editor :

```sql
-- Vérifier l'état des ressources
SELECT * FROM sys.dm_db_resource_stats ORDER BY end_time DESC;

-- Identifier les sessions bloquantes
SELECT blocking_session_id, session_id, wait_type, wait_time
FROM sys.dm_exec_requests WHERE blocking_session_id > 0;
```

### 3. Correction
| Type d'incident | Action |
|-----------------|--------|
| Pipeline silencieux | Redémarrer le job Stream Analytics |
| Fragmentation index > 30% | Exécuter `index_maintenance.sql` (REBUILD) |
| Données corrompues / orphelines | Exécuter `check_integrity.sql`, corriger manuellement |
| Base indisponible | Déclencher PITR via `restore_procedure.sh` |

### 4. Reprocess
- Vérifier la fraîcheur des données après correction : [`data_freshness.sql`](../../monitoring/queries/data_freshness.sql)
- Valider les SLA : [`sla_availability.sql`](../../monitoring/queries/sla_availability.sql)

### 5. Documentation
- Consigner l'incident dans le registre MCO (date, durée, cause, action corrective)
- Mettre à jour les runbooks si nécessaire

## Indicateurs de santé en continu

| Fréquence | Requête | Seuil d'alerte |
|-----------|---------|----------------|
| Toutes les 5 min | `log_errors_last24h.sql` | Niveau ALERTE détecté |
| Toutes les 5 min | `data_freshness.sql` | Pipeline silencieux > 10 min |
| Mensuelle | `sla_availability.sql` | Disponibilité < 99,9% |
| Hebdomadaire | `check_integrity.sql` | Score cohérence < 75 |
