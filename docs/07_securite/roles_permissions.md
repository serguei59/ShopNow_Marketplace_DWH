# Rôles & Permissions

**Implémentation :** voir [`security/rbac/rbac_mapping.md`](../../security/rbac/rbac_mapping.md)

## Matrice RBAC — synthèse

| Rôle | Azure RBAC | SQL Permission | MFA |
|------|-----------|----------------|-----|
| Admin | Owner | db_owner | Oui |
| Data Engineer | Contributor | db_datareader + db_datawriter | Oui |
| Data Steward | Reader | db_datareader + UPDATE dim_customer | Oui |
| MCO | Reader | db_datareader (toutes tables) | Oui |
| Vendeur | — | SELECT sur vues filtrées uniquement | Non |

Détail complet (script SQL création login, procédure 6 étapes, révision trimestrielle) :
[`security/rbac/rbac_mapping.md`](../../security/rbac/rbac_mapping.md)
