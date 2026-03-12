# Event Hub Producers

Producteurs Python multi-flux pour le DWH ShopNow Marketplace.

## Fonctionnement

Boucle infinie qui envoie des événements vers Azure Event Hubs à intervalles configurables :

| Flux | Event Hub cible | Intervalle par défaut |
|------|-----------------|-----------------------|
| orders | `orders` | 60 s |
| clickstream | `clickstream` | 2 s |

## Variables d'environnement

| Variable | Description |
|----------|-------------|
| `EVENTHUB_CONNECTION_STR` | Connection string Event Hubs (policy `send`) |
| `ORDERS_INTERVAL` | Intervalle envoi orders (secondes, défaut 60) |
| `PRODUCTS_INTERVAL` | Intervalle envoi products (secondes, défaut 120) |
| `CLICKSTREAM_INTERVAL` | Intervalle envoi clickstream (secondes, défaut 2) |

## Build et déploiement

```bash
# Build (--network=host requis dans certains environnements restreints)
docker build --network=host -t blackphoenix2020/event_hub_producers:latest .

# Push DockerHub
docker push blackphoenix2020/event_hub_producers:latest
```

Image publiée : `blackphoenix2020/event_hub_producers:latest`

> L'image originale `sengsathit/event_hub_producers:latest` (fournie par le formateur) est inaccessible (privée/supprimée). Cette image a été reconstruite depuis les sources présentes dans ce dossier.

## Dépendances

- `azure-eventhub` — SDK Event Hubs
- `Faker` — génération de données de test réalistes
