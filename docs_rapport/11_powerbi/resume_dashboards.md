# Dashboards — Supervision et analytique

---

## Dashboard SLA — Monitoring opérationnel

Spécification dans [`monitoring/dashboards/dashboard_sla_spec.md`](../../monitoring/dashboards/dashboard_sla_spec.md)

| Tile | Indicateur | Source | Seuil alerte |
|------|-----------|--------|-------------|
| Disponibilité DB | % uptime mensuel | `sys.event_log` | < 99,9% |
| Latence `fact_order` | Délai dernière insertion | `fact_order.order_timestamp` | > 5 min |
| Latence `fact_clickstream` | Délai dernière insertion | `fact_clickstream.event_timestamp` | > 2 min |
| Taux erreurs connexion | Connexions échouées/total | `sys.event_log` | > 5% |
| Volume journalier | Insertions J vs moy. J-7 | `fact_order` COUNT | < 50% moy. |
| Statut SLA global | OK / ATTENTION / ALERTE | Calcul combiné | Tout seuil dépassé |

Statut : [x] Spécification complète — [`dashboard_sla_spec.md`](../../monitoring/dashboards/dashboard_sla_spec.md)

---

## Dashboard Vendeurs — Analytique Marketplace

Vue analytique sur `vw_vendor_stock_disponible` :

```sql
SELECT vendor_id, vendor_name, product_name,
       quantity_available, stock_net, stock_timestamp
FROM dbo.vw_vendor_stock_disponible
WHERE stock_net > 0
ORDER BY vendor_id, product_name;
```

| Indicateur | Description |
|-----------|-------------|
| Stock net par vendeur | `quantity_available - quantity_reserved` |
| Historique commission | `dim_vendor` — toutes versions SCD2 |
| Répartition produits | 972 produits / 3 vendeurs actifs |

Statut : [x] Vue `vw_vendor_stock_disponible` opérationnelle — testée 2026-03-12

---

## Cloisonnement RBAC

Le rôle `Vendor` dans la matrice RBAC accède uniquement à des vues filtrées par `vendor_id`.
Pas de RLS Power BI natif implémenté (hors périmètre MVP) — cloisonnement au niveau SQL.

| Couche | Mécanisme | Statut |
|--------|-----------|--------|
| RBAC Azure SQL | 5 rôles, permissions SQL minimales | [x] Fait |
| Vues filtrées SQL | SELECT restreint par vendor_id | [x] Documenté |
| RLS Power BI | DAX row-level security | [ ] Hors périmètre MVP |

Voir : [`security/rbac/rbac_mapping.md`](../../security/rbac/rbac_mapping.md)
