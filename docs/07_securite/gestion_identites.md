# Gestion des identités

**Implémentation :** voir [`security/`](../../security/)

## Registre des traitements RGPD (art. 30)

3 traitements documentés : commandes clients, clickstream, vendeurs tiers.
Référence : [`security/rgpd/registre_traitements.md`](../../security/rgpd/registre_traitements.md)

## Procédures de conformité

Purge mensuelle clickstream, effacement art. 17, rectification art. 16, portabilité art. 20, audit trimestriel.
Référence : [`security/rgpd/procedures_conformite.md`](../../security/rgpd/procedures_conformite.md)

## Contrôle d'accès (RBAC)

5 rôles (Admin, Data Engineer, Data Steward, MCO, Vendeur) mappés sur Azure RBAC + permissions SQL.
Référence : [`security/rbac/rbac_mapping.md`](../../security/rbac/rbac_mapping.md)
