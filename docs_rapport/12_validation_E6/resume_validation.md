# Validation E6 — C16 / C17

---

## Compétence C16 — Gérer l'entrepôt de données (MCO)

| Critère | Artefact | Validation |
|---------|----------|-----------|
| Registre RGPD art. 30 | [`security/rgpd/registre_traitements.md`](../../security/rgpd/registre_traitements.md) | [x] Fait |
| Procédures conformité + fréquences | [`security/rgpd/procedures_conformite.md`](../../security/rgpd/procedures_conformite.md) | [x] Fait |
| Matrice RBAC 5 rôles | [`security/rbac/rbac_mapping.md`](../../security/rbac/rbac_mapping.md) | [x] Fait |
| Journalisation catégorisée alertes/erreurs | [`monitoring/queries/log_errors_last24h.sql`](../../monitoring/queries/log_errors_last24h.sql) | [x] Fait |
| Système d'alerte activé | [`monitoring/dashboards/alert_rules_spec.md`](../../monitoring/dashboards/alert_rules_spec.md) | [x] Fait |
| Indicateurs basés sur SLA | [`monitoring/queries/sla_availability.sql`](../../monitoring/queries/sla_availability.sql) | [x] Fait |
| Tableau de bord indicateurs | [`monitoring/dashboards/dashboard_sla_spec.md`](../../monitoring/dashboards/dashboard_sla_spec.md) | [x] Fait |
| Backup complet planifié & fonctionnel | [`sql/backups/backup_full.sh`](../../sql/backups/backup_full.sh) — BACPAC 2.4MB testé 2026-03-12 | [x] Fait |
| Backup partiel planifié & fonctionnel | [`sql/backups/backup_ltr_config.sh`](../../sql/backups/backup_ltr_config.sh) — P4W/P12M/P5Y | [x] Fait |
| Tâches priorisées selon SLA (P1/P2/P3) | [`docs/05_socle_MCO/processus_MCO.md`](../../docs/05_socle_MCO/processus_MCO.md) | [x] Fait |
| Tâches assignées RACI | [`docs/05_socle_MCO/processus_MCO.md`](../../docs/05_socle_MCO/processus_MCO.md) | [x] Fait |
| Maintenance index & intégrité | [`sql/maintenance/`](../../sql/maintenance/) — 99.9%→0.28% testé | [x] Fait |
| Documentation cas d'usage | [`docs/05_socle_MCO/`](../../docs/05_socle_MCO/) (6 fichiers) | [x] Fait |

**Score C16 : 13/13 — 100%**

---

## Compétence C17 — Implémenter les SCD

| Critère | Artefact | Validation |
|---------|----------|-----------|
| Modélisation SCD2 `dim_vendor` | [`sql/scd2/dim_vendor_create.sql`](../../sql/scd2/dim_vendor_create.sql) | [x] Fait |
| Procédure MERGE SCD2 (3 cas) | [`sql/scd2/dim_vendor_merge.sql`](../../sql/scd2/dim_vendor_merge.sql) + `sp_merge_dim_vendor` | [x] Fait |
| Nouvelle fact `fact_vendor_stock` | [`sql/scd2/fact_vendor_stock.sql`](../../sql/scd2/fact_vendor_stock.sql) + vue | [x] Fait |
| Enrichissement `dim_product` | [`sql/scd2/dim_product_update.sql`](../../sql/scd2/dim_product_update.sql) — 972 produits | [x] Fait |
| Adaptation ETL documentée | [`docs/06_SCD2/adaptations_ETL.md`](../../docs/06_SCD2/adaptations_ETL.md) | [x] Fait |
| Documentation modélisation | [`docs/06_SCD2/modelisation_SCD2.md`](../../docs/06_SCD2/modelisation_SCD2.md) | [x] Fait |

**Score C17 : 6/6 — 100%**

---

## Preuves tests en conditions réelles — 2026-03-12

| Preuve | Résultat |
|--------|---------|
| BACPAC exporté | `weekly/dwh-shopnow-2026-03-12.bacpac` — 2.4 MB |
| LTR configuré | P4W / P12M / P5Y → OK |
| check_integrity.sql | Score 75/100 — unit_price NULL 3004 lignes détecté |
| index_maintenance.sql | fact_clickstream 99.9% → 0.28% REBUILD ONLINE |
| dim_vendor SCD2 | V001 commission 12.50→14.00 — version fermée + nouvelle active |
| fact_vendor_stock | 25 lignes — 5 vendeurs × 5 produits |
| dim_product enrichi | 972 produits — 0 sans vendeur |

---

## Couverture du brief Marketplace

| Exigence brief | Couverture | Artefact |
|----------------|------------|---------|
| Suivi historique vendeurs | SCD2 `dim_vendor` | `sql/scd2/` |
| Qualité données | `check_integrity.sql` score 75/100 | `sql/maintenance/` |
| Sécurité multi-tenant | RBAC 5 rôles + vues filtrées | `security/` |
| Ingestion streaming | Event Hubs + Stream Analytics | `docs/10_pipelines/` |
| Cohérence analytique | Vue `vw_vendor_stock_disponible` | `sql/scd2/fact_vendor_stock.sql` |
| Résilience DRP | PITR + BACPAC + LTR | `sql/backups/` |
