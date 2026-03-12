# Diagnostic de l'architecture existante

## Architecture avant C16/C17

```
Python producers (ACI)
  → Event Hubs (orders / products / clickstream)
  → Stream Analytics (job continu, 1 SU)
  → Azure SQL S0 dwh-shopnow
       ├─ dim_customer   (PII : name, email, address)
       ├─ dim_product    (product_id VARCHAR(50), name, category)
       ├─ fact_order     (order_id, product_id, customer_id, quantity, unit_price)
       └─ fact_clickstream (event_id, session_id, user_id, url, event_type)
```

## Analyse par domaine

### Ingestion

| Constat | Impact |
|---------|--------|
| 3 flux Event Hub actifs (orders/clickstream/products) | ✓ Opérationnel |
| Pas de gestion d'erreur sur Stream Analytics | Risque : pipeline silencieux |
| Pas de mécanisme batch pour les vendeurs | Manquant pour C17 |
| `unit_price` NULL sur 3004 lignes `fact_order` | Mapping ASA incomplet détecté |

### Stockage

| Constat | Impact |
|---------|--------|
| Azure SQL S0 — 10 DTU, 2 GB | Suffisant pour MVP |
| Pas de dimension vendeur | À créer (C17) |
| `product_id` en UUID VARCHAR(50) | Attention FK type mismatch |
| Pas de zones Raw/Curated/Serve | Non requis sur Azure SQL |

### Sécurité

| Constat | Impact |
|---------|--------|
| Firewall `0.0.0.0–255.255.255.255` | Risque — toutes IPs autorisées |
| Pas de RBAC documenté | À créer (C16) |
| Pas de registre RGPD | À créer (C16) |
| sqladmin = seul compte | Pas de comptes nominatifs |

### Supervision

| Constat | Impact |
|---------|--------|
| Pas de monitoring DMV configuré | Risque incident non détecté |
| Pas d'alertes Azure Monitor | Aucune notification en cas de panne |
| Pas de SLA défini | Impossible de mesurer la disponibilité |
| Pas de backup planifié | Risque de perte de données |

### Maintenance

| Constat | Impact |
|---------|--------|
| Pas de script d'intégrité | Anomalies non détectées (unit_price NULL) |
| Pas de maintenance d'index | Fragmentation 99.9% sur fact_clickstream |
| Pas de schedule de backup | PITR Azure SQL actif mais non documenté |
