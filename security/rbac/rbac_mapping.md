# Matrice RBAC — DWH ShopNow Marketplace

**Projet :** DWH ShopNow Marketplace
**Date de mise à jour :** 2026-03-11
**Référence :** C16 — Nouveaux accès configurés conformément au besoin

---

## Rôles définis

| Rôle | Profil | Responsabilités |
|------|--------|-----------------|
| **Admin** | Responsable infrastructure data | Gestion complète des ressources Azure et du DWH |
| **Data Engineer** | Ingénieur data | Développement, déploiement des pipelines, maintenance |
| **Data Steward** | Référent qualité/conformité | Gouvernance des données, traitements RGPD, audits |
| **MCO** | Opérateur maintenance | Supervision, alertes, backups, runbooks |
| **Vendeur** | Partenaire tiers (Marketplace) | Accès en lecture à ses propres données uniquement |

---

## Matrice des droits Azure RBAC

| Rôle | Azure Role | Périmètre | MFA requis |
|------|-----------|-----------|-----------|
| Admin | Owner | Resource Group `rg-e6-sbuasa` | Oui |
| Data Engineer | Contributor | Resource Group `rg-e6-sbuasa` | Oui |
| Data Steward | Reader | Resource Group `rg-e6-sbuasa` | Oui |
| MCO | Reader + rôle custom monitoring | Resource Group `rg-e6-sbuasa` | Oui |
| Vendeur | Aucun accès Azure direct | — | — |

---

## Matrice des droits SQL (Azure SQL Database `dwh-shopnow`)

| Rôle | Permission SQL | Tables accessibles | Restrictions |
|------|---------------|-------------------|-------------|
| Admin | `db_owner` | Toutes | Aucune |
| Data Engineer | `db_datareader` + `db_datawriter` | Toutes | Pas de DROP/TRUNCATE en prod |
| Data Steward | `db_datareader` | Toutes | Lecture seule, pas d'export en masse |
| MCO | `db_datareader` | `sys.dm_db_resource_stats`, `sys.event_log` | Vues système uniquement |
| Vendeur | SELECT sur vue filtrée | `v_vendor_orders` (vue à créer — C17) | Filtré sur `vendor_id` |

---

## Détail des permissions par table

| Table | Admin | Data Engineer | Data Steward | MCO | Vendeur |
|-------|-------|---------------|-------------|-----|---------|
| `dim_customer` | CRUD | CRUD | SELECT | — | — |
| `dim_product` | CRUD | CRUD | SELECT | — | SELECT (ses produits) |
| `fact_order` | CRUD | CRUD | SELECT | — | SELECT (ses commandes) |
| `fact_clickstream` | CRUD | CRUD | SELECT | — | — |
| `dim_vendor` (C17) | CRUD | CRUD | SELECT | — | SELECT (son profil) |
| Vues système | SELECT | SELECT | — | SELECT | — |

---

## Script de création d'un accès vendeur (exemple)

```sql
-- Création du login SQL pour un vendeur
CREATE LOGIN vendor_v001 WITH PASSWORD = '<mot_de_passe_fort>';

-- Création de l'utilisateur dans la base dwh-shopnow
USE [dwh-shopnow];
CREATE USER vendor_v001 FOR LOGIN vendor_v001;

-- Attribution du rôle restreint
EXEC sp_addrolemember 'db_datareader', 'vendor_v001';

-- Restriction à la vue filtrée (après création de la vue en C17)
-- GRANT SELECT ON dbo.v_vendor_orders TO vendor_v001;
-- DENY SELECT ON dbo.dim_customer TO vendor_v001;
-- DENY SELECT ON dbo.fact_clickstream TO vendor_v001;

---

## Procédure de création d'un nouvel accès

1. Demande formalisée par le responsable métier (ticket)
2. Validation par le Data Steward (vérification RGPD — accès au strict nécessaire)
3. Création du login SQL par le Data Engineer
4. Attribution du rôle approprié selon cette matrice
5. Notification à l'utilisateur avec procédure de premier login
6. Mise à jour du présent document

---

## Révision

| Fréquence | Action |
|-----------|--------|
| Trimestrielle | Revue des accès actifs — suppression des comptes inactifs |
| À chaque départ | Désactivation immédiate du compte SQL et Azure |
| À chaque nouvel accès | Mise à jour de la matrice |

