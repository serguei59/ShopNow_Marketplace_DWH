# Automatisation des backups

## Scripts déployés

| Script | Type | Planification | Détail |
|--------|------|---------------|--------|
| `sql/backups/backup_full.sh` | BACPAC complet | Dimanche 02h00 | `az sql db export` → Blob Storage |
| `sql/backups/backup_ltr_config.sh` | LTR configuration | One-shot (idempotent) | P4W/P12M/P5Y |
| `sql/backups/restore_procedure.sh` | Restauration | Sur incident | PITR ou BACPAC import |

## backup_full.sh — fonctionnement

```bash
# Logique du script (résumé)
1. Vérifier/créer le storage account (stshopnowbackup)
2. Vérifier/créer le container (sql-backups)
3. Générer le nom du fichier : weekly/dwh-shopnow-YYYY-MM-DD.bacpac
4. Lancer az sql db export (BACPAC asynchrone)
5. Attendre la fin du job (polling status)
6. Logger le résultat
```

Test réel — 2026-03-12 :
```
→ weekly/dwh-shopnow-2026-03-12.bacpac
→ Taille : 2.4 MB
→ Durée : ~3 min
```

## backup_ltr_config.sh — politique configurée

```bash
az sql db ltr-policy set \
  --server sql-server-rg-e6-sbuasa \
  --database dwh-shopnow \
  --resource-group rg-e6-sbuasa \
  --weekly-retention P4W \
  --monthly-retention P12M \
  --yearly-retention P5Y \
  --week-of-year 1
```

## Planification recommandée (cron Linux ou Azure Automation)

```cron
# Backup BACPAC hebdo — dimanche 02h00
0 2 * * 0  /opt/scripts/backup_full.sh >> /var/log/backup.log 2>&1

# Vérification LTR mensuelle — 1er du mois 03h00
0 3 1 * *  /opt/scripts/backup_ltr_config.sh >> /var/log/ltr.log 2>&1
```

## Note sur Azure SQL Database vs SQL Managed Instance

> `BACKUP DATABASE TO DISK` n'est **pas supporté** sur Azure SQL Database.
> Le BACPAC via `az sql db export` est l'équivalent du backup complet portable
> et constitue le mécanisme recommandé par Microsoft pour ce tier.
