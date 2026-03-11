# Structure des modules Terraform

Les fichiers Terraform sont répartis en deux niveaux :

```
terraform/           ← point d'entrée (terraform init/apply lancé ici)
  1_main.tf          ← orchestration des modules
  2_variables.tf     ← déclaration des variables
  3_providers.tf     ← provider azurerm v4.54.0
  terraform.tfvars   ← valeurs des variables (subscription, credentials)

modules/             ← modules réutilisables (racine du projet)
  event_hubs/        ← namespace Event Hubs + 3 hubs + policies send/listen
  sql_database/      ← SQL Server + base dwh-shopnow (S0) + container db-setup
  stream_analytics/  ← job ASA + inputs Event Hubs + outputs SQL + démarrage
  container_producers/ ← ACI producteurs Python (orders/products/clickstream)
```

## Détail des modules

### event_hubs
- Namespace SKU Basic, capacity 1
- Event Hubs : `orders`, `products`, `clickstream` (partition_count=1, retention=1j)
- Authorization rules : `send-policy` et `listen-policy`

### sql_database
- SQL Server v12.0 nommé `sql-server-rg-e6-sbuasa`
- Base `dwh-shopnow` : SKU S0, 2 GB max, collation `SQL_Latin1_General_CP1_CI_AS`
- Firewall : AllowAzureServices (0.0.0.0/0.0.0.0)
- Container `db-setup` : exécute `dwh_schema.sql` via `sqlcmd` (one-shot)

### stream_analytics
- Job `asa-shopnow` : 1 streaming unit, compatibilité 1.2
- Inputs : `InputOrders`, `InputClickstream` (Event Hubs, JSON)
- Outputs : `OutputFactOrder`, `OutputDimCustomer`, `OutputDimProduct`, `OutputFactClickstream` (Azure SQL)
- Démarrage automatique via `null_resource` + `local-exec` (`az stream-analytics job start`)

### container_producers
- ACI `aeh-producers`, restart_policy Always, pas d'IP publique
- Image : `sengsathit/event_hub_producers:latest`
- Variables d'environnement : `EVENTHUB_CONNECTION_STR`, intervalles orders/products/clickstream
