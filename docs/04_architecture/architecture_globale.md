# Architecture globale — DWH ShopNow Marketplace

## Vue d'ensemble

```mermaid
flowchart LR
    subgraph Producers["Producteurs (ACI)"]
        PY[Python + Faker\nblackphoenix2020/event_hub_producers]
    end

    subgraph Ingestion["Ingestion temps réel"]
        EH_O[Event Hub\norders]
        EH_C[Event Hub\nclickstream]
        EH_P[Event Hub\nproducts]
    end

    subgraph Streaming["Stream Analytics\nasa-shopnow"]
        ASA[Job continu\n1 Streaming Unit\nCompatibilité 1.2]
    end

    subgraph DWH["Azure SQL Database S0\ndwh-shopnow"]
        DC[dim_customer]
        DP[dim_product]
        FO[fact_order]
        FC[fact_clickstream]
        DV[dim_vendor\nSCD2]
        FVS[fact_vendor_stock]
    end

    subgraph Batch["Batch SCD2 — Marketplace"]
        MERGE[sp_merge_dim_vendor\nquotidien]
        INSERT[INSERT horodaté\nhoraire]
    end

    subgraph Backup["Sauvegarde"]
        PITR[PITR natif Azure\n35 jours continu]
        BACPAC[BACPAC hebdo\nAzure Blob Storage]
        LTR[LTR long terme\n5 ans]
    end

    PY --> EH_O & EH_C & EH_P
    EH_O & EH_C & EH_P --> ASA
    ASA --> FO & FC & DP & DC
    MERGE --> DV
    INSERT --> FVS
    DWH --> PITR & BACPAC & LTR
```

---

## Composants déployés

| Composant | Nom Azure | Rôle |
|-----------|-----------|------|
| Resource Group | `rg-e6-sbuasa` | Conteneur de toutes les ressources |
| Event Hubs namespace | `eh-sbuasa` | Bus de messages — 3 hubs |
| Stream Analytics | `asa-shopnow` | Transformation + écriture temps réel |
| Azure SQL Server | `sql-server-rg-e6-sbuasa` | Moteur base de données |
| Azure SQL Database | `dwh-shopnow` (S0, 10 DTU) | Entrepôt de données |
| ACI producers | `aeh-producers` | Simulation de flux (Python + Faker) |
| Storage Account | `stshopnowbackup` | Stockage des BACPAC |
| IaC | Terraform azurerm v4.54.0 | Déploiement reproductible |

---

## Schéma de données

```mermaid
erDiagram
    dim_customer {
        int customer_id PK
        nvarchar name
        nvarchar email
        nvarchar city
        nvarchar country
    }
    dim_product {
        varchar product_id PK
        nvarchar name
        nvarchar category
        nvarchar vendor_id FK
    }
    dim_vendor {
        int vendor_sk PK
        nvarchar vendor_id
        nvarchar vendor_name
        decimal commission_rate
        nvarchar status
        datetime2 valid_from
        datetime2 valid_to
        bit is_current
    }
    fact_order {
        int order_id PK
        varchar product_id FK
        int customer_id FK
        int quantity
        decimal unit_price
        datetime2 order_timestamp
    }
    fact_clickstream {
        int event_id PK
        nvarchar session_id
        nvarchar user_id
        nvarchar url
        nvarchar event_type
        datetime2 event_timestamp
    }
    fact_vendor_stock {
        int stock_id PK
        int vendor_sk FK
        varchar product_id FK
        int quantity_available
        int quantity_reserved
        decimal unit_cost
        datetime2 stock_timestamp
    }
    dim_customer ||--o{ fact_order : "customer_id"
    dim_product ||--o{ fact_order : "product_id"
    dim_vendor ||--o{ fact_vendor_stock : "vendor_sk"
    dim_product ||--o{ fact_vendor_stock : "product_id"
```

---

## Flux de données

| Flux | Source | Fréquence | Destination | Mécanisme |
|------|--------|-----------|-------------|-----------|
| Commandes | ACI Python | 60s | `fact_order` | Event Hub → Stream Analytics |
| Clickstream | ACI Python | 2s | `fact_clickstream` | Event Hub → Stream Analytics |
| Produits | ACI Python | 120s | `dim_product` | Event Hub → Stream Analytics |
| Vendeurs | Batch simulé | Quotidien | `dim_vendor` (SCD2) | `sp_merge_dim_vendor` |
| Stocks | Batch simulé | Horaire | `fact_vendor_stock` | INSERT horodaté |

---

## Choix d'architecture justifiés

| Décision | Choix | Alternative écartée | Raison |
|----------|-------|---------------------|--------|
| Ingestion temps réel | Stream Analytics | ADF + Databricks | Latence 2s requise pour clickstream |
| Base de données | Azure SQL S0 | SQL Managed Instance | MVP — 10 DTU suffisants, coût maîtrisé |
| SCD2 vendeurs | Procédure stockée `sp_merge_dim_vendor` | Pipeline ADF | Volume batch quotidien faible |
| Backup complet | BACPAC via `az sql db export` | `BACKUP TO DISK` | Azure SQL Database ne supporte pas BACKUP TO DISK |
| Producteurs | ACI (container) | Azure Functions | Simplicité déploiement Terraform |
