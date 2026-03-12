# Backups & Plan de Reprise d'Activité (DRP)

**Implémentation :** voir [`sql/backups/`](../../sql/backups/)

## Architecture de sauvegarde

Azure SQL Database S0 ne supporte pas `BACKUP DATABASE TO DISK`.
Trois mécanismes complémentaires sont mis en œuvre :

| Mécanisme | Type | Fréquence | Rétention | Script |
|-----------|------|-----------|-----------|--------|
| PITR (Point-In-Time Restore) | Natif Azure | Toutes les 5–12 min | 35 jours | Automatique |
| BACPAC export | Backup complet | Hebdomadaire (dim. 02h00) | 12 mois | [`backup_full.sh`](../../sql/backups/backup_full.sh) |
| LTR (Long-Term Retention) | Backup partiel | Hebdo/mensuel/annuel | 5 ans | [`backup_ltr_config.sh`](../../sql/backups/backup_ltr_config.sh) |

Planning complet : [`backup_schedule.md`](../../sql/backups/backup_schedule.md)

## Objectifs RPO / RTO

| Objectif | Valeur | Mécanisme |
|----------|--------|-----------|
| RPO (perte de données max) | < 15 min | PITR (snapshot toutes les 5–12 min) |
| RTO (durée de restauration max) | < 2 h | PITR ou import BACPAC |

## Scénarios de restauration

### Scénario 1 — Suppression accidentelle / corruption récente
Utiliser PITR : restauration à un point précis dans les 35 derniers jours.

```bash
SCENARIO=pitr RESTORE_TIME="2026-03-10T14:30:00Z" bash sql/backups/restore_procedure.sh
```

### Scénario 2 — Perte région / sinistre majeur
Importer le dernier BACPAC depuis le Blob Storage vers une nouvelle instance Azure SQL.

```bash
SCENARIO=bacpac BACPAC_URI="https://..." bash sql/backups/restore_procedure.sh
```

Procédure complète : [`restore_procedure.sh`](../../sql/backups/restore_procedure.sh)

## Conformité RGPD

- BACPAC chiffrés au repos (Azure Storage encryption)
- Purge automatique des BACPAC > 12 mois dans `backup_full.sh`
- Données PII (`dim_customer`, `fact_clickstream`) couvertes par les sauvegardes
