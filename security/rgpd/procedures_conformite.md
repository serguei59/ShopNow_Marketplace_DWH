# Procédures de conformité RGPD

**Projet :** DWH ShopNow Marketplace
**Date de mise à jour :** 2026-03-11
**Référence :** C16 — Procédures de tri des données personnelles + traitements de conformité avec fréquence

---

## Procédure 1 — Purge automatique du clickstream (J+13 mois)

**Déclencheur :** Planification mensuelle (1er de chaque mois)
**Table concernée :** `fact_clickstream`
**Base légale :** Recommandation CNIL — durée maximale 13 mois

```sql
-- Purge des événements clickstream de plus de 13 mois
DELETE FROM dbo.fact_clickstream
WHERE event_timestamp < DATEADD(MONTH, -13, GETDATE());
```

**Responsable :** Data Engineer
**Fréquence :** Mensuelle (automatisée)
**Vérification post-purge :**

```sql
SELECT MIN(event_timestamp) AS plus_ancienne_entree,
       COUNT(*) AS total_lignes
FROM dbo.fact_clickstream;
```

---

## Procédure 2 — Droit à l'effacement (art. 17 RGPD)

**Déclencheur :** Demande écrite du client identifié
**Tables concernées :** `dim_customer`, `fact_clickstream`
**Délai de traitement :** 1 mois maximum

### Étapes

1. Réception et validation de la demande (identité vérifiée par le Data Steward)
2. Recherche du `customer_id` dans `dim_customer`
3. Pseudonymisation de `dim_customer` (conservation pour intégrité référentielle)
4. Purge des entrées `fact_clickstream` liées au `user_id`

```sql
-- Pseudonymisation dim_customer
UPDATE dbo.dim_customer
SET name    = 'ANONYMIZED',
    email   = CONCAT('anon_', customer_id, '@deleted.invalid'),
    address = 'ANONYMIZED',
    city    = 'ANONYMIZED',
    country = 'ANONYMIZED'
WHERE customer_id = '<customer_id>';

-- Suppression clickstream lié
DELETE FROM dbo.fact_clickstream
WHERE user_id = '<user_id_associé>';
```

> `fact_order` est conservé (obligation légale comptable 10 ans) mais le lien nominatif est coupé par la pseudonymisation de `dim_customer`.

**Responsable :** Data Steward (validation) + Data Engineer (exécution)
**Fréquence :** Sur demande — délai max 1 mois

---

## Procédure 3 — Droit de rectification (art. 16 RGPD)

**Déclencheur :** Demande écrite du client
**Table concernée :** `dim_customer`
**Délai de traitement :** 1 mois maximum

```sql
UPDATE dbo.dim_customer
SET name    = '<nouveau_nom>',
    email   = '<nouvel_email>',
    address = '<nouvelle_adresse>',
    city    = '<nouvelle_ville>',
    country = '<nouveau_pays>'
WHERE customer_id = '<customer_id>';
```

**Responsable :** Data Steward (validation) + Data Engineer (exécution)
**Fréquence :** Sur demande — délai max 1 mois

---

## Procédure 4 — Droit à la portabilité (art. 20 RGPD)

**Déclencheur :** Demande écrite du client
**Tables concernées :** `dim_customer`, `fact_order`
**Format de sortie :** JSON
**Délai de traitement :** 1 mois maximum

```sql
SELECT
    c.customer_id,
    c.name,
    c.email,
    c.address,
    c.city,
    c.country,
    (
        SELECT o.order_id, o.product_id, o.quantity, o.unit_price,
               o.status, o.order_timestamp
        FROM dbo.fact_order o
        WHERE o.customer_id = c.customer_id
        FOR JSON PATH
    ) AS commandes
FROM dbo.dim_customer c
WHERE c.customer_id = '<customer_id>'
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
```

**Responsable :** Data Engineer (exécution) + Data Steward (transmission sécurisée)
**Fréquence :** Sur demande — délai max 1 mois

---

## Procédure 5 — Audit trimestriel des accès

**Déclencheur :** Planification trimestrielle
**Objectif :** Détecter les accès non conformes, comptes inactifs, droits excessifs

```sql
SELECT event_time, event_type, database_name, server_principal_name
FROM sys.event_log
WHERE event_type IN ('connection_successful', 'connection_failed')
  AND event_time > DATEADD(DAY, -90, GETDATE())
ORDER BY event_time DESC;
```

**Actions :**
- Désactiver les comptes sans connexion depuis 90 jours
- Signaler les connexions échouées répétées (>5 en 24h)
- Mettre à jour la matrice RBAC (`security/rbac/rbac_mapping.md`)

**Responsable :** MCO (exécution) + Data Steward (validation)
**Fréquence :** Trimestrielle

---

## Calendrier des traitements de conformité

| Procédure | Fréquence | Responsable | Automatisée |
|-----------|-----------|-------------|-------------|
| Purge clickstream J+13 mois | Mensuelle (1er du mois) | Data Engineer | Oui |
| Effacement sur demande | Sur demande (< 1 mois) | Data Steward + Data Engineer | Non |
| Rectification sur demande | Sur demande (< 1 mois) | Data Steward + Data Engineer | Non |
| Portabilité sur demande | Sur demande (< 1 mois) | Data Engineer | Non |
| Audit des accès | Trimestrielle | MCO + Data Steward | Non |
| Revue du registre RGPD | Annuelle | Responsable traitement | Non |
