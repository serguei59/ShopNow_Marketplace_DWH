# Maintenance en Conditions Opérationnelles (MCO) : Socle MCO (C16)
 
---

## 🔧 Monitoring & logs
- Azure Log Analytics  
- Logs ADF, API, Stream Analytics  
- Dashboards SLA

## 🚨 Alertes
- Pipelines ETL en échec  
- API vendeurs non atteignables  
- Taux anomalies > seuil  
- Stock non mis à jour  

## 💾 Backups & DRP
- Snapshots SQL  
- Versioning ADLS  
- Procédures de restauration (perte région, suppression accidentelle)

## 📚 Documentation
- Runbooks MCO  
- Incident playbooks  
- Dictionnaires données  

## 🔌 Nouvelles sources
- Pipelines multi-formats  
- Connecteurs API  
- Normalisation (Databricks)  

| Critère | Action | Ressources | Statut |
|---------|--------|------------|--------|
| Logging & supervision | Configurer logs ETL / API / Stream | Azure Log Analytics, Azure Monitor | [ ] |
| Alerting | Définir alertes erreurs / anomalies stock | Azure Monitor, Power BI | [ ] |
| SLA | Définir indicateurs service | Power BI Dashboard | [ ] |
| Backups | Sauvegarde SQL DWH, tables critiques, metadata | SQL Snapshots, ADLS, Purview | [ ] |
| Documentation | Procédures intégration, datamarts, stockage | Docs/README | [ ] |
| Zones données | RAW / CLEAN / CURATED / REJECT | ADLS gen2, ADF | [ ] |
