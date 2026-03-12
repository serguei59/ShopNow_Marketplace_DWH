# Référence technique — Lot 2 : SCD2 C17 (Marketplace multi-vendeurs)

**Projet :** E6 – DWH ShopNow Marketplace
**Auteur :** Serge Buasa
**Date :** 2026-03-12
**Certification :** RNCP 37638 – Expert en infrastructures de données massives
**Compétence couverte :** C17 – Implémenter les Slowly Changing Dimensions (SCD)

---

## Architecture de référence — après C17

```
Event Hubs (eh-sbuasa)
  orders / products / clickstream
      │
      ▼
Stream Analytics Job (continu, 1 streaming unit)
      │
      ▼
Azure SQL Database S0 — dwh-shopnow
      │
      ├─ dim_customer        (PII — inchangé C17)
      ├─ dim_product         (enrichi : + vendor_id FK nullable)
      ├─ fact_order          (inchangé C17)
      ├─ fact_clickstream    (inchangé C17)
      │
      ├─ dim_vendor          ← NOUVEAU SCD2 (valid_from/to, is_current)
      └─ fact_vendor_stock   ← NOUVEAU (stocks par vendeur/produit)

API vendeurs (batch simulé) → sp_merge_dim_vendor → dim_vendor (SCD2)
API vendeurs (batch simulé) → INSERT horodaté   → fact_vendor_stock
```

---

## Principes d'ordonnancement

1. **Dimension avant faits** — `dim_vendor` avant `fact_vendor_stock` (FK vendor_sk)
2. **Procédure après table** — `sp_merge_dim_vendor` après la table `dim_vendor`
3. **Enrichissement non destructif** — `dim_product_update.sql` utilise `IF NOT EXISTS` + nullable
4. **Tests avant documentation rapport** — artefacts validés en conditions réelles avant inclusion

---

## Cartographie critères C17 → étapes

| Critère C17 | Étapes |
|-------------|--------|
| Modélisation SCD2 (valid_from/to, is_current, surrogate key) | 1 |
| Procédure MERGE SCD2 automatisée | 2 |
| Nouvelle table de faits liée à la dimension SCD2 | 3 |
| Enrichissement dimension existante (non destructif) | 4 |
| Documentation modélisation | 5 |
| Documentation ETL adapté | 6 |
| Synthèse rapport certifiant | 7 |

---

## Roadmap détaillée — 7 étapes

---

### PHASE 1 — Schéma SCD2

---

#### Étape 1 — `sql/scd2/dim_vendor_create.sql`

- **Statut :** [x] Fait — 2026-03-12
- **Critère C17 :** Modélisation SCD Type 2
- **Contenu :**
  - Table `dbo.dim_vendor` avec colonnes SCD2 : `vendor_sk` (PK IDENTITY), `vendor_id` (natural key), `valid_from`, `valid_to` (NULL = version courante), `is_current` (BIT)
  - Attributs trackés : `vendor_name`, `commission_rate`, `status`, `country`, `region`
  - Attribut non tracké : `vendor_email` (UPDATE direct sans nouvelle version)
  - Index : `IX_dim_vendor_vendor_id_current` (vendor_id, is_current) + `IX_dim_vendor_valid_from`
  - 4 vendeurs démo : TechGadgets SAS (FR), ModaStyle GmbH (DE), HomeDecor Ltd (UK), SportZone Iberia (ES)
- **Test en conditions réelles :** `(4 rows affected)` — 2026-03-12 12:40:56
- **Justification jury :** La surrogate key `vendor_sk` est immuable — c'est le fondement du SCD2 qui permet aux faits de référencer une version précise sans rompre l'historique.
- **Dépendances :** `dim_product` existant (FK indirecte via vendor_id)

---

#### Étape 2 — `sql/scd2/dim_vendor_merge.sql`

- **Statut :** [x] Fait — 2026-03-12
- **Critère C17 :** Procédure MERGE SCD2 automatisée
- **Contenu :** Procédure stockée `sp_merge_dim_vendor` — 3 cas :

| Cas | Déclencheur | Action SQL |
|-----|-------------|------------|
| Nouveau vendeur | `vendor_id` inconnu | INSERT version 1 (`valid_from=now`, `valid_to=NULL`, `is_current=1`) |
| Attribut tracké changé | `commission_rate`, `status`, `country`, `region`, `vendor_name` | UPDATE ancienne version (`valid_to=now`, `is_current=0`) + INSERT nouvelle version |
| Changement mineur | `vendor_email` seul | UPDATE direct sans nouvelle ligne SCD2 |

