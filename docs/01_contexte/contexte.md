# Contexte général — ShopNow Marketplace

## Situation initiale

ShopNow est une entreprise e-commerce disposant d'un DWH Azure opérationnel :
- Pipeline streaming : **Python producers → Event Hubs → Stream Analytics → Azure SQL**
- Tables : `dim_customer`, `dim_product`, `fact_order`, `fact_clickstream`
- Infrastructure IaC : **Terraform** (azurerm v4.54.0), région `francecentral`

## Pivot stratégique : modèle Marketplace

ShopNow ouvre sa plateforme à des **vendeurs tiers**. Ce pivot implique :

| Avant | Après |
|-------|-------|
| Vendeur unique (ShopNow) | Multi-vendeurs tiers indépendants |
| Pas de dimension vendeur | `dim_vendor` SCD2 requis |
| Stocks gérés en interne | `fact_vendor_stock` par vendeur |
| RGPD simplifié | 3 traitements distincts à registrer |

## Enjeux techniques

| Enjeu | Impact |
|-------|--------|
| Hétérogénéité des sources | Vendeurs via API batch (≠ streaming orders) |
| Historisation des contrats | SCD2 obligatoire (commission, statut) |
| Supervision MCO | Pipeline arrêté = invisible sans monitoring |
| RGPD multi-acteurs | Données vendeurs + clients + clickstream |
| Résilience | RPO <15 min, RTO <2h — backup documenté |

## Périmètre de la mission E6

- **C16** : Socle MCO — supervision, backup, maintenance, RGPD, RBAC
- **C17** : SCD2 — dim_vendor, fact_vendor_stock, ETL adapté

Voir [objectifs_mission.md](objectifs_mission.md) pour le détail des livrables.
