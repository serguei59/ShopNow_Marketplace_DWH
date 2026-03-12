# Grille de validation C16 / C17

## C16 — Gérer l'entrepôt de données en conditions opérationnelles

| # | Critère jury | Implémentation | Statut |
|---|-------------|----------------|--------|
| C16.1 | Journalisation catégorisée alertes/erreurs | `sys.event_log` + `sys.dm_db_resource_stats` avec labels ALERTE/ATTENTION/OK | ✓ |
| C16.2 | Système d'alerte activé sur erreur journalisée | 6 règles Azure Monitor spec + Action Groups email | ✓ |
| C16.3 | Tâches priorisées selon objectifs | Matrice P1 (15 min) / P2 (1h) / P3 (4h) | ✓ |
| C16.4 | Tâches assignées (RACI) | RACI 4 acteurs par type incident | ✓ |
| C16.5 | Indicateurs basés sur SLA | Disponibilité ≥99.9% / Latence orders ≤5 min / clickstream ≤2 min | ✓ |
| C16.6 | Tableau de bord indicateurs | 6 tiles Power BI spec — CPU, DTU, latence, volume, SLA global | ✓ |
| C16.7 | Backup complet planifié & fonctionnel | BACPAC hebdo — testé 2026-03-12 — `weekly/dwh-shopnow-2026-03-12.bacpac` 2.4 MB | ✓ |
| C16.8 | Backup partiel planifié & fonctionnel | LTR : P4W/P12M/P5Y — `az sql db ltr-policy set` | ✓ |
| C16.9 | Documentation cas d'usage (sources, accès, stockage) | `docs/05_socle_MCO/` (6 fichiers) + `docs/07_securite/` | ✓ |
| C16.10 | Nouveaux accès configurés conformément | RBAC 5 rôles (Admin/DE/Steward/MCO/Vendor) + SQL permissions | ✓ |
| C16.11 | Registre RGPD art. 30 complet | 3 traitements documentés (commandes, clickstream, vendeurs) | ✓ |
| C16.12 | Procédures tri données personnelles | Purge clickstream J+13 mois, effacement art. 17, portabilité art. 20 | ✓ |
| C16.13 | Traitements conformité avec fréquence | Purge mensuelle, audit trimestriel, revue annuelle registre | ✓ |

**Score C16 : 13/13 critères couverts**

---

## C17 — Implémenter les Slowly Changing Dimensions

| # | Critère jury | Implémentation | Statut |
|---|-------------|----------------|--------|
| C17.1 | Identifier les attributs à variation lente | `commission_rate`, `status`, `country`, `region`, `vendor_name` trackés — `vendor_email` non tracké | ✓ |
| C17.2 | Choisir le type SCD adapté et le justifier | SCD2 choisi vs SCD1 — traçabilité contractuelle commission requise | ✓ |
| C17.3 | Implémenter avec surrogate key et dates validité | `vendor_sk` (IDENTITY immuable), `valid_from`, `valid_to` (NULL=courant), `is_current` (BIT) | ✓ |
| C17.4 | Adapter l'ETL pour gérer les 3 cas SCD2 | `sp_merge_dim_vendor` — INSERT / UPDATE+INSERT / UPDATE direct | ✓ |
| C17.5 | Documenter la modélisation et l'ETL | `docs/06_SCD2/modelisation_SCD2.md` + `docs/06_SCD2/adaptations_ETL.md` | ✓ |

**Score C17 : 5/5 critères couverts**

---

## Preuves disponibles pour le jury

| Type de preuve | Disponible | Détail |
|----------------|------------|--------|
| Scripts SQL exécutables | ✓ | `sql/scd2/`, `sql/maintenance/`, `sql/backups/` |
| Sorties de tests réelles | ✓ | `docs_rapport/05_socle_MCO/resume_socle_MCO.md` + `docs_rapport/06_SCD2/resume_SCD2.md` |
| Timestamps de déploiement | ✓ | 2026-03-12 — dim_vendor, fact_vendor_stock, dim_product enrichi |
| SCD2 en action | ✓ | V001 commission 12.50→14.00 avec valid_from/valid_to documentés |
| Backup testé | ✓ | BACPAC 2.4 MB — `weekly/dwh-shopnow-2026-03-12.bacpac` |
| Index maintenance | ✓ | fact_clickstream 99.9%→0.28% REBUILD ONLINE |
| Intégrité données | ✓ | Score 75/100, unit_price NULL 3004 lignes identifié |
