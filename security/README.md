# Dossier Sécurité — DWH ShopNow Marketplace

**Projet :** DWH ShopNow Marketplace  
**Responsable :** Serge Buasa  
**Date :** 2026-03-11  
**Certification :** RNCP 37638 — Compétence C16

---

## Contexte légal

Ce dossier regroupe l'ensemble des artefacts de gouvernance des données et de sécurité
du DWH ShopNow, en conformité avec :

- **RGPD** — Règlement (UE) 2016/679 (en vigueur depuis mai 2018)
  - Art. 30 : obligation de tenir un registre des traitements
  - Art. 15-21 : droits des personnes concernées
- **Recommandation CNIL n° 2012-322** : durée maximale de conservation des données
  de navigation (clickstream) fixée à 13 mois
- **Code de commerce art. L123-22** : conservation des données comptables 10 ans

---

## Structure du dossier

security/
├── README.md                          ← ce fichier (index)
├── rgpd/
│   ├── registre_traitements.md        ← registre art. 30 RGPD (3 traitements)
│   └── procedures_conformite.md       ← procédures RGPD (purge, effacement, portabilité...)
└── rbac/
└── rbac_mapping.md                ← matrice RBAC (5 rôles × droits Azure + SQL)


---

## Artefacts

### `rgpd/registre_traitements.md`
Registre des traitements de données personnelles (art. 30 RGPD).  
Couvre 3 traitements :
1. Gestion des commandes clients (`dim_customer`, `fact_order`) — base légale : contrat — 10 ans
2. Analyse comportementale clickstream (`fact_clickstream`) — base légale : intérêt légitime — 13 mois
3. Référencement vendeurs tiers (`dim_vendor`, anticipé C17) — base légale : contrat

Inclut le tableau des droits des personnes (accès, rectification, effacement, portabilité,
opposition, limitation) et la cartographie des flux PII.

### `rgpd/procedures_conformite.md`
Procédures opérationnelles de conformité RGPD avec fréquences :
- Purge mensuelle `fact_clickstream` (J+13 mois) — automatisée
- Effacement sur demande art. 17 (pseudonymisation `dim_customer`)
- Rectification art. 16 (`UPDATE dim_customer`)
- Portabilité art. 20 (export JSON `FOR JSON PATH`)
- Audit trimestriel des accès (`sys.event_log`)

### `rbac/rbac_mapping.md`
Matrice des contrôles d'accès basés sur les rôles (RBAC) :
- 5 rôles : Admin, Data Engineer, Data Steward, MCO, Vendeur
- Mapping Azure RBAC role + permissions SQL + périmètre données + MFA
- Script SQL exemple : création login Vendeur avec accès restreint
- Procédure de création d'un nouvel accès (6 étapes)

---

## Périmètre de données personnelles

| Table | Classification PII | Données concernées |
|-------|-------------------|-------------------|
| `dim_customer` | PII niveau 1 — identité directe | name, email, address, city, country |
| `fact_order` | PII niveau 2 — lien indirect | customer_id (FK vers dim_customer) |
| `fact_clickstream` | PII niveau 2 — pseudonymisé | user_id (UUID), ip_address |
| `dim_product` | Aucun PII | Données produit non personnelles |

---

## Révision

| Fréquence | Action |
|-----------|--------|
| Annuelle | Revue complète par le responsable de traitement |
| À chaque nouveau traitement | Mise à jour du registre avant mise en production |
| Trimestrielle | Audit des accès et mise à jour matrice RBAC |
