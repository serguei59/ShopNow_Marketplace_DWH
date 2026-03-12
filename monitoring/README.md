# Dossier Monitoring — DWH ShopNow Marketplace

**Projet :** DWH ShopNow Marketplace  
**Responsable :** Serge Buasa  
**Date :** 2026-03-11  
**Certification :** RNCP 37638 — Compétence C16

---

## Contexte technique

Base de données : Azure SQL Database S0  
Serveur : `sql-server-rg-e6-sbuasa.database.windows.net`  
Base : `dwh-shopnow`  
Pipeline : ACI producers → Event Hubs → Stream Analytics → Azure SQL

Les requêtes exploitent les DMV (Dynamic Management Views) natives d'Azure SQL,
accessibles sans droits admin : `sys.event_log`, `sys.dm_exec_requests`,
`sys.dm_db_resource_stats`, `sys.dm_exec_query_stats`.

---

## Structure du dossier

monitoring/
├── README.md                              ← ce fichier (index)
├── queries/
│   ├── log_errors_last24h.sql             ← journalisation catégorisée (C16)
│   ├── data_freshness.sql                 ← fraîcheur pipeline, alertes ingestion
│   ├── sla_availability.sql               ← indicateurs SLA (disponibilité, latence)
│   └── pipeline_latency.sql               ← performance pipeline, monitoring prédictif
└── dashboards/
├── dashboard_sla_spec.md              ← spécification Power BI 6 tiles
└── alert_rules_spec.md               ← 6 règles Azure Monitor Alert



---

## Requêtes SQL

### `queries/log_errors_last24h.sql`
**Critère C16 :** Journalisation catégorisée alertes et erreurs  
4 requêtes :
1. Événements critiques `sys.event_log` — connexions échouées, deadlocks, throttling (sévérité ALERTE/ATTENTION/INFO)
2. Sessions bloquantes actives `sys.dm_exec_requests` — temps d'attente, requête en cours
3. Consommation ressources `sys.dm_db_resource_stats` — CPU/IO/mémoire avec seuils ALERTE/ATTENTION/OK
4. Top 10 requêtes coûteuses `sys.dm_exec_query_stats` — CPU cumulé, lectures logiques

### `queries/data_freshness.sql`
**Critère C16 :** Supervision pipeline, alertes ingestion ratée  
4 requêtes :
1. Vue consolidée fraîcheur par table (FRAIS / ATTENTION / STALE)
2. Alerte pipeline orders silencieux — 0 commande dans les 15 dernières minutes
3. Volume journalier J-7 — détection dérive tendancielle
4. Détection doublons `fact_clickstream` — event_id non unique

### `queries/sla_availability.sql`
**Critère C16 :** Indicateurs de service basés sur les SLA  
SLA cibles : disponibilité ≥ 99,9% / latence `fact_order` ≤ 5 min / latence `fact_clickstream` ≤ 2 min  
3 requêtes :
1. Taux de disponibilité par jour sur 30 jours (connexions ok/total) + statut SLA OK/KO
2. Fraîcheur temps réel `fact_order` et `fact_clickstream` avec étiquettes SLA
3. Synthèse mensuelle KPI (rapport direction)

### `queries/pipeline_latency.sql`
**Critère C16 :** Performance pipeline, monitoring prédictif  
3 requêtes :
1. Latence inter-insertions `fact_order` avec `LAG()` — min/max/écart-type
2. Gaps `fact_clickstream` > 10 s avec sévérité (ALERTE > 60s, ATTENTION > 30s)
3. Volume horaire J-7 vs moyenne même heure — détection dégradation progressive

---

## Spécifications supervision

### `dashboards/dashboard_sla_spec.md`
**Critère C16 :** Tableau de bord permettant de rendre compte de l'ensemble des indicateurs de service  
Spécification Power BI : 6 tiles (disponibilité, latence fact_order, latence clickstream,
taux erreurs, volume journalier, statut SLA global), filtres période/table/statut,
Vue MCO (technique) et Vue Direction (synthèse).

### `dashboards/alert_rules_spec.md`
**Critère C16 :** Système d'alerte mis en place et activé en cas d'erreur notifiée dans les journaux  
6 règles Azure Monitor Alert : CPU > 80%, DTU > 90%, connexions échouées > 10/5min,
fraîcheur `fact_order` > 10min, fraîcheur `fact_clickstream` > 5min, stockage > 80%.  
3 Action Groups : MCO, Data Engineer, Slack webhook.

---

## Cartographie critères C16

| Critère C16 | Artefact |
|-------------|---------|
| Journalisation catégorisée alertes/erreurs | `log_errors_last24h.sql` |
| Système d'alerte activé | `alert_rules_spec.md` |
| Indicateurs basés sur SLA | `sla_availability.sql` |
| Tableau de bord indicateurs | `dashboard_sla_spec.md` |
| Supervision pipeline (ingestion) | `data_freshness.sql`, `pipeline_latency.sql` |
