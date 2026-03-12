# Ingestion Event Hubs — ShopNow

## Configuration déployée

| Paramètre | Valeur |
|-----------|--------|
| Namespace | `eh-sbuasa` (francecentral) |
| SKU | Basic |
| Capacity | 1 unité de débit |
| Hubs | orders, clickstream, products |
| Retention | 1 jour (Basic tier) |

## Hubs et partitions

| Event Hub | Partitions | Producteur | Fréquence | Destination SQL |
|-----------|------------|------------|-----------|-----------------|
| `orders` | 2 | ACI Python | 60s | `fact_order` |
| `clickstream` | 2 | ACI Python | 2s | `fact_clickstream` |
| `products` | 2 | ACI Python | 120s | `dim_product` |

## Format des messages

### orders
```json
{
  "order_id": "uuid",
  "customer_id": "uuid",
  "product_id": "uuid",
  "quantity": 3,
  "unit_price": 29.99,
  "status": "pending",
  "order_timestamp": "2026-03-12T12:00:00Z"
}
```

### clickstream
```json
{
  "session_id": "uuid",
  "user_id": "uuid",
  "url": "/products/uuid",
  "event_type": "page_view",
  "event_timestamp": "2026-03-12T12:00:00Z"
}
```

### products
```json
{
  "product_id": "uuid",
  "name": "Ergonomic client-driven groupware",
  "category": "Electronics",
  "price": 149.99
}
```

## Authentification

- **Connection string** injectée en variable d'environnement dans le container ACI (`EVENTHUB_CONNECTION_STR`)
- **Stream Analytics** lit via Input configuré avec la même connection string
- Politique d'accès : `RootManageSharedAccessKey` (Send + Listen + Manage)

## Architecture producteurs

```
ACI container (aeh-producers)
  └─ producers.py
       ├─ pool 100 clients Faker (généré au démarrage)
       ├─ pool 1000 produits Faker (généré au démarrage)
       └─ boucle infinie :
            ├─ toutes les 2s  → clickstream → Event Hub clickstream
            ├─ toutes les 60s → order       → Event Hub orders
            └─ toutes les 120s → product    → Event Hub products
```

Image Docker : `blackphoenix2020/event_hub_producers:latest`
(reconstruite depuis `_events_producers/` — image prof `sengsathit/` inaccessible)
