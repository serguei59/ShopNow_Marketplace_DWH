# Plan de continuité d'activité — DWH ShopNow

> Ce document est un résumé du DRP. Voir la documentation complète :
> [docs/05_socle_MCO/backups_et_DRP.md](../05_socle_MCO/backups_et_DRP.md)

## Objectifs SLA

| Indicateur | Cible | Base |
|------------|-------|------|
| **RPO** (Recovery Point Objective) | < 15 minutes | PITR Azure SQL toutes les 5-12 min |
| **RTO** (Recovery Time Objective) | < 2 heures | Restauration PITR depuis CLI |
| Disponibilité mensuelle | ≥ 99,9 % | SLA Azure SQL Database Standard |

## Stratégie de sauvegarde

| Type | Fréquence | Rétention | Mécanisme |
|------|-----------|-----------|-----------|
| PITR (continu) | Automatique Azure | 35 jours | Natif Azure SQL |
| BACPAC (complet) | Hebdo — dim. 02h00 | 12 mois | `sql/backups/backup_full.sh` |
| LTR (long terme) | Hebdo/mensuel/annuel | 5 ans | `sql/backups/backup_ltr_config.sh` |

## Processus d'activation DRP

```
1. Détection incident (Azure Monitor alerte ou signalement MCO)
       ↓
2. Qualification gravité (P1 = pipeline arrêté / P2 = dégradation / P3 = mineur)
       ↓
3. Si P1 : activation DRP
   - Identifier le point de restauration PITR optimal
   - az sql db restore → base temporaire
   - Validation données restaurées
   - Bascule connexion application
       ↓
4. Reprocess des événements manquants (Event Hubs retention 1 jour)
       ↓
5. Clôture incident + rapport post-mortem
```

## Responsabilités

| Rôle | Action DRP |
|------|-----------|
| MCO | Détection + qualification |
| Data Engineer | Exécution restauration |
| Admin | Validation + communication |
