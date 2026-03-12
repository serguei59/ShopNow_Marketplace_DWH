# Scénarios de restauration

> Voir aussi : [docs/05_socle_MCO/backups_et_DRP.md](../05_socle_MCO/backups_et_DRP.md)

## Scénario 1 — Suppression accidentelle de données (< 35 jours)

**Mécanisme :** PITR (Point-In-Time Restore)

```bash
az sql db restore \
  --dest-name dwh-shopnow-restored \
  --edition Standard --service-objective S0 \
  --name dwh-shopnow \
  --resource-group rg-e6-sbuasa \
  --server sql-server-rg-e6-sbuasa \
  --time "2026-03-12T11:00:00Z"
# Puis valider les données, renommer, rebrancher les connexions
```

**RPO :** < 15 min | **RTO :** 30-60 min

---

## Scénario 2 — Corruption logique de la base

**Mécanisme :** PITR vers le dernier point sain identifié

1. Identifier le timestamp de la dernière donnée cohérente via `check_integrity.sql`
2. Restaurer via PITR
3. Reprocesser les événements Event Hubs perdus (rétention 1 jour)

**RPO :** < 15 min | **RTO :** 1-2h

---

## Scénario 3 — Migration ou clonage d'environnement

**Mécanisme :** BACPAC import

```bash
az sql db import \
  --admin-password '***' \
  --admin-user sqladmin \
  --storage-key-type StorageAccessKey \
  --storage-key $STORAGE_KEY \
  --storage-uri "https://stshopnowbackup.blob.core.windows.net/sql-backups/weekly/dwh-shopnow-2026-03-12.bacpac" \
  --name dwh-shopnow-dev \
  --resource-group rg-e6-sbuasa \
  --server sql-server-rg-e6-sbuasa
```

**RTO :** 45-90 min

---

## Scénario 4 — Perte complète de région Azure

**Mécanisme :** LTR + recréation infrastructure Terraform

```bash
# 1. Recréer l'infrastructure dans une nouvelle région
terraform apply -var="location=westeurope"

# 2. Importer le dernier backup LTR disponible
az sql db ltr-backup restore \
  --backup-id "/subscriptions/.../ltrBackups/..." \
  --dest-database dwh-shopnow \
  --dest-resource-group rg-e6-sbuasa-west \
  --dest-server sql-server-rg-e6-sbuasa-west \
  --edition Standard --service-objective S0
```

**RPO :** Dernier backup LTR (max 7 jours) | **RTO :** < 4h

---

## Tableau de décision

| Incident | Ancienneté | Mécanisme recommandé |
|----------|------------|---------------------|
| Suppression accidentelle | < 35 jours | PITR |
| Corruption | < 35 jours | PITR |
| Migration dev/prod | N/A | BACPAC import |
| Perte région | N/A | LTR + Terraform |
| Audit historique | > 35 jours | LTR (P12M ou P5Y) |