- **Test en conditions réelles — SCD2 V001 commission 12.50 → 14.00 :**
  ```
  vendor_sk  vendor_id  commission_rate  valid_from                   valid_to                     is_current
  1          V001       12.50            2026-03-12 12:40:56.203      2026-03-12 12:41:48.559      0
  5          V001       14.00            2026-03-12 12:41:48.559      NULL                         1
  ```
- **Test nouveau vendeur :** V005 ElectroShop BV inséré (commission 9.50)
- **Justification jury :** La procédure est le cœur de C17 — elle prouve la maîtrise du pattern SCD2 complet (fermeture version + ouverture nouvelle version atomique).
- **Dépendances :** Étape 1

---

#### Étape 3 — `sql/scd2/fact_vendor_stock.sql`

- **Statut :** [x] Fait — 2026-03-12
- **Critère C17 :** Nouvelle table de faits liée à la dimension SCD2
- **Contenu :**
  - Table `dbo.fact_vendor_stock` : `stock_id` (PK), `vendor_sk` (FK → dim_vendor), `product_id` (FK → dim_product), `quantity_available`, `quantity_reserved`, `unit_cost`, `stock_timestamp`
  - Pattern **insert-only** : chaque mise à jour stock = nouveau enregistrement horodaté (auditabilité complète)
  - Vue `dbo.vw_vendor_stock_disponible` : join dim_vendor (is_current=1) + dim_product, calcul `stock_net = quantity_available - quantity_reserved`
  - Données démo : 5 vendeurs actifs × 5 produits = 25 lignes
- **Corrections appliquées :**
  - `product_id INT` → `product_id VARCHAR(50)` (type réel dans `dim_product` : UUID généré par Faker)
  - `GO` ajouté avant `CREATE OR ALTER VIEW` (obligatoire : VIEW doit être premier statement du batch)
- **Test en conditions réelles :** `(25 rows affected)` — vue opérationnelle — 2026-03-12 12:48:03
- **Justification jury :** La FK vers `vendor_sk` (surrogate key SCD2) garantit que les stocks référencent toujours une version précise du vendeur — c'est la preuve concrète de l'utilité du SCD2.
- **Dépendances :** Étapes 1 et 2

---

#### Étape 4 — `sql/scd2/dim_product_update.sql`

- **Statut :** [x] Fait — 2026-03-12
- **Critère C17 :** Enrichissement dimension existante (non destructif)
- **Contenu :**
  - `IF NOT EXISTS` sur le `ALTER TABLE ADD vendor_id` — idempotent, relançable sans erreur
  - Ajout colonne `vendor_id NVARCHAR(50) NULL` dans `dim_product` (nullable = compatibilité ascendante)
  - Mapping par catégorie : Electronics/Tech/Gadgets → V001, Clothing/Fashion → V002, Home/Decor → V003, Sports → V004, autres → V001 (défaut)
  - Index filtré `UX_dim_vendor_vendor_id_current` sur `dim_vendor(vendor_id) WHERE is_current=1`
- **Corrections appliquées :**
  - `GO` ajouté après `ALTER TABLE` (le batch suivant ne voit pas la nouvelle colonne sinon)
  - `SET QUOTED_IDENTIFIER ON; GO` avant `CREATE INDEX` filtré (requis par Azure SQL)
  - `IF NOT EXISTS` pour idempotence (colonne déjà créée au premier run échoué)
- **Test en conditions réelles :**

| Métrique | Résultat |
|----------|----------|
| Produits mis à jour | 972 |
| Produits sans vendeur | **0** |
| V001 TechGadgets (Electronics + défaut) | 587 |
| V002 ModaStyle (Clothing) | 195 |
| V003 HomeDecor (Home) | 190 |

- **Justification jury :** ALTER TABLE non destructif — les requêtes existantes sur `dim_product` continuent de fonctionner. La colonne nullable garantit la compatibilité avec `fact_order` et `fact_clickstream` qui ne connaissent pas les vendeurs.
- **Dépendances :** Étape 1

---

### PHASE 2 — Documentation technique (docs/06_SCD2/)

---

#### Étape 5 — `docs/06_SCD2/modelisation_SCD2.md`

- **Statut :** [x] Fait — 2026-03-12
- **Critère C17 :** Documentation modélisation
- **Contenu :**
  - Principe SCD2 (toutes versions conservées, surrogate key immuable)
  - Diagramme ERD Mermaid : dim_vendor, dim_product, fact_vendor_stock, fact_order
  - Tableau attributs trackés vs non trackés avec justification métier
  - Requête type historique complet avec `ISNULL(valid_to, 'en cours')`
