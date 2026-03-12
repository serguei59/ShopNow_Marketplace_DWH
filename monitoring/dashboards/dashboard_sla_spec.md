# Spécification Dashboard SLA — DWH ShopNow Marketplace

**Outil cible :** Power BI (ou Azure Monitor Workbooks)
**Source de données :** Azure SQL `dwh-shopnow` — DMV + tables DWH
**Mode connexion :** DirectQuery (refresh 15 min)
**Critère C16 :** Tableau de bord permettant de rendre compte de l'ensemble des indicateurs de service

---

## Vue d'ensemble — 6 tiles

| # | Tile | Requête source | Seuils visuels |
|---|------|---------------|----------------|
| 1 | Disponibilité base (%) | `sla_availability.sql` — Req. 1 | 🟢 ≥99,9% / 🟠 ≥99% / 🔴 <99% |
| 2 | Latence `fact_order` (min) | `sla_availability.sql` — Req. 2 | 🟢 ≤5min / 🟠 ≤15min / 🔴 >15min |
| 3 | Latence `fact_clickstream` (min) | `sla_availability.sql` — Req. 2 | 🟢 ≤2min / 🟠 ≤5min / 🔴 >5min |
| 4 | Taux erreurs connexion (%) | `log_errors_last24h.sql` — Req. 1 | 🟢 <1% / 🟠 <5% / 🔴 ≥5% |
| 5 | Volume journalier commandes | `data_freshness.sql` — Req. 3 | 🟢 normal / 🟠 -25% / 🔴 -50% |
| 6 | Statut SLA global | Agrégat tiles 1-3 | 🟢 TOUT OK / 🔴 AU MOINS 1 KO |

---

## Détail des tiles

### Tile 1 — Disponibilité base (%)
- **Type :** Jauge (gauge) ou carte KPI
- **Valeur :** `taux_disponibilite_pct` moyen sur la période sélectionnée
- **Référence :** `sla_availability.sql` Requête 1
- **Seuil SLA :** 99,9 % / mois

### Tile 2 — Latence fact_order
- **Type :** Carte KPI avec indicateur de tendance
- **Valeur :** `retard_minutes` en temps réel
- **Référence :** `sla_availability.sql` Requête 2
- **Seuil SLA :** ≤ 5 minutes

### Tile 3 — Latence fact_clickstream
- **Type :** Carte KPI avec indicateur de tendance
- **Valeur :** `retard_minutes` en temps réel
- **Référence :** `sla_availability.sql` Requête 2
- **Seuil SLA :** ≤ 2 minutes

### Tile 4 — Taux erreurs connexion
- **Type :** Graphique courbe (24h glissantes)
- **Valeur :** `connexions_ko / total_connexions * 100`
- **Référence :** `log_errors_last24h.sql` Requête 1

### Tile 5 — Volume journalier commandes
- **Type :** Histogramme barres J-7
- **Valeur :** `nb_commandes` par jour
- **Référence :** `data_freshness.sql` Requête 3

### Tile 6 — Statut SLA global
- **Type :** Carte statut (vert/rouge)
- **Logique :** `IF(tile1=OK AND tile2=OK AND tile3=OK, "TOUT OK", "INCIDENT")`

---

## Filtres globaux

| Filtre | Valeurs | Par défaut |
|--------|---------|-----------|
| Période | 24h / 7j / 30j | 7j |
| Table source | fact_order / fact_clickstream / toutes | toutes |
| Statut SLA | OK / KO / tous | tous |

---

## Vues

### Vue MCO (technique)
- Toutes les tiles + détail erreurs + sessions bloquantes
- Actualisation : 15 min
- Destinataires : Data Engineer, MCO

### Vue Direction (synthèse)
- Tile 6 (statut global) + Tile 1 (disponibilité) + Tile 5 (volume)
- Lecture seule, format épuré
- Destinataires : Responsable de traitement, direction

---

## Procédure de déploiement

```bash
# 1. Connexion Power BI Desktop → Get Data → Azure SQL Database
# Server  : sql-server-rg-e6-sbuasa.database.windows.net
# Database: dwh-shopnow
# Mode    : DirectQuery

# 2. Importer les 4 requêtes SQL comme sources nommées
# 3. Créer les 6 tiles selon la spécification ci-dessus
# 4. Publier sur Power BI Service → workspace ShopNow
# 5. Configurer le refresh planifié : toutes les 15 min
```

> **Note environnement de test :** Power BI Service n'est pas disponible dans
> cet environnement Azure de formation. Cette spécification constitue la preuve
> de conception requise par le critère C16.
