# Enjeux du pivot Marketplace

## Pourquoi le modèle Marketplace change tout

Un modèle Marketplace multi-vendeurs introduit des contraintes DWH fondamentalement différentes d'un modèle mono-vendeur :

## 1. Traçabilité contractuelle

Chaque vendeur négocie des **taux de commission** qui évoluent dans le temps. Un écrasement (SCD1) efface l'historique — illégal dans un contexte contractuel.

→ **Solution : SCD Type 2** (`dim_vendor` avec `valid_from`, `valid_to`, `is_current`)

## 2. Cloisonnement des données

Un vendeur ne doit voir **que ses propres données** (stocks, commandes, commissions).

→ **Solution : RBAC Azure SQL** — vues filtrées par `vendor_id`, rôle SQL dédié vendeur

## 3. Qualité et disponibilité des stocks

Les stocks vendeurs sont mis à jour **toutes les heures** — pas en temps réel. Un modèle insert-only horodaté garantit l'auditabilité.

→ **Solution : `fact_vendor_stock`** — INSERT-only avec `stock_timestamp`

## 4. Supervision hybride

Le DWH combine désormais :
- Flux **temps réel** (orders/clickstream via Stream Analytics)
- Flux **batch** (vendeurs/stocks via procédures stockées)

→ **Solution : monitoring DMV Azure SQL** + alertes Azure Monitor sur les deux flux

## 5. Conformité RGPD étendue

3 traitements distincts à déclarer (art. 30 RGPD) :

| Traitement | Base légale | Durée |
|------------|-------------|-------|
| Commandes clients | Contrat art. 6.1.b | 10 ans |
| Clickstream | Intérêt légitime art. 6.1.f | 13 mois (CNIL) |
| Vendeurs tiers | Contrat art. 6.1.b | Contrat + 5 ans |

## 6. Dimensionnement et évolutivité

L'implémentation actuelle (Azure SQL S0, 10 DTU) est calibrée pour le **MVP Marketplace** :

| Seuil | Valeur S0 | Trigger migration |
|-------|-----------|-------------------|
| DTU | 10 | >80% sustained → passer S2 |
| Stockage | 2 GB | >1.5 GB → passer S1 |
| Vendeurs | <100 actifs | >500 → évaluer Elastic Pool |
