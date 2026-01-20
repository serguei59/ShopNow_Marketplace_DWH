# Maintenance en Conditions Opérationnelles (MCO) : Adaptations SCD2 (C17)

---

## DIM_VENDOR (SCD2)
```sql
VendorID (SK)
VendorNK
VendorName
Status
Category
IsCurrent
ValidFrom
ValidTo
```
## DIM_PRODUCT enrichie
```sql
VendorID FK
ProductSource (internal / vendor)
```

## Nouvelle fact : FACT_VENDOR_STOCK
```sql
StockLevel
Timestamp
VendorID
```

## Pipelines SCD2

- Détection de changement
- Insert nouvelle ligne
- Fermeture ancien enregistrement

| Critère | Action | Ressources | Statut |
|---------|--------|------------|--------|
| Modélisation | Ajouter dim_vendor SCD2 | SQL Database | [ ] |
| Adaptations dim_product | ProductSource, VendorID | SQL Database | [ ] |
| Fact tables | fact_vendor_stock, fact_data_quality | SQL Database, Stream Analytics, ADF | [ ] |
| ETL | Pipelines modifiés SCD2 | ADF, Databricks | [ ] |
| Documentation | Schéma et règles SCD2 | Docs/README | [ ] |
