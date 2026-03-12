# sql/ — Scripts SQL et shell DWH ShopNow

Ce dossier contient tous les scripts de maintenance, backup et restauration
pour la base Azure SQL Database `dwh-shopnow` (SKU S0, francecentral).

---

## Structure

sql/
├── backups/
│   ├── backup_schedule.md       # Planning PITR / BACPAC / LTR — RPO/RTO
│   ├── backup_full.sh           # Export BACPAC hebdomadaire vers Blob Storage
│   ├── backup_ltr_config.sh     # Configuration Long-Term Retention (backup partiel)
│   └── restore_procedure.sh     # Restauration PITR ou BACPAC (2 scénarios)
└── maintenance/
├── check_integrity.sql      # Contrôle cohérence : orphelins, nulls, score 0-100
└── index_maintenance.sql    # Fragmentation index : REORGANIZE / REBUILD / UPDATE STATS


---

## Spécificités Azure SQL Database S0

| Limitation | Alternative utilisée |
|------------|---------------------|
| `BACKUP DATABASE TO DISK` non disponible | `az sql db export` (BACPAC) |
| `RESTORE DATABASE` non disponible | `az sql db restore` (PITR) ou `az sql db import` |
| Pas de SQL Agent | Planification externe (cron / Azure Automation) |
| REBUILD index OFFLINE non supporté | `REBUILD WITH (ONLINE = ON)` |

---

## Planning de maintenance

| Fréquence | Action | Script |
|-----------|--------|--------|
| Hebdomadaire (lundi) | Contrôle intégrité | `maintenance/check_integrity.sql` |
| Hebdomadaire (mercredi) | Maintenance index | `maintenance/index_maintenance.sql` |
| Hebdomadaire (dim. 02h00) | Backup BACPAC complet | `backups/backup_full.sh` |
| Mensuel | Vérification LTR | `backups/backup_ltr_config.sh` |

---

## Critères C16 couverts

| Critère | Script |
|---------|--------|
| Backup complet planifié et fonctionnel | `backups/backup_full.sh` |
| Backup partiel planifié et fonctionnel | `backups/backup_ltr_config.sh` |
| Tâches de maintenance priorisées | `maintenance/check_integrity.sql` |
| Performance et fragmentation index | `maintenance/index_maintenance.sql` |

