# 4. Diagnostic de l’architecture existante

La plateforme existante présente plusieurs limites structurelles.

## 4.1. Ingestion
- Pipelines non standardisés.
- Absence de gestion des erreurs.
- Pas de mécanisme d'historisation.
- Dépendances manuelles entre jobs.

## 4.2. Stockage
- Organisation en silos.
- Pas de zone Raw/Curated/Serve.
- Pas de versioning des données.

## 4.3. Sécurité
- Droits attribués individuellement au lieu de rôles.
- Pas de séparation vendeur/client.
- Audit logs partiels.

## 4.4. Supervision
- Monitoring insuffisant.
- Impossible d'observer un SLA de bout en bout.
- Logs dispersés dans plusieurs comptes/ressources.

## 4.5. Gouvernance
- Métadonnées limitées.
- Absence de catalogage centralisé.
