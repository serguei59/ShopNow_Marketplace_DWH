# Limites et risques identifiés

## Limites fonctionnelles

| Limite | Description | Réponse C16/C17 |
|--------|-------------|-----------------|
| Pas d'historique vendeurs | Impossible de retracer l'évolution des commissions | SCD2 `dim_vendor` (C17) |
| Pas de suivi des stocks | Aucune visibilité sur la disponibilité produit par vendeur | `fact_vendor_stock` (C17) |
| Qualité données non mesurée | `unit_price` NULL sur 3004 lignes non détecté avant C16 | `check_integrity.sql` score 75/100 |
| Pas de SLA formalisé | Impossible de savoir si le pipeline est en retard | `sla_availability.sql` + alertes |

## Limites techniques

| Limite | Description | Réponse C16/C17 |
|--------|-------------|-----------------|
| Azure SQL S0 — 10 DTU | Limite basse pour charge croissante | Dimensionnement justifié MVP, seuils documentés |
| Pas de backup automatisé | PITR natif actif mais non planifié, pas de BACPAC | `backup_full.sh` + `backup_ltr_config.sh` |
| Fragmentation index 99.9% | `fact_clickstream` dégradée — impact performance requêtes | `index_maintenance.sql` → 0.28% |
| Firewall ouvert 0.0.0.0–255.255.255.255 | Toutes les IPs autorisées sur le SQL Server | Documenté comme risque dans `gestion_identites.md` |

## Risques identifiés

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Pipeline arrêté non détecté | Moyenne | Fort | `data_freshness.sql` alerte silence >15 min |
| Perte données corruption | Faible | Critique | PITR 35j + BACPAC hebdo + LTR 5 ans |
| Non-conformité RGPD | Moyenne | Légal | Registre art.30 + procédures purge clickstream |
| Accès non autorisé données vendeur | Faible | Fort | RBAC 5 rôles + vues filtrées SQL |
| Dégradation performance requêtes | Haute | Moyen | Index maintenance hebdo (fragmentation détectée) |
| Dérive qualité données | Haute | Moyen | `check_integrity.sql` — score 75/100 suivi |
