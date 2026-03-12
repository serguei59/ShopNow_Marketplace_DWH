# Planning des sauvegardes — DWH ShopNow Marketplace

**Projet :** DWH ShopNow Marketplace
**Critère C16 :** Backup complet et partiel planifiés et configurés
**Date :** 2026-03-12
**Responsable :** Data Engineer (voir `security/rbac/rbac_mapping.md`)

---

## Architecture de sauvegarde Azure SQL

Azure SQL Database S0 propose trois niveaux de sauvegarde natifs :

| Type | Mécanisme | Fréquence native | Rétention |
|------|-----------|-----------------|-----------|
| **PITR** (Point-In-Time Restore) | Automatique Azure | Toutes les 5-12 min | 35 jours |
| **BACPAC** (backup complet portable) | `az sql db export` → Blob Storage | Hebdomadaire (planifié) | 12 mois |
| **LTR** (Long-Term Retention) | `az sql db ltr-policy set` | Mensuel / Annuel | 5 ans |

---

## RPO / RTO cibles

| Scénario | RPO cible | RTO cible | Mécanisme |
|----------|-----------|-----------|-----------|
| Corruption logique récente (< 35j) | < 15 min | < 2h | PITR natif Azure |
| Suppression accidentelle table | < 15 min | < 2h | PITR natif Azure |
| Perte de données > 35j | < 1 semaine | < 4h | BACPAC hebdo |
| Obligation légale (RGPD 10 ans) | < 1 mois | < 8h | LTR annuel |

---

## Planning des sauvegardes

| Type | Déclencheur | Heure | Stockage cible | Rétention |
|------|-------------|-------|---------------|-----------|
| PITR | Automatique Azure (continu) | — | Géré par Azure | 35 jours |
| BACPAC complet | Hebdomadaire — dimanche | 02h00 UTC | `stshopnowbackup/sql-backups/weekly/` | 12 mois |
| LTR mensuel | 1er du mois | 03h00 UTC | Géré par Azure LTR | 4 semaines |
| LTR annuel | 1er janvier | 03h00 UTC | Géré par Azure LTR | 5 ans |

---

## Stockage cible (BACPAC)

Azure Blob Storage
Compte      : stshopnowbackup
Container   : sql-backups
Structure   : sql-backups/
weekly/dwh-shopnow-YYYY-MM-DD.bacpac
monthly/dwh-shopnow-YYYY-MM.bacpac


---

## Conformité RGPD

| Table | Durée conservation | Couverture backup |
|-------|-------------------|-------------------|
| `dim_customer` | 10 ans (obligation comptable) | LTR annuel 5 ans + rotation |
| `fact_order` | 10 ans (obligation comptable) | LTR annuel 5 ans + rotation |
| `fact_clickstream` | 13 mois (CNIL) | PITR 35j + BACPAC 12 mois |
| `dim_product` | Durée activité | BACPAC hebdo |

> La purge mensuelle de `fact_clickstream` (procédure RGPD) est distincte du backup —
> les backups LTR conservent les données historiques pour obligation légale comptable.

---

## Responsabilités

| Tâche | Responsable | Fréquence |
|-------|-------------|-----------|
| Exécution BACPAC hebdo | Data Engineer | Hebdomadaire (automatisé) |
| Vérification LTR | Data Engineer | Mensuelle |
| Test de restauration | Data Engineer + MCO | Trimestrielle |
| Revue du planning | MCO | Annuelle |
