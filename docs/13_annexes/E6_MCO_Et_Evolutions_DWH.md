# E6_MCO_Et_Evolutions_DWH.md
Socle obligatoire (C16–C17) + évolutions complémentaires, avec ressources et cases à cocher.

---

## 1️⃣ Socle obligatoire – Maintenance en Condition Opérationnelle (C16)

| Critère | Action | Ressource nécessaire | Statut | ✅ |
|---------|--------|----------------------|--------|----|
| **C16.1 – Journalisation & supervision** | Configurer logs ETL | Azure Log Analytics, Azure Monitor | À ajouter | [ ] |
|  | Configurer logs API vendeurs | Azure Log Analytics, ADF monitoring | À ajouter | [ ] |
|  | Configurer logs Stream Analytics | Azure Log Analytics | Existante | [ ] |
| **C16.2 – Alerting** | Alertes erreurs ETL / flux API / anomalies stock | Azure Monitor + Alert Rules | À ajouter | [ ] |
| **C16.3 – Priorisation & suivi** | Définir SLA / indicateurs service | Power BI Dashboard, tableau suivi SLA | À ajouter | [ ] |
| **C16.4 – Backups & Reprise après incident** | Backup complet SQL DWH (snapshots automatisés) | Azure SQL Snapshots, automated backup policy | Existante | [ ] |
|  | Backup partiel tables critiques (dim_vendor, dim_product, facts sensibles) | SQL Database + ADLS incremental snapshots | À ajouter | [ ] |
|  | Backup metadata store (schémas, mapping vendeurs, dictionnaires) | ADLS / Purview | À ajouter | [ ] |
|  | Plan de restauration après incident : suppression accidentelle, corruption, perte totale (type OVH) | Runbook MCO, procédure de restauration, Terraform state + redeploy | À ajouter | [ ] |
|  | Tests périodiques de restauration (DRP tests) | SQL restore sandbox, ADLS restore sandbox | À ajouter | [ ] |
| **C16.5 – Documentation** | Procédures MCO : intégration sources, création accès, capacity planning | Docs/README, Terraform modules README | Existante / à compléter | [ ] |
|  | Procédures incidents : erreurs ETL, API down, saturation stockage | Docs/Incident-Playbooks | À ajouter | [ ] |
| **C16.6 – Intégration nouvelles sources** | Ajouter source CSV/JSON/Excel | Azure Data Factory, Storage Event Triggers | Existante / à compléter | [ ] |
|  | Ajouter source API vendeur | ADF REST pipelines + Azure Functions | À ajouter | [ ] |
|  | Ajouter source streaming Event Hubs | Event Hubs, Stream Analytics | Existante | [ ] |
|  | Normalisation schémas vendeurs | Databricks / Synapse pipelines | À ajouter | [ ] |
|  | Mise en place zones RAW / CLEAN / CURATED / REJECT | ADLS Gen2, ADF, Synapse | À ajouter | [ ] |

---

## 2️⃣ Adaptation ETL aux SCD (C17)

| Critère | Action | Ressource nécessaire | Statut | ✅ |
|---------|--------|----------------------|--------|----|
| **C17.1 – Modélisation variations** | Ajouter dim_vendor SCD2 | SQL Database, dwh_schema.sql | À ajouter | [ ] |
|  | Ajouter champs ProductSource, VendorID dans dim_product | SQL Database, dwh_schema.sql | À ajouter | [ ] |
| **C17.2 – Intégration variations** | Créer fact_vendor_stock (variations stock/temps) | SQL Database, Stream Analytics, Event Hubs | À ajouter | [ ] |
|  | Créer fact_data_quality | SQL Database, ADF / Databricks | À ajouter | [ ] |
| **C17.3 – Mise à jour ETL** | Pipelines modifiés pour gérer SCD2 | ADF, Databricks, Stream Analytics | À ajouter | [ ] |
|  | Insertion nouvelle ligne si changement détecté | SQL Database + ADF | À ajouter | [ ] |
|  | Clôture ancien enregistrement | SQL Database + ADF | À ajouter | [ ] |
| **C17.4 – Documentation** | Documentation SCD2, MLD, MCD, schéma DWH | Docs/README + dwh_schema.sql | À ajouter | [ ] |

---

## 3️⃣ Évolutions complémentaires (optionnelles mais argumentées)

| Action | Ressource nécessaire | Statut | ✅ |
|--------|----------------------|--------|----|
| Enrichissement flux API pour suivi prix & stock temps réel | Azure Functions, Event Hubs, ADF, Databricks | À ajouter | [ ] |
| Amélioration scoring qualité vendeur | SQL Database, Databricks, Power BI | À ajouter | [ ] |
| Optimisation requêtes fact tables | SQL Database (columnstore, partitions) | Existante / à optimiser | [ ] |
| Tableau de bord Power BI multi-vendeur (RLS vendeur) | Power BI, Row Level Security | À ajouter | [ ] |
| Historisation clickstream par vendeur | Event Hubs, Stream Analytics, ADLS | À ajouter | [ ] |

---

# 4️⃣ Stack de ressources par socle

---

## 4.1 Socle MCO (C16)

| Ressource | Usage | Statut |
|-----------|--------|--------|
| Azure Event Hubs | Réception flux temps réel vendeurs | Existante |
| SQL Database | Stockage DWH, dimensions + facts | Existante |
| SQL Snapshots (automated backups) | Restauration rapide / anti-delete | Existante |
| ADLS Gen2 | Zones RAW / CLEAN / CURATED / REJECT | À ajouter |
| ADLS Snapshots | Sauvegarde dictionnaires / metadata | À ajouter |
| Azure Data Factory | Pipelines fichiers + API vendeurs | À ajouter / compléter |
| Stream Analytics | Intégration temps réel vers SQL | Existante |
| Azure Log Analytics | Logs ETL, API, streaming | À ajouter |
| Azure Monitor | Alerting + SLA | À ajouter |
| Purview (ou ADLS metadata folder) | Métadonnées & catalogues | À ajouter |
| Runbooks MCO / DRP | Procédures restauration post-incident | À ajouter |
| Terraform | Reconstruction complète infra après perte DC | Existante |
| Docs / README | Procédures, playbooks, runbooks | À compléter |

---

## 4.2 Socle SCD / C17

| Ressource | Usage | Statut |
|-----------|--------|--------|
| SQL Database | Implémentation SCD2 | À ajouter |
| ADF | Pipelines SCD2 (detect & insert) | À ajouter |
| Databricks | Normalisation schémas vendeurs, SCD scalable | À ajouter |
| Stream Analytics | Fact_vendor_stock temps réel | Existante |
| Docs/README | Documentation SCD2 | À compléter |

---

## 4.3 Évolutions complémentaires

| Ressource | Usage | Statut |
|-----------|--------|--------|
| Azure Functions | Connecteurs API avancés | À ajouter |
| Databricks | Scoring qualité, enrichissement | À ajouter |
| Power BI | Dashboard productivité / multi vendeur | À compléter |
| SQL Database | Optimisations (partitions, columnstore) | À optimiser |

---

## 5️⃣ Suivi des cases à cocher

Chaque action peut être cochée une fois réalisée.  
Ce fichier permet de suivre :  
- le socle obligatoire C16 (MCO)  
- le socle obligatoire C17 (SCD2)  
- les évolutions complémentaires  
- les ressources Terraform nécessaires  
- les procédures de restauration, RLS, normalisation  
