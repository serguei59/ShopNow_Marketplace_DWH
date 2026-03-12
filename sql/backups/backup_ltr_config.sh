#!/usr/bin/env bash
# =============================================================
# backup_ltr_config.sh — Configuration Long-Term Retention (LTR)
# Projet   : DWH ShopNow Marketplace
# Critère  : C16 — Backup partiel planifié et configuré
# LTR      : équivalent backup différentiel/partiel sur Azure SQL
# Schedule : Mensuel (1er du mois) + Annuel (1er janvier)
# =============================================================

set -euo pipefail

# ------------------------------------------------------------
# Variables
# ------------------------------------------------------------
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-e6-sbuasa}"
SERVER_NAME="${SERVER_NAME:-sql-server-rg-e6-sbuasa}"
DB_NAME="${DB_NAME:-dwh-shopnow}"

LOG_FILE="/tmp/ltr_config_$(date -u +%Y-%m-%d).log"

log() { echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $*" | tee -a "${LOG_FILE}"; }

# ------------------------------------------------------------
# 1. Configurer la politique LTR
#    weekly-retention  : 4 semaines
#    monthly-retention : 12 mois
#    yearly-retention  : 5 ans
#    week-of-year      : 1 (1er janvier)
# ------------------------------------------------------------
log "INFO — Configuration politique LTR sur ${DB_NAME}"

az sql db ltr-policy set \
  --resource-group      "${RESOURCE_GROUP}" \
  --server              "${SERVER_NAME}" \
  --name                "${DB_NAME}" \
  --weekly-retention    "P4W" \
  --monthly-retention   "P12M" \
  --yearly-retention    "P5Y" \
  --week-of-year        1

log "OK — Politique LTR configurée : weekly=4W / monthly=12M / yearly=5Y"

# ------------------------------------------------------------
# 2. Vérifier la politique appliquée
# ------------------------------------------------------------
log "INFO — Vérification politique LTR"

az sql db ltr-policy show \
  --resource-group "${RESOURCE_GROUP}" \
  --server         "${SERVER_NAME}" \
  --name           "${DB_NAME}" \
  --output table | tee -a "${LOG_FILE}"

# ------------------------------------------------------------
# 3. Lister les backups LTR existants
# ------------------------------------------------------------
log "INFO — Liste des backups LTR disponibles"

az sql db ltr-backup list \
  --location  francecentral \
  --server    "${SERVER_NAME}" \
  --database  "${DB_NAME}" \
  --output table | tee -a "${LOG_FILE}"

log "INFO — Configuration LTR terminée. Log : ${LOG_FILE}"
exit 0
