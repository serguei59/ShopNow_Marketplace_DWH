# E6 – Document de cadrage (Plan du rapport final)

Ce document est le **plan complet et structurant du rapport E6**, conforme au référentiel et à la logique du projet Marketplace.

---

# 1️⃣ Introduction  
- Contexte Marketplace ShopNow  
- Problématique multi-vendeurs  
- Objectifs du DWH  
- Enjeux qualité / sécurité / disponibilité  
- Présentation du périmètre E6 (C16 & C17)

---

# 2️⃣ Diagnostic initial  
- Sources multiples / hétérogènes  
- Faible qualité envoyée par les vendeurs  
- Absence d’historisation  
- Aucun mécanisme de sécurité multi-tenant  
- Aucun DRP ni backups réels  
- Supervision inexistante  

---

# 3️⃣ Situations professionnelles (réelles + simulées)  
*(Référence complète au fichier E6_Situations_Types.md)*  
- Intégration multi-sources  
- Contrôles qualité  
- Historisation SCD2  
- Streaming temps réel  
- Sécurité multi-tenant  
- Plan de reprise / incident majeur  
- Supervision SLA  
- Ajout vendeur  
- Optimisation DWH  
- Documentation / transfert MCO  

---

# 4️⃣ Proposition d’architecture cible (socle commun)

## 4.1 Schéma général  
- ADLS RAW / CLEAN / CURATED  
- ADF ingestion  
- Databricks transformation  
- SQL DWH  
- Event Hubs / Stream Analytics  
- Power BI  

## 4.2 Sécurité  
- RBAC  
- RLS  
- Masquage SQL  

## 4.3 Résilience  
- Snapshots SQL  
- Versioning ADLS  
- Réplication géographique  

---

# 5️⃣ Mise en œuvre (terraform + scripts)

## 5.1 Ressources déployées  
- ADLS  
- Event Hubs  
- SQL  
- Stream Analytics  
- Pipelines ADF  
- Power BI (RLS)

## 5.2 Documentation associée  
- README  
- DRP  
- Procédure intégration nouvelle source  
- Procédure restauration  

---

# 6️⃣ Validation des compétences (C16 / C17)  
*(Référence à E6_Grille_Validation.md)*

- C16 couvert via :  
  - diagnostics  
  - MCO  
  - évolutions  
  - contrôle efficacité  

- C17 couvert via :  
  - qualité  
  - sécurité  
  - disponibilité  
  - supervision  

---

# 7️⃣ Résultats & indicateurs  
- KPIs qualité  
- Historisation  
- Disponibilité  
- Sécurité multi-tenant  
- Temps de traitement ↓  

---

# 8️⃣ Conclusion et recommandations  
- Pérennité  
- Facilité maintenance  
- Évolutions futures :  
  - catalogue Purview  
  - automatisation CI/CD  
  - ML scoring des vendeurs  

