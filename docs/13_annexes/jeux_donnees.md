# Jeux de données — ShopNow DWH

## Données générées en temps réel (Python Faker)

Les données sont générées par `_events_producers/producers.py` via la librairie **Faker**.
Elles sont fictives — aucune donnée personnelle réelle.

### Pool clients (100 entrées au démarrage ACI)

| Champ | Générateur Faker | Exemple |
|-------|-----------------|---------|
| `customer_id` | `uuid4()` | `a1b2c3d4-...` |
| `name` | `fake.name()` | `Jean Dupont` |
| `email` | `fake.email()` | `jean.dupont@example.com` |
| `address` | `fake.street_address()` | `12 rue de la Paix` |
| `city` | `fake.city()` | `Lyon` |
| `country` | `fake.country()` | `France` |

### Pool produits (1000 entrées au démarrage ACI)

| Champ | Générateur Faker | Exemple |
|-------|-----------------|---------|
| `product_id` | `uuid4()` | `00012656-3bfe-...` |
| `name` | `fake.catch_phrase()` | `Persevering stable alliance` |
| `category` | `random.choice(...)` | `Electronics`, `Home`, `Clothing`, `Books`, `Beauty` |
| `price` | `random.uniform(5, 300)` | `149.99` |

### Vendeurs démo (dim_vendor — 5 entrées)

| vendor_id | vendor_name | country | commission_rate | status |
|-----------|-------------|---------|-----------------|--------|
| V001 | TechGadgets SAS | France | 14.00 (après SCD2) | active |
| V002 | ModaStyle GmbH | Germany | 10.00 | active |
| V003 | HomeDecor Ltd | UK | 11.00 | active |
| V004 | SportZone Iberia | Spain | 15.00 | suspended |
| V005 | ElectroShop BV | Netherlands | 9.50 | active |

### Volumétrie au 2026-03-12

| Table | Lignes approx. | Croissance |
|-------|---------------|------------|
| `dim_customer` | ~100 | Stable (pool fixe) |
| `dim_product` | 972 | Stable (pool fixe) |
| `fact_order` | Variable | +1 toutes les 60s |
| `fact_clickstream` | Variable | +1 toutes les 2s (~43 200/j) |
| `dim_vendor` | 6 (5 actifs + 1 historique) | Batch quotidien |
| `fact_vendor_stock` | 25 (démo) | Batch horaire |
