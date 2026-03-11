# Plan de déploiement

## Prérequis : connexion Azure et corrections de chemins

Avant tout déploiement Terraform, deux corrections structurelles et une vérification de connexion sont nécessaires.

### 1. Vérifier la connexion Azure CLI

```bash
az account show
```

Le compte actif doit correspondre à la subscription cible du projet.
Deux subscriptions sont disponibles :

| Nom | Subscription ID | Usage |
|-----|----------------|-------|
| HDF_ROUBAIX_DATA_ENGINEER_P1_ALT_91373 | `029b3537-0f24-400b-b624-6058a145efe1` | Subscription école (expirée) |
| Azure subscription 1 | `51a5ea3c-2ada-4f97-b2a1-a26eda3b14f2` | Subscription personnelle (active) |

Pour basculer sur la bonne subscription :

```bash
az account set --subscription 51a5ea3c-2ada-4f97-b2a1-a26eda3b14f2
```

### 2. Mettre à jour terraform.tfvars

Dans `terraform/terraform.tfvars`, s'assurer que `subscription_id` correspond à la subscription active :

```hcl
subscription_id = "51a5ea3c-2ada-4f97-b2a1-a26eda3b14f2"
```

### 3. Corriger les chemins dans 1_main.tf

Le fichier `terraform/1_main.tf` référence les modules avec `./modules/` alors qu'ils se trouvent à la racine du projet (`../modules/` relatif au dossier `terraform/`). Corrections à appliquer :

| Avant | Après |
|-------|-------|
| `source = "./modules/event_hubs"` | `source = "../modules/event_hubs"` |
| `source = "./modules/sql_database"` | `source = "../modules/sql_database"` |
| `source = "./modules/stream_analytics"` | `source = "../modules/stream_analytics"` |
| `source = "./modules/container_producers"` | `source = "../modules/container_producers"` |
| `schema_file_path = "${path.root}/dwh_schema.sql"` | `schema_file_path = "${path.root}/../dwh_schema.sql"` |

`path.root` résout vers le dossier `terraform/` ; le schéma SQL est à la racine du projet.

---

## Déploiement

Depuis le dossier `terraform/` :

```bash
cd terraform/

# Initialisation des providers et modules
terraform init

# Vérification du plan (aucune ressource créée)
terraform plan

# Déploiement effectif (~10-15 min)
terraform apply
```

L'ordre de création est géré par les `depends_on` définis dans `1_main.tf` :

1. Resource Group
2. Event Hubs namespace + Event Hubs (orders, products, clickstream)
3. SQL Server + base `dwh-shopnow` + container db-setup (exécution de `dwh_schema.sql`)
4. Stream Analytics job + inputs/outputs + démarrage automatique
5. Container producers (ACI)

## Destruction

```bash
terraform destroy
```

> **Note :** Le container `db-setup` reste en état `Terminated` après exécution — c'est le comportement attendu (`restart_policy = "Never"`).
