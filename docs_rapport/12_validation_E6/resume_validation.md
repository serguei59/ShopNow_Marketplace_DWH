# Validation E6 – C16 / C17

---

## Compétence C16 — MCO
✔ Monitoring  
✔ Alerts  
✔ Backups  
✔ Documentation  
✔ Intégration nouvelles sources  

## Compétence C17 — SCD
✔ DIM_VENDOR SCD2  
✔ Adaptation ETL  
✔ Nouvelle fact  
✔ Documentation variations  

## Couverture du brief Marketplace
✔ Suivi vendeur  
✔ Qualité données  
✔ Sécurité multi-tenant  
✔ Intégration API / fichiers / streaming  
✔ Cohérence analytique  

| Compétence | Situation / action | Artefact | Validation |
|------------|------------------|----------|-----------|
| C16 | Registre RGPD art. 30 | `security/rgpd/registre_traitements.md` | [x] Fait |
| C16 | Procédures conformité + fréquences | `security/rgpd/procedures_conformite.md` | [x] Fait |
| C16 | Matrice RBAC 5 rôles | `security/rbac/rbac_mapping.md` | [x] Fait |
| C16 | Journalisation catégorisée alertes/erreurs | `monitoring/queries/log_errors_last24h.sql` | [x] Fait |
| C16 | Système d'alerte activé | `monitoring/dashboards/alert_rules_spec.md` | [x] Fait |
| C16 | Indicateurs basés sur SLA | `monitoring/queries/sla_availability.sql` | [x] Fait |
| C16 | Tableau de bord indicateurs | `monitoring/dashboards/dashboard_sla_spec.md` | [x] Fait |
| C16 | Backup complet + partiel | `sql/backups/` | [ ] Phase 3 |
| C16 | Documentation MCO (runbooks, RACI) | `docs/` | [ ] Phase 4 |
| C17 | Modélisation SCD2, pipelines ETL | — | [ ] Lot 3 |
| C17 | Fact tables adaptées | — | [ ] Lot 3 |
| C17 | Documentation SCD2 | — | [ ] Lot 3 |
