#!/usr/bin/env bash
# =============================================================
# backup_full.sh — Backup complet BACPAC vers Azure Blob Storage
# Projet   : DWH ShopNow Marketplace
# Critère  : C16 — Backup complet planifié et configuré
# Schedule : Dimanche 02h00 UTC (voir backup_schedule.md)
# =============================================================

set -euo pipefail

# ------------------------------------------------------------
# Variables — à surcharger via variables d'environnement CI/CD
# ------------------------------------------------------------
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-e6-sbuasa}"
SERVER_NAME="${SERVER_NAME:-sql-server-rg-e6-sbuasa}"
DB_NAME="${DB_NAME:-dwh-shopnow}"
STORAGE_ACCOUNT="${STORAGE_ACCOUNT:-stshopnowbackup}"
CONTAINER_NAME="${CONTAINER_NAME:-sql-backups}"
ADMIN_LOGIN="${SQL_ADMIN_LOGIN:-sqladmin}"
ADMIN_PASSWORD="${SQL_ADMIN_PASSWORD:?Erreur : SQL_ADMIN_PASSWORD non défini}"
STORAGE_KEY="${STORAGE_KEY:?Erreur : STORAGE_KEY non défini}"
NOTIFICATION_EMAIL="${NOTIFICATION_EMAIL:-dataeng@shopnow.fr}"

DATE=$(date -u +%Y-%m-%d)
BACPAC_FILENAME="dwh-shopnow-${DATE}.bacpac"
STORAGE_URI="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/weekly/${BACPAC_FILENAME}"
LOG_FILE="/tmp/backup_${DATE}.log"

# ------------------------------------------------------------
# Fonctions
# ------------------------------------------------------------
log() { echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $*" | tee -a "${LOG_FILE}"; }

notify_failure() {
    log "ECHEC — Envoi notification à ${NOTIFICATION_EMAIL}"
    # Remplacer par az communication send ou sendmail selon l'environnement
    echo "BACKUP ECHEC — ${DB_NAME} — ${DATE}" | mail -s "[ALERTE] Backup DWH échoué" "${NOTIFICATION_EMAIL}" 2>/dev/null || true
}

# ------------------------------------------------------------
# 1. Vérification connexion Azure
# ------------------------------------------------------------
log "INFO — Vérification connexion Azure CLI"
az account show --query "id" -o tsv || { log "ERREUR — Non connecté à Azure"; notify_failure; exit 1; }

# ------------------------------------------------------------
# 2. Lancement export BACPAC
# ------------------------------------------------------------
log "INFO — Démarrage export BACPAC : ${DB_NAME} → ${STORAGE_URI}"

OPERATION_ID=$(az sql db export \
  --resource-group "${RESOURCE_GROUP}" \
  --server          "${SERVER_NAME}" \
  --name            "${DB_NAME}" \
  --admin-user      "${ADMIN_LOGIN}" \
  --admin-password  "${ADMIN_PASSWORD}" \
  --storage-key     "${STORAGE_KEY}" \
  --storage-key-type StorageAccessKey \
  --storage-uri     "${STORAGE_URI}" \
  --query "name" -o tsv) || { log "ERREUR — az sql db export a échoué"; notify_failure; exit 1; }

log "INFO — Export lancé, opération : ${OPERATION_ID}"

# ------------------------------------------------------------
# 3. Attente fin d'opération (polling toutes les 60s, max 60 min)
# ------------------------------------------------------------
MAX_WAIT=3600
ELAPSED=0
INTERVAL=60

while [ "${ELAPSED}" -lt "${MAX_WAIT}" ]; do
    STATUS=$(az sql db operation list \
      --resource-group "${RESOURCE_GROUP}" \
      --server "${SERVER_NAME}" \
      --database "${DB_NAME}" \
      --query "[?name=='${OPERATION_ID}'].state" -o tsv 2>/dev/null || echo "Unknown")

    log "INFO — Statut export : ${STATUS} (${ELAPSED}s écoulées)"

    if [ "${STATUS}" = "Succeeded" ]; then
        log "OK — Export BACPAC terminé avec succès : ${BACPAC_FILENAME}"
        break
    elif [ "${STATUS}" = "Failed" ] || [ "${STATUS}" = "Cancelled" ]; then
        log "ERREUR — Export BACPAC échoué (statut : ${STATUS})"
        notify_failure
        exit 1
    fi

    sleep "${INTERVAL}"
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [ "${ELAPSED}" -ge "${MAX_WAIT}" ]; then
    log "ERREUR — Timeout export BACPAC après ${MAX_WAIT}s"
    notify_failure
    exit 1
fi

# ------------------------------------------------------------
# 4. Vérification présence du fichier dans Blob Storage
# ------------------------------------------------------------
log "INFO — Vérification présence BACPAC dans Blob Storage"
az storage blob show \
  --account-name "${STORAGE_ACCOUNT}" \
  --container-name "${CONTAINER_NAME}" \
  --name "weekly/${BACPAC_FILENAME}" \
  --account-key "${STORAGE_KEY}" \
  --query "properties.contentLength" -o tsv \
  | xargs -I{} log "OK — Taille BACPAC : {} octets"

log "INFO — Backup complet terminé : ${BACPAC_FILENAME}"
log "INFO — Log complet : ${LOG_FILE}"

# ------------------------------------------------------------
# 5. Nettoyage des BACPAC > 12 mois
# ------------------------------------------------------------
log "INFO — Nettoyage BACPAC de plus de 12 mois"
CUTOFF_DATE=$(date -u -d "12 months ago" +%Y-%m-%d 2>/dev/null || date -u -v-12m +%Y-%m-%d)

az storage blob list \
  --account-name "${STORAGE_ACCOUNT}" \
  --container-name "${CONTAINER_NAME}" \
  --prefix "weekly/" \
  --account-key "${STORAGE_KEY}" \
  --query "[].name" -o tsv | while read -r blob; do
    BLOB_DATE=$(echo "${blob}" | grep -oP '\d{4}-\d{2}-\d{2}' || true)
    if [ -n "${BLOB_DATE}" ] && [ "${BLOB_DATE}" \< "${CUTOFF_DATE}" ]; then
        log "INFO — Suppression ancien BACPAC : ${blob}"
        az storage blob delete \
          --account-name "${STORAGE_ACCOUNT}" \
          --container-name "${CONTAINER_NAME}" \
          --name "${blob}" \
          --account-key "${STORAGE_KEY}"
    fi
done

log "INFO — Script backup_full.sh terminé avec succès"
exit 0
