# Supervision & Logging

**Implémentation :** voir [`monitoring/queries/`](../../monitoring/queries/)

## Requêtes de journalisation (Azure SQL DMV)

| Fichier | Contenu |
|---------|---------|
| [`log_errors_last24h.sql`](../../monitoring/queries/log_errors_last24h.sql) | Événements critiques `sys.event_log`, sessions bloquantes, ressources CPU/IO (seuils ALERTE/ATTENTION/OK), top 10 requêtes coûteuses |
| [`data_freshness.sql`](../../monitoring/queries/data_freshness.sql) | Fraîcheur par table (FRAIS/ATTENTION/STALE), alerte pipeline silencieux, volume J-7, doublons clickstream |
| [`pipeline_latency.sql`](../../monitoring/queries/pipeline_latency.sql) | Latence inter-insertions LAG(), gaps clickstream, volume horaire vs moyenne (monitoring prédictif) |

## Sources Azure SQL utilisées

- `sys.event_log` — connexions échouées, deadlocks, throttling (disponible sans droits admin)
- `sys.dm_exec_requests` — sessions bloquantes actives
- `sys.dm_db_resource_stats` — CPU/IO/mémoire (granularité 15 s, conservé 1h)
- `sys.dm_exec_query_stats` — statistiques requêtes cumulées

## Catégorisation des sévérités

| Label | Critère exemple |
|-------|----------------|
| `ALERTE` | CPU > 80%, wait_time > 30s, gap clickstream > 60s |
| `ATTENTION` | CPU > 60%, wait_time > 10s, gap clickstream > 30s |
| `OK` | Sous les seuils |
