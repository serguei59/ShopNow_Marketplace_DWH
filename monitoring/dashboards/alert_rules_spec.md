# Spécification Règles d'Alerte — DWH ShopNow Marketplace

**Outil cible :** Azure Monitor Alerts
**Critère C16 :** Système d'alerte mis en place et activé en cas d'erreur notifiée dans les journaux
**Date :** 2026-03-11

---

## Action Groups

| Groupe | Destinataires | Canal |
|--------|--------------|-------|
| `ag-mco-shopnow` | MCO | Email : mco@shopnow.fr |
| `ag-dataeng-shopnow` | Data Engineer | Email : dataeng@shopnow.fr |
| `ag-slack-shopnow` | Équipe data | Webhook Slack (optionnel) |

---

## Règles d'alerte — 6 règles

### Règle 1 — CPU élevé

| Champ | Valeur |
|-------|--------|
| **Nom** | `alert-cpu-high-dwh` |
| **Condition** | `avg_cpu_percent > 80` |
| **Source** | `sys.dm_db_resource_stats` |
| **Fenêtre évaluation** | 5 minutes |
| **Fréquence évaluation** | 1 minute |
| **Sévérité** | 2 — Warning |
| **Action Group** | `ag-mco-shopnow` |
| **Message** | "CPU Azure SQL dwh-shopnow > 80% depuis 5 min" |

### Règle 2 — DTU saturée

| Champ | Valeur |
|-------|--------|
| **Nom** | `alert-dtu-critical-dwh` |
| **Condition** | `dtu_consumption_percent > 90` |
| **Source** | Azure Monitor Metric — DTU Consumption Percent |
| **Fenêtre évaluation** | 5 minutes |
| **Fréquence évaluation** | 1 minute |
| **Sévérité** | 1 — Error |
| **Action Group** | `ag-mco-shopnow`, `ag-dataeng-shopnow` |
| **Message** | "DTU dwh-shopnow > 90% — risque throttling imminent" |

### Règle 3 — Connexions échouées répétées

| Champ | Valeur |
|-------|--------|
| **Nom** | `alert-connection-failures-dwh` |
| **Condition** | connexions échouées > 10 sur 5 minutes |
| **Source** | `sys.event_log` — `event_type = 'connection_failed'` |
| **Fenêtre évaluation** | 5 minutes |
| **Fréquence évaluation** | 5 minutes |
| **Sévérité** | 1 — Error |
| **Action Group** | `ag-mco-shopnow` |
| **Message** | "Plus de 10 connexions échouées en 5 min sur dwh-shopnow" |

### Règle 4 — Pipeline orders silencieux (fraîcheur fact_order)

| Champ | Valeur |
|-------|--------|
| **Nom** | `alert-freshness-fact-order` |
| **Condition** | `MAX(order_timestamp) < DATEADD(MINUTE, -10, GETUTCDATE())` |
| **Source** | `data_freshness.sql` — Requête 2 |
| **Fenêtre évaluation** | 10 minutes |
| **Fréquence évaluation** | 5 minutes |
| **Sévérité** | 1 — Error |
| **Action Group** | `ag-dataeng-shopnow`, `ag-slack-shopnow` |
| **Message** | "ALERTE — aucune commande ingérée depuis 10 min (SLA : ≤5 min)" |

### Règle 5 — Pipeline clickstream silencieux (fraîcheur fact_clickstream)

| Champ | Valeur |
|-------|--------|
| **Nom** | `alert-freshness-fact-clickstream` |
| **Condition** | `MAX(event_timestamp) < DATEADD(MINUTE, -5, GETUTCDATE())` |
| **Source** | `data_freshness.sql` — Requête 1 |
| **Fenêtre évaluation** | 5 minutes |
| **Fréquence évaluation** | 2 minutes |
| **Sévérité** | 2 — Warning |
| **Action Group** | `ag-dataeng-shopnow` |
| **Message** | "ATTENTION — aucun événement clickstream depuis 5 min (SLA : ≤2 min)" |

### Règle 6 — Stockage proche de la limite

| Champ | Valeur |
|-------|--------|
| **Nom** | `alert-storage-high-dwh` |
| **Condition** | `storage_percent > 80` |
| **Source** | Azure Monitor Metric — Storage Percent |
| **Fenêtre évaluation** | 15 minutes |
| **Fréquence évaluation** | 15 minutes |
| **Sévérité** | 2 — Warning |
| **Action Group** | `ag-mco-shopnow` |
| **Message** | "Stockage dwh-shopnow > 80% — S0 limité à 250 GB" |

---

## Procédure de création Azure CLI

```bash
# Créer l'action group MCO
az monitor action-group create \
  --resource-group rg-e6-sbuasa \
  --name ag-mco-shopnow \
  --short-name mco \
  --email-receiver name=MCO email=mco@shopnow.fr

# Exemple : créer la règle CPU (Règle 1)
az monitor metrics alert create \
  --name alert-cpu-high-dwh \
  --resource-group rg-e6-sbuasa \
  --scopes "/subscriptions/51a5ea3c-2ada-4f97-b2a1-a26eda3b14f2/resourceGroups/rg-e6-sbuasa/providers/Microsoft.Sql/servers/sql-server-rg-e6-sbuasa/databases/dwh-shopnow" \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --severity 2 \
  --action ag-mco-shopnow \
  --description "CPU Azure SQL dwh-shopnow > 80% depuis 5 min"
```

> **Note environnement de test :** Les règles Azure Monitor ne sont pas activées
> dans cet environnement de formation (pas de budget alerting). Cette spécification
> constitue la preuve de conception requise par le critère C16.

---

## Récapitulatif sévérités

| Sévérité | Label | Règles concernées |
|----------|-------|------------------|
| 0 | Critical | — |
| 1 | Error | Règles 2, 3, 4 |
| 2 | Warning | Règles 1, 5, 6 |
| 3 | Informational | — |
