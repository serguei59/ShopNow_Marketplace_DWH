# Plan DRP – Sauvegardes et restauration

---

## Scénarios couverts
- Suppression accidentelle dataset  
- Corruption table  
- Perte région (type OVH Strasbourg)  
- API vendeurs en panne  

## Mécanismes
- SQL automated backups  
- ADLS versioning + soft delete  
- Export Terraform state  
- Réplication GRS  

## Tests
- Restauration sandbox trimestrielle  

| Action | Ressources | Statut |
|--------|------------|--------|
| Backups SQL DWH | Snapshots, soft-delete | [ ] |
| Backups metadata store | ADLS / Purview | [ ] |
| Automatisation | Pipelines ADF / scripts Terraform | [ ] |
| Scénarios de restauration | Pertes accidentelles, OVH, suppression stagiaire | [ ] |
