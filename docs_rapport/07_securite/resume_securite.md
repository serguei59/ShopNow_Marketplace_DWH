# Sécurité & Cloisonnement vendeur

---

## 🔐 RBAC / Azure AD
- Groupes par vendeur  
- Accès lecture/écriture segmentés

## 🔐 ADLS partitionné par VendorID

```
/raw/vendor_id=123/
```

## 🔐 RLS Power BI

```DAX
[VendorID] = USERPRINCIPALNAME()
```

## 🔐 Masquage dynamique SQL

- PII anonymisées en staging

| Action | Ressources | Statut |
|--------|------------|--------|
| RLS Power BI | VendorID = USERPRINCIPALNAME() | [ ] |
| Cloisonnement ADLS | ACL par dossier vendeur | [ ] |
| Gestion identités et rôles | Azure AD + RBAC | [ ] |