- **Dépendances :** Étapes 1 à 4

---

#### Étape 6 — `docs/06_SCD2/adaptations_ETL.md`

- **Statut :** [x] Fait — 2026-03-12
- **Critère C17 :** Documentation ETL adapté
- **Contenu :**
  - Architecture avant/après C17 (schéma ASCII flux streaming + batch)
  - Flux existants inchangés (orders/clickstream/products via Stream Analytics)
  - Nouveaux flux batch : dim_vendor (quotidien via sp_merge_dim_vendor) + fact_vendor_stock (horaire INSERT)
  - Logique ETL dim_vendor avec arbre de décision des 3 cas MERGE
  - Séquence de déploiement C17 (4 commandes sqlcmd)
- **Justification jury :** Prouve que le candidat comprend pourquoi les vendeurs passent en batch (volume faible, logique MERGE incompatible avec Stream Analytics) et non en streaming.
- **Dépendances :** Étapes 1 à 4

---

### PHASE 3 — Synthèse rapport (docs_rapport/06_SCD2/)

---

#### Étape 7 — `docs_rapport/06_SCD2/resume_SCD2.md`

- **Statut :** [x] Fait — 2026-03-12
- **Critère C17 :** Couverture complète dans le livrable certifiant
- **Contenu :**
  - Contexte métier (pivot Marketplace, traçabilité contractuelle commission)
  - Modèle de données implémenté (3 tables)
  - Colonnes SCD2 avec rôle de chacune
  - Procédure MERGE — tableau des 3 cas
  - Critères C17 tous cochés [x]
  - Choix techniques justifiés (SCD2 vs SCD1, procédure stockée vs ADF, insert-only vs staging)
  - **Tests en conditions réelles 2026-03-12** : commandes sqlcmd + sorties + SCD2 timestamps exacts
- **Dépendances :** Étapes 1 à 6

---

## Suivi d'avancement

| # | Fichier | Statut | Critère |
|---|---------|--------|---------|
| 1 | `sql/scd2/dim_vendor_create.sql` | [x] | Modélisation SCD2 |
| 2 | `sql/scd2/dim_vendor_merge.sql` | [x] | Procédure MERGE SCD2 |
| 3 | `sql/scd2/fact_vendor_stock.sql` | [x] | Table de faits SCD2 |
| 4 | `sql/scd2/dim_product_update.sql` | [x] | Enrichissement dimension |
| 5 | `docs/06_SCD2/modelisation_SCD2.md` | [x] | Documentation modélisation |
| 6 | `docs/06_SCD2/adaptations_ETL.md` | [x] | Documentation ETL |
| 7 | `docs_rapport/06_SCD2/resume_SCD2.md` | [x] | C17 synthèse rapport |

---

## Points techniques notables (bugs résolus)

| Fichier | Problème | Solution |
|---------|----------|----------|
| `fact_vendor_stock.sql` | FK `product_id INT` incompatible avec `dim_product.product_id VARCHAR(50)` | Correction type → `VARCHAR(50)` (Faker génère des UUID) |
| `fact_vendor_stock.sql` | `CREATE OR ALTER VIEW` doit être premier statement du batch | Ajout `GO` avant la vue |
| `dim_product_update.sql` | `UPDATE` parsé avant `ALTER TABLE` dans le même batch | Ajout `GO` après `ALTER TABLE ADD vendor_id` |
| `dim_product_update.sql` | Index filtré `WHERE is_current=1` requiert `QUOTED_IDENTIFIER ON` | `SET QUOTED_IDENTIFIER ON; GO` avant `CREATE INDEX` |
| `dim_product_update.sql` | Deuxième exécution échoue sur `ALTER TABLE` (colonne existe) | `IF NOT EXISTS` sur le bloc ALTER — script idempotent |

---

## Résultat final C17 — 2026-03-12

| Artefact | Résultat test |
|----------|--------------|
| `dim_vendor` | 5 vendeurs actifs (4 init + V005 SCD2) |
| `sp_merge_dim_vendor` | V001 commission 12.50→14.00 : version fermée 12:40:56→12:41:48, nouvelle version active |
| `fact_vendor_stock` | 25 lignes, vue `vw_vendor_stock_disponible` opérationnelle |
| `dim_product` enrichi | 972 produits, 0 sans vendeur, distribution V001:587 / V002:195 / V003:190 |

---

## Résultat attendu en fin de Lot 2

- **7 fichiers** créés ou mis à jour
- **100 % des critères C17** couverts avec artefacts concrets et tests en conditions réelles
- **Architecture hybride** streaming (C16) + batch SCD2 (C17) documentée et déployée
