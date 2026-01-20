# 7.4 Situation ingestion multi-sources

## Sources intégrées
- API partenaires
- Fichiers CSV/Parquet
- Event Hubs

## 🖼️ Capture recommandée
- Architecture d’ingestion dans Data Factory

# Situation Multi-sources

La plateforme gère :

- fichiers CSV,
- API REST,
- ERP partenaires,
- flux Event Hubs.

## Standardisation d’un pipeline multi-source


flowchart TD
  Source1(API) --> A[Data Factory]
  Source2(CSV) --> A
  Source3(EventHub) --> A
  A --> Raw[Storage RAW]
  Raw --> Curated[Transformation]
  Curated --> Serve[Zone Serve]
