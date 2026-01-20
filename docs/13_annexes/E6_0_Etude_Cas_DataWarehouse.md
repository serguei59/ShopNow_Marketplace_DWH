# 🌐 ÉTUDE DE CAS E6 -- Évolution d'un Data Warehouse existant (ShopNow Marketplace)

## 1. Analyse structurée de la situation

### 1.1. Contexte actuel

Le Data Warehouse repose sur : - dim_customer\
- dim_product\
- fact_order\
- fact_clickstream\
- alimentation via ETL internes + flux temps réel via Azure Event Hubs\
Il a été conçu pour un modèle vendeur unique.

### 1.2. Changement stratégique : passage en Marketplace

Conséquence : intégration de vendeurs tiers → augmentation de la
complexité du DWH.

**Impacts immédiats :** - Nouveaux objets métiers\
- Multiplication des flux entrants\
- Hétérogénéité des données\
- Besoin de cloisonnement\
- Suivi historique vendeur

## 2. Limites du Data Warehouse actuel

-   Pas de dimension vendeur\
-   Pas de multi-offres\
-   Pas de SCD2\
-   Pas de structure stock / qualité\
-   Flux limités\
-   Qualité non contrôlée\
-   Pas de RLS

## 3. Évolutions proposées

-   dim_vendor SCD2\
-   Extension dim_product\
-   fact_vendor_stock\
-   fact_data_quality

## 4. ETL Azure

-   ADF fichiers\
-   ADF REST + Functions pour API\
-   Event Hubs\
-   Databricks

## 5. Qualité

-   Validation schéma / cohérence\
-   Zones raw/clean/curated/reject\
-   Score vendeur

## 6. Sécurité

-   RBAC + RLS\
-   ACL ADLS

## 7. Monitoring

-   Log Analytics\
-   Tableau bord volumes / rejets / latence

## 8. Maintenance

-   purge raw\
-   partitions\
-   columnstore\
-   ACL\
-   dictionnaires\
-   backups

## 9. RGPD

-   pseudonymisation\
-   durée conservation\
-   droit à l'oubli

## 10. SLA

-   DWH 99,9%\
-   commandes \<15 min\
-   API vendeur 15 min\
-   stock \<5 min

## 11. Documentation

Architecture, dictionnaire, SCD, supervision, SLA, maintenance.

## 12. Argumentaire oral

« Le passage Marketplace rend l'architecture actuelle insuffisante.\
J'ai proposé une extension du modèle (dim_vendor SCD2 + facts), une
ingestion multi-sources robuste et un renforcement sécurité/monitoring.\
Objectif : un DWH fiable, sécurisé et évolutif. »
