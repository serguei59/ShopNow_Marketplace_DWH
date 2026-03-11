#!/usr/bin/env bash
# =============================================================
# restore_procedure.sh — Procédures de restauration
# Projet   : DWH ShopNow Marketplace
# Critère  : C16 — Les tâches planifiées produisent les résultats attendus
# Scénario 1 : PITR (corruption/suppression récente ≤ 35j)
# Scénario 2 : Restauration depuis BACPAC (inter-env ou > 35j)
# =============================================================

set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-e6-sbuasa}"
SERVER_NAME="${SERVER_NAME:-sql-server-rg-e6-sbuasa}"
DB_NAME="${DB_NAME:-dwh-shopnow}"
STORAGE_ACCOUNT="${STORAGE_ACCOUNT:-stshopnowbackup}"
STORAGE_KEY="${STORAGE_KEY:?Erreur : STORAGE_KEY non défini}"
ADMIN_LOGIN="${SQL_ADMIN_LOGIN:-sqladmin}"
ADMIN_PASSWORD="${SQL_ADMIN_PASSWORD:?Erreur : SQL_ADMIN_PASSWORD non défini}"

LOG_FILE="/tmp/restore_$(date -u +%Y-%m-%d_%H%M%S).log"
log() { echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $*" | tee -a "${LOG_FILE}"; }

# ------------------------------------------------------------
# SCÉNARIO 1 — PITR (Point-In-Time Restore)
# Usage : SCENARIO=pitr RESTORE_POINT="2026-03-11T02:00:00Z" bash restore_procedure.sh
# ------------------------------------------------------------
restore_pitr() {
    local RESTORE_POINT="${RESTORE_POINT:?Erreur : RESTORE_POINT requis (ex: 2026-03-11T02:00:00Z)}"
    local TARGET_DB="${TARGET_DB:-${DB_NAME}-restored-$(date -u +%Y%m%d%H%M)}"

    log "INFO — PITR vers ${RESTORE_POINT} → base cible : ${TARGET_DB}"

    az sql db restore \
      --resource-group      "${RESOURCE_GROUP}" \
      --server              "${SERVER_NAME}" \
      --name                "${DB_NAME}" \
      --dest-name           "${TARGET_DB}" \
      --time                "${RESTORE_POINT}" \
      --edition             Standard \
      --service-objective   S0

    log "OK — PITR terminé. Base restaurée : ${TARGET_DB}"
    log "ATTENTION — Valider les données avant de renommer ou basculer la base en production"
    log "  az sql db rename --resource-group ${RESOURCE_GROUP} --server ${SERVER_NAME} --name ${TARGET_DB} --new-name ${DB_NAME}-validated"
}

# ------------------------------------------------------------
# SCÉNARIO 2 — Restauration depuis BACPAC
# Usage : SCENARIO=bacpac BACPAC_DATE="2026-03-09" bash restore_procedure.sh
# ------------------------------------------------------------
restore_bacpac() {
    local BACPAC_DATE="${BACPAC_DATE:?Erreur : BACPAC_DATE requis (ex: 2026-03-09)}"
    local BACPAC_FILENAME="dwh-shopnow-${BACPAC_DATE}.bacpac"
    local STORAGE_URI="https://${STORAGE_ACCOUNT}.blob.core.windows.net/sql-backups/weekly/${BACPAC_FILENAME}"
    local TARGET_DB="${TARGET_DB:-${DB_NAME}-import-$(date -u +%Y%m%d%H%M)}"

    log "INFO — Import BACPAC : ${BACPAC_FILENAME} → base cible : ${TARGET_DB}"

    # Vérifier existence du BACPAC
    az storage blob show \
      --account-name   "${STORAGE_ACCOUNT}" \
      --container-name "sql-backups" \
      --name           "weekly/${BACPAC_FILENAME}" \
      --account-key    "${STORAGE_KEY}" \
      --query          "properties.contentLength" -o tsv \
      | xargs -I{} log "INFO — Taille BACPAC : {} octets" \
      || { log "ERREUR — BACPAC introuvable : ${BACPAC_FILENAME}"; exit 1; }

    az sql db import \
      --resource-group "${RESOURCE_GROUP}" \
      --server         "${SERVER_NAME}" \
      --name           "${TARGET_DB}" \
      --admin-user     "${ADMIN_LOGIN}" \
      --admin-password "${ADMIN_PASSWORD}" \
      --storage-key    "${STORAGE_KEY}" \
      --storage-key-type StorageAccessKey \
      --storage-uri    "${STORAGE_URI}"

    log "OK — Import BACPAC terminé. Base restaurée : ${TARGET_DB}"
    log "ATTENTION — Valider les données avant bascule en production"
}

# ------------------------------------------------------------
# Dispatch scénario
# ------------------------------------------------------------
SCENARIO="${SCENARIO:-pitr}"

case "${SCENARIO}" in
    pitr)   restore_pitr ;;
    bacpac) restore_bacpac ;;
    *)
        log "ERREUR — SCENARIO inconnu : ${SCENARIO}. Valeurs : pitr | bacpac"
        exit 1
        ;;
esac

log "INFO — restore_procedure.sh terminé. Log : ${LOG_FILE}"
exit 0
