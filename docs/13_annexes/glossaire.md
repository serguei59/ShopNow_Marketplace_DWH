# Glossaire

| Terme | Définition |
|-------|-----------|
| **SCD2** | Slowly Changing Dimension Type 2 — conservation de l'historique par versioning (valid_from / valid_to / is_current) |
| **MERGE** | Instruction SQL permettant INSERT/UPDATE/DELETE en une seule opération atomique sur la base d'une correspondance source/cible |
| **DTU** | Database Transaction Unit — unité de mesure des ressources Azure SQL (CPU + mémoire + I/O combinés) |
| **PITR** | Point-In-Time Restore — restauration à un instant précis via les journaux de transaction Azure SQL (rétention 35 jours) |
| **LTR** | Long-Term Retention — conservation des sauvegardes au-delà de 35 jours (P4W / P12M / P5Y) |
| **BACPAC** | Format d'export portable Azure SQL (schéma + données) — équivalent backup complet pour Azure SQL Database |
| **RPO** | Recovery Point Objective — perte de données maximale acceptable (ici : < 15 min) |
| **RTO** | Recovery Time Objective — durée maximale de restauration acceptable (ici : < 2 heures) |
| **RBAC** | Role-Based Access Control — contrôle d'accès basé sur des rôles SQL (db_datareader, db_datawriter, etc.) |
| **ETL** | Extract, Transform, Load — processus d'alimentation du DWH depuis les sources |
| **Stream Analytics** | Service Azure de traitement de flux temps réel (ici : Event Hubs → Azure SQL) |
| **Event Hub** | Service Azure d'ingestion de messages à haute volumétrie (compatible Kafka) |
| **ACI** | Azure Container Instances — conteneurs serverless utilisés pour les producteurs Python Faker |
| **DWH** | Data Warehouse — entrepôt de données structuré pour l'analytique |
| **MCO** | Maintien en Condition Opérationnelle — ensemble des processus assurant la disponibilité et la qualité du DWH |
| **SLA** | Service Level Agreement — engagement de disponibilité (ici : 99,9 % mensuel) |
| **RGPD** | Règlement Général sur la Protection des Données — réglementation européenne sur les données personnelles |
| **DMV** | Dynamic Management View — vues système Azure SQL exposant les métriques temps réel (ressources, sessions, index) |
| **IaC** | Infrastructure as Code — provisionnement d'infrastructure via du code versionné (ici : Terraform) |
| **Terraform** | Outil IaC HashiCorp — déploiement déclaratif d'infrastructure cloud via des fichiers `.tf` |
