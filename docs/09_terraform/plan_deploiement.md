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

### 3. Image Docker des producers

L'image `sengsathit/event_hub_producers:latest` référencée dans le code source du prof est privée/supprimée et inaccessible. L'image a été reconstruite depuis les sources locales (`_events_producers/`) et publiée sur le compte DockerHub du candidat.

```bash
cd _events_producers/

# Build avec --network=host pour que pip accède à PyPI
docker build --network=host -t blackphoenix2020/event_hub_producers:latest .

# Push
docker push blackphoenix2020/event_hub_producers:latest
```

Mettre à jour `terraform/terraform.tfvars` :

```hcl
container_producers_image = "blackphoenix2020/event_hub_producers:latest"
dockerhub_username        = "blackphoenix2020"
dockerhub_token           = "<token_dockerhub>"
```

> **Note :** Le Dockerfile utilise `--network=host` en raison d'une restriction DNS de l'environnement de build. L'image est publique sur DockerHub : `blackphoenix2020/event_hub_producers:latest`.

---

### 4. Corriger les chemins dans 1_main.tf

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

## Historique des déploiements

| Date | Action | Subscription | Résultat |
|------|--------|-------------|---------|
| 2026-03-11 | `terraform apply` initial | `51a5ea3c` (perso) | 20/21 ressources créées (ACI producers KO — image inaccessible) |
| 2026-03-11 | Build image + `terraform apply -target=module.container_producers` | `51a5ea3c` (perso) | Image reconstruite depuis sources, 21/21 ressources déployées |

## Destruction

```bash
terraform destroy
```

> **Note :** Le container `db-setup` reste en état `Terminated` après exécution — c'est le comportement attendu (`restart_policy = "Never"`).
