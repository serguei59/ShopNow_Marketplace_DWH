# Plan DRP — Sauvegardes et restauration

---

## Stratégie de sauvegarde implémentée

| Mécanisme | Fréquence | Rétention | Script |
|-----------|-----------|-----------|--------|
| PITR natif Azure SQL | Continu (5-12 min) | 35 jours | Automatique Azure |
| BACPAC complet | Hebdo — dim. 02h00 | 12 mois | [`sql/backups/backup_full.sh`](../../sql/backups/backup_full.sh) |
| LTR (Long-Term Retention) | P4W / P12M / P5Y | 5 ans | [`sql/backups/backup_ltr_config.sh`](../../sql/backups/backup_ltr_config.sh) |

**RPO cible : < 15 minutes — RTO cible : < 2 heures**

---

## Scénarios couverts

| Scénario | Mécanisme | RTO estimé | Statut |
|----------|-----------|------------|--------|
| Suppression accidentelle de lignes (< 35j) | PITR — `az sql db restore` | 30-60 min | [x] Fait |
| Corruption logique récente | PITR — point précis avant incident | 30-60 min | [x] Fait |
| Restauration inter-environnement | BACPAC — `az sql db import` | 45-90 min | [x] Fait |
| Perte région Azure complète | LTR + `terraform apply` nouvelle région | < 4h | [x] Documenté |

---

## Tests réalisés — 2026-03-12

| Test | Résultat | Artefact |
|------|----------|---------|
| LTR policy configurée | P4W/P12M/P5Y → **OK** | `backup_ltr_config.sh` |
| BACPAC exporté | `weekly/dwh-shopnow-2026-03-12.bacpac` **2.4 MB** → **OK** | `backup_full.sh` |
| PITR disponible | 35 jours de rétention confirmés → **OK** | Azure Portal |

---

## Note architecture

> Azure SQL Database S0 ne supporte pas `BACKUP DATABASE TO DISK`.
> Le BACPAC via `az sql db export` est l'équivalent du backup complet portable
> recommandé par Microsoft pour ce tier.

Voir procédure complète : [`sql/backups/restore_procedure.sh`](../../sql/backups/restore_procedure.sh)
