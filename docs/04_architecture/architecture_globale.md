# 8. Architecture globale

# Architecture globale

Voici l'architecture cible complète.

## Composants :
- Azure Storage
- Data Factory
- Event Hubs
- Azure Functions
- Log Analytics
- Azure Monitor
- Key Vault
- Power BI

flowchart LR
  A[Sources multi-fournisseur] --> B[Event Hubs]
  A --> C[Data Factory]
  B --> C
  C --> D[Raw]
  D --> E[Curated + SCD2]
  E --> F[Serve / Power BI]
  C --> G[Log Analytics]
  G --> H[Monitor / Alerting]
  C --> I[Key Vault]

========================
trier

## Vue d’ensemble

```mermaid
flowchart LR
    A[Sources externes] --> EH(Event Hubs)
    EH --> ADF(Data Factory)
    ADF --> RAW(Raw Zone)
    RAW --> CUR(Curated Zone)
    CUR --> SERVE(Serve)
    SERVE --> PBI(Power BI)


---

# ────────────────────────────────────────────  
# 📁 docs/04_architecture/schema_mermaid.md  
# ────────────────────────────────────────────

```md
# 9. Schéma d’architecture (Mermaid)

```mermaid
graph TD
    subgraph Ingestion
        API-->ADF
        EventHubs-->ADF
        Blob-->ADF
    end

    ADF-->Raw
    Raw-->Curated
    Curated-->Serve
    Serve-->PowerBI
 
---

# ────────────────────────────────────────────  
# 📁 docs/04_architecture/schema_deploiement_terraform.md  
# ────────────────────────────────────────────

```md
# 10. Schéma de déploiement Terraform

```mermaid
flowchart TD
    TF(Terraform) --> RG(Resource Groups)
    TF --> SA(Storage Accounts)
    TF --> ADF(Data Factory)
    TF --> EH(Event Hubs)
    TF --> VNET(VNET + NSG)


---

# =============================================  
# 05_socle_MCO  
# =============================================  

(⏳ pour garder ce message lisible, je ne colle pas ici les 30 fichiers restants — confirme-moi : **veux-tu que je continue maintenant avec 05_SOCLE_MCO → 13_ANNEXES d’un seul bloc ?**)
