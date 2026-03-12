# Correspondance situations → compétences E6

## Matrice de couverture C16 / C17

| Situation professionnelle | Compétence | Artefacts |
|---------------------------|------------|-----------|
| Supervision & journalisation DWH | **C16** | `monitoring/queries/log_errors_last24h.sql`, `monitoring/queries/data_freshness.sql` |
| Alerting & SLA | **C16** | `monitoring/dashboards/alert_rules_spec.md`, `docs/05_socle_MCO/alerting_SLA.md` |
| Backup complet planifié | **C16** | `sql/backups/backup_full.sh` → BACPAC 2.4MB testé 2026-03-12 |
| Backup partiel / LTR | **C16** | `sql/backups/backup_ltr_config.sh` → P4W/P12M/P5Y |
| Restauration & DRP | **C16** | `sql/backups/restore_procedure.sh`, `docs/05_socle_MCO/backups_et_DRP.md` |
| Maintenance index & intégrité | **C16** | `sql/maintenance/check_integrity.sql` (score 75/100), `sql/maintenance/index_maintenance.sql` (99.9%→0.28%) |
| RGPD — registre traitements | **C16** | `security/rgpd/registre_traitements.md` (art. 30 — 3 traitements) |
| RGPD — procédures conformité | **C16** | `security/rgpd/procedures_conformite.md` |
| RBAC & contrôle d'accès | **C16** | `security/rbac/rbac_mapping.md` (5 rôles), `docs/07_securite/` |
| Processus MCO (RACI, P1/P2/P3) | **C16** | `docs/05_socle_MCO/processus_MCO.md` |
| Modélisation SCD Type 2 | **C17** | `sql/scd2/dim_vendor_create.sql`, `docs/06_SCD2/modelisation_SCD2.md` |
| Procédure MERGE SCD2 | **C17** | `sql/scd2/dim_vendor_merge.sql` + `sp_merge_dim_vendor` |
| Table de faits liée SCD2 | **C17** | `sql/scd2/fact_vendor_stock.sql` + vue `vw_vendor_stock_disponible` |
| Enrichissement dimension existante | **C17** | `sql/scd2/dim_product_update.sql` (vendor_id FK, 972 produits) |
| Documentation ETL adapté | **C17** | `docs/06_SCD2/adaptations_ETL.md` |

---

## Couverture par critère officiel C16

| Critère C16 | Statut | Artefact principal |
|-------------|--------|--------------------|
| Journalisation catégorisée (ALERTE/ATTENTION/OK) | ✓ | `monitoring/queries/log_errors_last24h.sql` |
| Système d'alerte activé | ✓ | `monitoring/dashboards/alert_rules_spec.md` |
| Tâches priorisées selon SLA (P1/P2/P3) | ✓ | `docs/05_socle_MCO/processus_MCO.md` |
| Tâches assignées (RACI) | ✓ | `docs/05_socle_MCO/processus_MCO.md` |
| Indicateurs basés sur SLA | ✓ | `monitoring/queries/sla_availability.sql` |
| Tableau de bord indicateurs | ✓ | `monitoring/dashboards/dashboard_sla_spec.md` |
| Backup complet planifié & fonctionnel | ✓ | `sql/backups/backup_full.sh` — testé 2026-03-12 |
| Backup partiel planifié & fonctionnel | ✓ | `sql/backups/backup_ltr_config.sh` — LTR P4W/P12M/P5Y |
| Documentation cas d'usage | ✓ | `docs/05_socle_MCO/` (6 fichiers) |
| Nouveaux accès configurés | ✓ | `security/rbac/rbac_mapping.md` |
| Registre RGPD complet | ✓ | `security/rgpd/registre_traitements.md` |
| Procédures tri données personnelles | ✓ | `security/rgpd/procedures_conformite.md` |
| Traitements conformité avec fréquence | ✓ | `security/rgpd/procedures_conformite.md` |

## Couverture par critère officiel C17

| Critère C17 | Statut | Artefact principal |
|-------------|--------|--------------------|
| Identification des attributs à variation lente | ✓ | `docs/06_SCD2/modelisation_SCD2.md` (tableau trackés/non trackés) |
| Choix du type SCD justifié | ✓ | SCD2 choisi vs SCD1 — traçabilité contractuelle commission |
| Implémentation avec surrogate key et dates | ✓ | `dim_vendor` : vendor_sk, valid_from, valid_to, is_current |
| Adaptation ETL | ✓ | `sp_merge_dim_vendor` — 3 cas MERGE documentés |
| Documentation modélisation | ✓ | `docs/06_SCD2/` — modélisation + ETL |
