# Références techniques

## Azure — Documentation officielle

| Ressource | URL |
|-----------|-----|
| Azure SQL Database — niveaux de service | docs.microsoft.com/azure/azure-sql/database/service-tiers-dtu |
| PITR — Point-In-Time Restore | docs.microsoft.com/azure/azure-sql/database/recovery-using-backups |
| LTR — Long-Term Retention | docs.microsoft.com/azure/azure-sql/database/long-term-retention-overview |
| az sql db export (BACPAC) | docs.microsoft.com/cli/azure/sql/db#az-sql-db-export |
| Stream Analytics — requêtes | docs.microsoft.com/azure/stream-analytics/stream-analytics-stream-lake-input |
| DMV Azure SQL (`sys.dm_db_resource_stats`) | docs.microsoft.com/azure/azure-sql/database/monitoring-with-dmvs |
| Terraform azurerm provider | registry.terraform.io/providers/hashicorp/azurerm/latest |

## Standards et bonnes pratiques

| Référence | Application dans le projet |
|-----------|---------------------------|
| **RGPD art. 30** | Registre des traitements — `security/rgpd/registre_traitements.md` |
| **CNIL — durée conservation clickstream** | 13 mois — `security/rgpd/procedures_conformite.md` |
| **Kimball — SCD Type 2** | Pattern valid_from/valid_to/is_current — `sql/scd2/dim_vendor_create.sql` |
| **Azure Well-Architected Framework — Reliability** | RPO/RTO définis — `docs/08_DRP/plan_continuite.md` |
| **Microsoft — index maintenance** | Seuils REORGANIZE <30% / REBUILD ≥30% — `sql/maintenance/index_maintenance.sql` |

## Outils utilisés

| Outil | Version | Usage |
|-------|---------|-------|
| Terraform | azurerm v4.54.0 | Infrastructure as Code |
| sqlcmd | ODBC Driver 17 | Exécution scripts SQL |
| Azure CLI | az 2.x | Backup, LTR, monitoring |
| Python Faker | `faker` lib | Génération données démo |
| MkDocs + Material | — | Documentation site |
