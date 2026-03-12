# Qualité des données

Contrôles implémentés via [`check_integrity.sql`](../../sql/maintenance/check_integrity.sql) :

| Contrôle | Résultat (2026-03-12) | Statut |
|----------|----------------------|--------|
| Orphelins `fact_order → dim_customer` | 0 | ✓ OK |
| Orphelins `fact_order → dim_product` | 0 | ✓ OK |
| NULLs `dim_customer.email` | 0 | ✓ OK |
| NULLs `fact_order.unit_price` | 3 004 | ⚠ ATTENTION |
| NULLs `fact_order.quantity` | 0 | ✓ OK |
| NULLs `fact_clickstream.session_id` | 0 | ✓ OK |
| **Score cohérence global** | **75/100** | **ATTENTION** |

**Anomalie identifiée :** `unit_price` NULL sur toutes les lignes `fact_order` —
cause probable : mapping Stream Analytics incomplet sur le champ `unit_price`.

Voir aussi : [`monitoring/queries/data_freshness.sql`](../../monitoring/queries/data_freshness.sql)
pour la détection de doublons clickstream et la fraîcheur pipeline.
