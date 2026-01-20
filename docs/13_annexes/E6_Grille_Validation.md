
# ✔️ Grille de Validation E6 – C16 / C17  
(À cocher au fur et à mesure de l’avancement)

---

## 🟦 C16 — Maintenir et faire évoluer un Data Warehouse

### C16.1 — Supervision & Monitoring
- [ ] Mise en place des logs (Log Analytics)
- [ ] Monitoring Azure Monitor
- [ ] Tableau de bord fraîcheur / rejets
- [ ] Alertes automatiques (erreurs, stocks, anomalies)

---

### C16.2 — Sécurité, accès et conformité
- [ ] RBAC Azure configuré
- [ ] Row-Level Security par VendorID
- [ ] ACLs par vendeur dans ADLS
- [ ] Pseudonymisation des PII
- [ ] Droit à l’oubli documenté
- [ ] Registre RGPD complété

---

### C16.3 — Plan de maintenance
- [ ] Purge RAW / REJECT
- [ ] Optimisation columnstore / partitions
- [ ] Vérification ACLs
- [ ] Mise à jour dictionnaires qualité
- [ ] Revue qualité vendeur (score)

---

### C16.4 — Sauvegardes & restauration
- [ ] Versioning ADLS activé
- [ ] Snapshots DWH SQL planifiés
- [ ] Backup metadata Purview / catalogues
- [ ] Procédure de restauration testée

---

### C16.5 — Documentation d’exploitation
- [ ] Architecture globale rédigée
- [ ] Dictionnaire des données
- [ ] Règles SCD documentées
- [ ] Règles qualité (validation) documentées
- [ ] Procédures en cas d’incident
- [ ] SLA décrit et validé

---

### C16.6 — SLA & indicateurs de service
- [ ] Disponibilité garantie 99,9%
- [ ] Fraîcheur commandes < 15 min
- [ ] Flux vendeur fichiers J+1
- [ ] Mise à jour stock < 5 min (streaming)

---

### C16.7 — Intégration nouvelles sources
- [ ] Gestion API vendeurs
- [ ] Gestion fichiers hétérogènes (CSV/JSON/Excel)
- [ ] Gestion streaming Event Hubs
- [ ] Normalisation schémas vendeurs
- [ ] Mise en place zones RAW / CLEAN / CURATED / REJECT

---

## 🟩 C17 — Gestion des SCD (Slowly Changing Dimensions)

### C17.1 — Identification des variations
- [ ] Attributs variant dans le temps listés (vendeurs, produits)

---

### C17.2 — Choix des types de SCD
- [ ] SCD2 défini pour dim_vendor
- [ ] SCD1 ou mixte défini pour dim_product

---

### C17.3 — Implémentation SCD
- [ ] Surrogate keys
- [ ] DateEffective / DateExpiration / IsCurrent
- [ ] Détection changement (hash / comparaison)

---

### C17.4 — Adaptation ETL aux SCD
- [ ] Pipelines modifiés pour SCD2
- [ ] Insertion nouvelle ligne si changement détecté
- [ ] Clôture ancien enregistrement

---

### C17.5 — Documentation SCD
- [ ] Dictionnaire attributs historisés
- [ ] Flux SCD documenté
- [ ] Diagrammes mis à jour

---

## ✔️ Suivi global
- [ ] Architecture validée
- [ ] Modèle de données validé
- [ ] Plan d’exploitation complet
- [ ] Conformité RGPD OK
- [ ] Supervision opérationnelle OK

---

*Document à valider étape par étape pendant ton projet E6.*
