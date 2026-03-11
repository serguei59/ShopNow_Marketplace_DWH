# Sécurité & Conformité RGPD — DWH ShopNow

---

## Registre des traitements (art. 30 RGPD)

3 traitements documentés dans [`security/rgpd/registre_traitements.md`](../../security/rgpd/registre_traitements.md) :

| Traitement | Table(s) | Base légale | Conservation |
|------------|----------|-------------|--------------|
| Commandes clients | `dim_customer`, `fact_order` | Contrat art. 6.1.b | 10 ans |
| Clickstream | `fact_clickstream` | Intérêt légitime art. 6.1.f | 13 mois (CNIL) |
| Vendeurs tiers | `dim_vendor` (C17) | Contrat art. 6.1.b | Contrat + 5 ans |

## Procédures de conformité RGPD

Documentées dans [`security/rgpd/procedures_conformite.md`](../../security/rgpd/procedures_conformite.md) :

| Procédure | Fréquence | Automatisée |
|-----------|-----------|-------------|
| Purge clickstream J+13 mois | Mensuelle | Oui |
| Effacement art. 17 (pseudonymisation) | Sur demande | Non |
| Rectification art. 16 | Sur demande | Non |
| Portabilité art. 20 (export JSON) | Sur demande | Non |
| Audit accès | Trimestrielle | Non |

## Contrôle d'accès RBAC

Matrice complète dans [`security/rbac/rbac_mapping.md`](../../security/rbac/rbac_mapping.md) :

| Rôle | Azure RBAC | SQL Permission | MFA |
|------|-----------|----------------|-----|
| Admin | Owner | db_owner | Oui |
| Data Engineer | Contributor | db_datareader + db_datawriter | Oui |
| Data Steward | Reader | db_datareader + UPDATE dim_customer | Oui |
| MCO | Reader | db_datareader | Oui |
| Vendeur | — | SELECT sur vues filtrées | Non |

| Action | Artefact | Statut |
|--------|----------|--------|
| Registre traitements RGPD art. 30 | `security/rgpd/registre_traitements.md` | [x] Fait |
| Procédures conformité + fréquences | `security/rgpd/procedures_conformite.md` | [x] Fait |
| Matrice RBAC 5 rôles | `security/rbac/rbac_mapping.md` | [x] Fait |
