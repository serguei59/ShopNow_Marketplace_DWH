# E6 – Situations types professionnelles  
*Marketplace ShopNow – Maintenance et évolutions du Data Warehouse*

Ce document présente **toutes les situations professionnelles simulées**, permettant de justifier pleinement les compétences **C16** et **C17**, dans un contexte Marketplace multi-vendeurs avec contraintes de qualité, sécurité, évolutivité et résilience.

---

# 1️⃣ Situation 1 : Intégration multi-sources vendeurs (CSV, API, Excel)

## Problème  
Les vendeurs fournissent leurs données sous des formats hétérogènes :  
- Excel (petits vendeurs)  
- CSV déposés sur SFTP  
- API structurée pour grands vendeurs  

## Actions  
- Pipelines ADF ingesting multi-sources  
- Détection automatique du schéma  
- Normalisation via Databricks  
- Insertion en zone RAW → CLEAN → CURATED  

## Compétences  
- **C16.1** (diagnostic formats)  
- **C16.4** (mise en œuvre évolutions)  
- **C17.1** (qualité données)  

---

# 2️⃣ Situation 2 : Contrôles qualité + isolation des anomalies

## Problème  
Des vendeurs envoient :  
- des stocks négatifs  
- des prix incohérents  
- des lignes sans ProductID  
- 2 fichiers différents dans la même journée  

## Actions  
- ADF + Databricks → règles qualité  
- Table "vendor_data_quality"  
- Table anomalies pour audit  
- Alerting automatique via Azure Monitor  

## Compétences  
- **C16.1** (diagnostic dysfonctionnements)  
- **C16.5** (vérifier corrections)  
- **C17.1** (qualité)  
- **C17.4** (documentation incidents)

---

# 3️⃣ Situation 3 : Historisation SCD2 (suivi vendeur / produits)

## Problème  
Les vendeurs modifient fréquemment :  
- tarifs  
- délais  
- conditions contractuelles  

## Actions  
- Création de DIM_VENDOR en SCD2  
- Pipelines ADF avec détection de changement  
- Fermeture des anciennes lignes + insertion historique  

## Compétences  
- **C17.1** (qualité historique)  
- **C17.3** (continuité du DWH)  
- **C16.3 / C16.4** (évolution structurelle)

---

# 4️⃣ Situation 4 : Flux streaming – monitoring du stock en temps réel

## Problème  
Le marketing veut visualiser les ruptures en temps réel.

## Actions  
- Event Hubs → ingestion événements de stock  
- Stream Analytics → agrégation  
- Fact_vendor_stock → SQL  
- Power BI en DirectQuery  

## Compétences  
- **C16.2** (besoin d’évolution)  
- **C16.3** (proposer architecture optimisée)  
- **C17.3** (disponibilité temps réel)

---

# 5️⃣ Situation 5 : Sécurité – cloisonnement vendeur (multi-tenant)

## Problème  
Chaque vendeur doit voir **uniquement ses données**.

## Actions  
- RBAC dans Azure AD (par vendeur)  
- RLS dans Power BI  
- Masquage dynamique dans SQL  
- Stockage segmenté dans ADLS (vendor_id partitions)

## Compétences  
- **C17.2** (sécurité d’accès)  
- **C16.3** (proposition d’amélioration)  

---

# 6️⃣ Situation 6 : Perte de données / DRP (catastrophe type OVH)

## Problème  
- Stagiaire supprime un dataset CLEAN  
- Incident majeur : perte région (type OVH Strasbourg)  

## Actions  
- Mise en place d’un **plan de reprise (DRP)**  
- Snapshots SQL journaliers + transaction logs  
- Versioning ADLS + soft delete + réplication GRS  
- Test de restauration trimestriel  

## Compétences  
- **C17.3** (continuité de service)  
- **C16.1** (diagnostic post-incident)  
- **C16.5** (vérification restauration)  

---

# 7️⃣ Situation 7 : Suivi SLA / supervision

## Problème  
Le responsable Marketplace réclame :  
- temps de disponibilité  
- erreurs par vendeur  
- délai d’arrivée des fichiers  
- durée des pipelines

## Actions  
- Dashboard SLA Power BI  
- Mesures : latence, volumétrie, erreurs, délais  
- Alertes Monitor  

## Compétences  
- **C16.3** (définition KPI)  
- **C17.4** (documentation monitoring)  

---

# 8️⃣ Situation 8 : Ajout nouveau vendeur (scénario réel demandé en E6)

## Actions  
- Création pipeline source dédiée  
- Normalisation automatique  
- Ajout RLS / RBAC  
- Ajout aux dashboards  

## Compétences  
- **C16.4** (mise en œuvre)  
- **C17.2** (sécurité)  

---

# 9️⃣ Situation 9 : Optimisation DWH (index, partitions, coûts)

## Problème  
Les requêtes deviennent lentes.

## Actions  
- Tables FACT partitionnées  
- Columnstore index  
- Tiering ADLS pour coûts optimisés  

## Compétences  
- **C16.3** (proposer optimisation)  
- **C16.5** (vérifier performance)  

---

# 10️⃣ Situation 10 : Documentation complète / transfert au futur MCO

## Actions  
- Schémas d’architecture  
- Procédures DRP  
- Procédures d’intégration de sources  
- Procédures sécurité / rôles  

## Compétences  
- **C16.5** (documentation)  
- **C17.4** (journalisation)  
