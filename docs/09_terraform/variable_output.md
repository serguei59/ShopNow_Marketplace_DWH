# Variables et Outputs Terraform

## Variables principales (terraform/variables.tf)

| Variable | Type | Description |
|----------|------|-------------|
| `subscription_id` | string | ID subscription Azure (`51a5ea3c-...`) |
| `resource_group_name` | string | Nom du RG (`rg-e6-sbuasa`) |
| `location` | string | Région Azure (`francecentral`) |
| `sql_admin_login` | string | Login admin SQL (`sqladmin`) |
| `sql_admin_password` | string | Mot de passe SQL (sensible) |
| `eventhub_namespace` | string | Nom namespace Event Hubs (`eh-sbuasa`) |
| `dockerhub_username` | string | Username DockerHub pour l'image producers (`blackphoenix2020`) |

## Valeurs actives (terraform/terraform.tfvars)

```hcl
subscription_id     = "51a5ea3c-2ada-4f97-b2a1-a26eda3b14f2"
resource_group_name = "rg-e6-sbuasa"
location            = "francecentral"
sql_admin_login     = "sqladmin"
dockerhub_username  = "blackphoenix2020"
```

> `sql_admin_password` non versionné — injecté en variable d'environnement ou prompt Terraform.

## Outputs (terraform/outputs.tf)

| Output | Description |
|--------|-------------|
| `sql_server_fqdn` | FQDN du SQL Server : `sql-server-rg-e6-sbuasa.database.windows.net` |
| `eventhub_connection_string` | Connection string Event Hub (sensitive) |
| `stream_analytics_job_name` | Nom du job ASA : `asa-shopnow` |
| `resource_group_name` | Nom du RG déployé |

## Corrections appliquées vs dépôt initial

| Fichier | Variable | Ancienne valeur | Nouvelle valeur |
|---------|----------|-----------------|-----------------|
| `terraform.tfvars` | `subscription_id` | `029b3537-...` (école, expirée) | `51a5ea3c-...` (personnelle) |
| `terraform.tfvars` | `dockerhub_username` | `sengsathit` (image privée) | `blackphoenix2020` (image reconstruite) |
