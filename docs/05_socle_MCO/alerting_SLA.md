# Alerting & SLA

**Implémentation :** voir [`monitoring/dashboards/`](../../monitoring/dashboards/)

## SLA cibles

| Indicateur | Seuil SLA | Source |
|------------|-----------|--------|
| Disponibilité base | ≥ 99,9 % / mois | `sys.event_log` connexions ok/total |
| Latence `fact_order` | ≤ 5 min | `MAX(order_timestamp)` vs `GETUTCDATE()` |
| Latence `fact_clickstream` | ≤ 2 min | `MAX(event_timestamp)` vs `GETUTCDATE()` |

Requêtes de calcul : [`sla_availability.sql`](../../monitoring/queries/sla_availability.sql)

## Règles d'alerte Azure Monitor (6 règles)

| Règle | Condition | Sévérité |
|-------|-----------|----------|
| CPU élevé | avg CPU > 80% / 5 min | Warning |
| DTU saturée | DTU > 90% / 5 min | Error |
| Connexions échouées | > 10 en 5 min | Error |
| Pipeline orders silencieux | 0 commande en 10 min | Error |
| Pipeline clickstream silencieux | 0 événement en 5 min | Warning |
| Stockage > 80% | storage_percent > 80 | Warning |

Spécification complète : [`alert_rules_spec.md`](../../monitoring/dashboards/alert_rules_spec.md)

## Tableau de bord

Spécification Power BI 6 tiles (disponibilité, latence, volume, statut SLA global) :
[`dashboard_sla_spec.md`](../../monitoring/dashboards/dashboard_sla_spec.md)
