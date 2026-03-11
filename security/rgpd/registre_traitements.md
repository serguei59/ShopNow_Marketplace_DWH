# Registre des traitements de données personnelles

**Projet :** DWH ShopNow Marketplace
**Responsable du traitement :** ShopNow
**Date de mise à jour :** 2026-03-11
**Référence réglementaire :** Article 30 du Règlement (UE) 2016/679 (RGPD)

---

## Traitement 1 — Gestion des commandes clients

| Champ | Valeur |
|-------|--------|
| **Nom du traitement** | Gestion des commandes clients |
| **Finalité** | Traitement et suivi des commandes passées sur la plateforme ShopNow |
| **Base légale** | Exécution du contrat (art. 6.1.b RGPD) |
| **Catégories de personnes concernées** | Clients de la plateforme |
| **Catégories de données personnelles** | Nom, adresse e-mail, adresse postale, ville, pays (`dim_customer`) ; historique des achats (`fact_order`) |
| **Tables DWH concernées** | `dim_customer`, `fact_order` |
| **Destinataires** | Équipe data, équipe logistique, service client |
| **Transfert hors UE** | Non |
| **Durée de conservation** | 10 ans (obligation légale comptable — art. L123-22 Code de commerce) |
| **Mesures de sécurité** | Accès restreint par rôle SQL (`db_datareader` limité), chiffrement TLS en transit, firewall Azure SQL |

---

## Traitement 2 — Analyse comportementale (clickstream)

| Champ | Valeur |
|-------|--------|
| **Nom du traitement** | Analyse du comportement de navigation |
| **Finalité** | Amélioration de l'expérience utilisateur, analyse des parcours d'achat, optimisation des recommandations |
| **Base légale** | Intérêt légitime (art. 6.1.f RGPD) — analyse interne non cédée à des tiers |
| **Catégories de personnes concernées** | Visiteurs authentifiés et anonymes de la plateforme |
| **Catégories de données personnelles** | Identifiant de session, identifiant utilisateur (nullable), URL visitée, type d'événement, adresse IP (`fact_clickstream`) |
| **Tables DWH concernées** | `fact_clickstream` |
| **Destinataires** | Équipe data, équipe produit |
| **Transfert hors UE** | Non |
| **Durée de conservation** | 13 mois (recommandation CNIL — délibération n° 2012-322) |
| **Mesures de sécurité** | Pseudonymisation de `user_id` (UUID non lié à `dim_customer`), purge mensuelle automatique au-delà de 13 mois |

---

## Traitement 3 — Gestion des vendeurs tiers (anticipation Marketplace)

| Champ | Valeur |
|-------|--------|
| **Nom du traitement** | Référencement et suivi des vendeurs tiers |
| **Finalité** | Gestion des partenaires vendeurs dans le cadre du pivot Marketplace de ShopNow |
| **Base légale** | Exécution du contrat (art. 6.1.b RGPD) — contrat de partenariat vendeur |
| **Catégories de personnes concernées** | Représentants légaux et contacts des entreprises vendeures |
| **Catégories de données personnelles** | Raison sociale, nom du contact, e-mail professionnel (`dim_vendor` — à créer C17) |
| **Tables DWH concernées** | `dim_vendor` (implémentation prévue — C17) |
| **Destinataires** | Équipe data, équipe commerciale |
| **Transfert hors UE** | Non |
| **Durée de conservation** | Durée du contrat + 5 ans après résiliation |
| **Mesures de sécurité** | Accès restreint au rôle Vendeur (lecture seule sur ses propres données) |

---

## Droits des personnes concernées

| Droit | Base légale | Délai de réponse | Procédure |
|-------|-------------|-----------------|-----------|
| **Accès** (art. 15) | Sur demande écrite | 1 mois | Export des données client via requête SQL sur `dim_customer` + `fact_order` |
| **Rectification** (art. 16) | Sur demande écrite | 1 mois | `UPDATE dim_customer` par le Data Steward après vérification d'identité |
| **Effacement** (art. 17) | Sur demande écrite ou fin de contrat | 1 mois | Pseudonymisation de `dim_customer` (remplacement nom/email par hash) + purge `fact_clickstream` |
| **Portabilité** (art. 20) | Sur demande écrite | 1 mois | Export JSON des données `dim_customer` + `fact_order` |
| **Opposition** (art. 21) | Sur demande écrite | 1 mois | Applicable au traitement clickstream (intérêt légitime) — suppression des entrées `fact_clickstream` liées au `user_id` |
| **Limitation** (art. 18) | Sur demande écrite | 1 mois | Marquage logique sur `dim_customer` — accès lecture suspendu hors traitement contractuel |

---

## Cartographie des flux de données personnelles

Producteurs Python (ACI aeh-producers)
│
│  JSON : {customer: {name, email, address, city, country}, items, ...}
▼
Azure Event Hub — orders
│
▼
Stream Analytics Job (asa-shopnow)
│  Transformation : extraction dim_customer / fact_order
▼
Azure SQL Database — dwh-shopnow
├─ dim_customer     ← PII niveau 1 (identité directe)
├─ fact_order       ← PII niveau 2 (lien customer_id)
└─ fact_clickstream ← PII niveau 2 (user_id pseudonymisé, ip_address)


---

## Revue et mise à jour du registre

| Fréquence | Action |
|-----------|--------|
| Annuelle | Revue complète du registre par le responsable de traitement |
| À chaque nouveau traitement | Ajout d'une entrée avant mise en production |
| À chaque changement de finalité | Mise à jour de la base légale et de la durée de conservation |


