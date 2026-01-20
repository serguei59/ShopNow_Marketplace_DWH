# 7.2 Situation SCD2

## Contexte
La Marketplace nécessite d'historiser les changements.

## Modèle mis en place
- Clés techniques
- Colonnes de validité
- Flags is_current

## 🖼️ Capture recommandée
- Table SQL SCD2 dans Synapse/Databricks

sequenceDiagram
  participant Source
  participant Pipeline
  participant TableSCD2

  Source->>Pipeline: Donnée nouvelle
  Pipeline->>TableSCD2: Comparaison
  alt Nouveau enregistrement
    TableSCD2->>TableSCD2: Insert (is_current = 1)
  else Changement détecté
    TableSCD2->>TableSCD2: Update is_current = 0
    TableSCD2->>TableSCD2: Insert nouvelle version
  end
