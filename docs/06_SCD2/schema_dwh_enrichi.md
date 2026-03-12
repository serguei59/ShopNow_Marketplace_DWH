# Schéma DWH enrichi — Post Marketplace

## Évolution du modèle

L'ouverture Marketplace a nécessité l'ajout de deux nouvelles entités et l'enrichissement de `dim_product`.

---

## Schéma cible

```mermaid
erDiagram
    dim_customer {
        int customer_id PK
        varchar name
        varchar email
        varchar address
        varchar city
        varchar country
    }
    dim_product {
        varchar product_id PK
        varchar name
        varchar category
        varchar vendor_id FK
    }
    dim_vendor {
        int vendor_id PK
        varchar vendor_name
        varchar contact_email
        decimal commission_rate
        date valid_from
        date valid_to
        bit is_current
    }
    fact_order {
        int order_id PK
        varchar product_id FK
        int customer_id FK
        int quantity
        decimal unit_price
        varchar status
        datetime order_timestamp
    }
    fact_clickstream {
        int event_id PK
        varchar session_id
        int user_id
        varchar url
        varchar event_type
        datetime event_timestamp
    }
    fact_vendor_stock {
        int stock_id PK
        int vendor_id FK
        varchar product_id FK
        int quantity_available
        int quantity_reserved
        datetime stock_timestamp
    }

    dim_product ||--o{ fact_order : "product_id"
    dim_customer ||--o{ fact_order : "customer_id"
    dim_vendor ||--o{ dim_product : "vendor_id"
    dim_vendor ||--o{ fact_vendor_stock : "vendor_id"
    dim_product ||--o{ fact_vendor_stock : "product_id"
```

---

## Entités ajoutées (Marketplace)

| Entité | Type | Rôle |
|--------|------|------|
| `dim_vendor` | Dimension SCD2 | Suivi historique des vendeurs et commissions |
| `fact_vendor_stock` | Table de faits | Disponibilité stock par vendeur/produit |

## Enrichissement `dim_product`

- Ajout colonne `vendor_id INT` → FK vers `dim_vendor`
- 972 produits mis à jour — 0 sans vendeur après migration
- Index filtré `idx_product_vendor` sur `vendor_id IS NOT NULL`

---

## Compatibilité ascendante

Les tables existantes (`fact_order`, `fact_clickstream`, `dim_customer`) n'ont pas été modifiées. Les pipelines streaming sont inchangés.
