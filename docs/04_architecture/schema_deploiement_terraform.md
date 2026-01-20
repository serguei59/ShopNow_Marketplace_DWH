# Schéma de déploiement Terraform

Terraform gère :

- RG
- Storage
- Key Vault
- Data Factory
- Event Hubs
- Monitor
- Log Analytics

flowchart TD
  A[main.tf] --> B[modules/storage]
  A --> C[modules/datafactory]
  A --> D[modules/eventhub]
  A --> E[modules/keyvault]
  A --> F[modules/monitoring]
