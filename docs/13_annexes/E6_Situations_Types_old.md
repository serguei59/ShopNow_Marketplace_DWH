# 📦 Étude de Cas E6 – Marketplace ShopNow  
## 🎭 Scénarios Fictifs Concrets Illustrant les Évolutions du DWH  
*(Version prête pour GitHub — à intégrer dans `/docs/` ou `/E6/`)*

---

# 🧩 Objectif du document

Ce document fournit **des situations fictives, réalistes et cohérentes**, qui illustrent :

- pourquoi les évolutions proposées sont nécessaires,
- comment chaque outil Azure intervient (ADF, Event Hubs, SQL, Stream Analytics…),
- comment chaque élément améliore la maintenabilité (MCO),
- comment tout cela répond aux compétences **C16 / C17**.

---

# 🧪 1. Scénarios Concrets – Ingestion & ETL Marketplace

## 📚 Scénario 1 — Un vendeur tiers envoie chaque nuit un CSV produit (Flux Fichier → ADF)

### 🎬 Situation simulée
Le vendeur **Vendor_X** envoie chaque nuit un fichier :

products_vendourX_2025-03-12.csv


Contenu :
- SKU vendeur
- Prix
- Stock
- Description
- Catégorie
- Champs libres parfois absents ou mal nommés

### 🔧 Processus
1. Le fichier tombe dans **ADLS /raw/vendor_x/**.
2. Un pipeline **Azure Data Factory** se déclenche automatiquement.
3. Le pipeline :
   - vérifie la conformité (schéma, colonnes obligatoires)
   - applique les règles de nettoyage
   - identifie les incohérences (prix < 0, absence de SKU)
   - charge les données propres dans **/clean/vendor_x/**
   - charge les anomalies dans **/reject/vendor_x/**

### 🎁 Valeur :
- ingestion fiable
- gestion multi-formats
- possibilité d’opérations complexes (mapping, normalisation)

### 📌 Compétences couvertes
- **C16.7 – gestion fichiers hétérogènes**
- **C16.5 – qualité des données**
- **C17.4 – ETL adaptés aux SCD**

---

# 🔌 Scénario 2 — Un vendeur expose une API stock (Flux API → ADF + Azure Functions)

### 🎬 Situation simulée
Un vendeur *Premium* expose une API :

GET https://api.vendor_premium.com/stock?updated_since=5mn


### 🔧 Processus
1. ADF appelle périodiquement l’API.
2. Une **Azure Function** convertit la réponse JSON :
   - correction des formats de date
   - résolution des unités (kg → g)
   - gestion des champs manquants
3. Les données sont poussées dans :
   - `/raw/api_vendor_premium/`
   - puis `/clean/api_vendor_premium/`
4. Enfin elles alimentent la table **fact_vendor_stock** dans le DWH.

### 🎁 Valeur :
- ingestion API industrialisée
- standardisation des schémas
- capacité à gérer 10, 100 ou 300 vendeurs API

### 📌 Compétences couvertes
- **C16.7 – gestion API vendeurs**
- **C16.6 – intégration hétérogène**
- **C17.2 – adaptation modèle de données**

---

# ⚡ Scénario 3 — Stock mis à jour en temps réel (Event Hubs → Stream Analytics)

### 🎬 Situation simulée
Les vendeurs “Premium+” envoient des messages d’événements à ShopNow :

{
"vendorId": 14,
"productId": 8876,
"stockLevel": 18,
"timestamp": "2025-03-12T14:23:10Z"
}


### 🔧 Processus
1. Les messages arrivent dans **Event Hubs**.
2. **Azure Stream Analytics** :
   - applique une transformation SQL-like
   - joint les données avec dim_product
   - détecte les incohérences (stock négatif)
   - insère directement dans :
     - `fact_vendor_stock`
     - `fact_data_quality` (si anomalie détectée)

### 🎁 Valeur :
- mise à jour instantanée
- détection des erreurs en streaming
- centralisation dans le DWH

### 📌 Compétences couvertes
- **C16.7 – gestion streaming Event Hubs**
- **C17.2 – adaptation aux nouvelles sources**
- **C17.3 – cohérence analytique**

---

# 📊 2. Scénarios Concrets — Modèle de Données & SCD

## 🧩 Scénario 4 — Le vendeur change de statut (SCD2)
### 🎬 Situation simulée
Le vendeur *Vendor_X* passe :

**Actif → Suspendu**

Champs impactés :
- statut
- score qualité
- SLA non respecté

### 🔧 Processus
1. L’ETL détecte le changement.
2. La ligne précédente dans **dim_vendor** est fermée :

Date_expiration = 2025-03-12
IsCurrent = 0

3. Une novelle ligne est créée:

Date_effective = 2025-03-12
IsCurrent = 1
Statut = "Suspended"


### 🎁 Valeur :
- analyse temporelle
- auditabilité
- conformité Marketplace

### 📌 Compétences couvertes
- **C17.4 – gestion SCD2**
- **C17.1 – adaptation des dimensions**

---

# 🛡️ 3. Scénarios Concrets — Sécurité & RLS

## 🔐 Scénario 5 — Un vendeur accède à Power BI

### 🎬 Situation simulée
Vendor_Y veut consulter :

- ses ventes
- ses stocks
- son score qualité

**Il ne doit pas voir les autres vendeurs**.

### 🔧 Processus
1. RLS est appliqué :

VendorID = USERPRINCIPALNAME()


2. Les dashboards :
   - filtrent automatiquement
   - sont multi-tenant sans duplication

### 🎁 Valeur :
- sécurité
- conformité
- simplicité d’exploitation

### 📌 Compétences couvertes
- **C16.4 – sécurité et cloisonnement des données**

---

# 🛠️ 4. Scénarios MCO — Maintenance & Monitoring

## 📟 Scénario 6 — Une API vendeur est en panne

### 🎬 Situation simulée
L’API Vendor_Premium ne répond plus (erreur 503).

### 🔧 Processus
1. ADF détecte l’erreur.
2. Azure Monitor génère une alerte.
3. Un runbook ou un ticket automatique est créé.
4. Les données manquantes sont rechargées via un job de rattrapage.

### 🟢 Ce que démontre ce scénario
- robustesse
- capacité de reprise sur incident
- supervision intégrée

---

## 📛 Scénario 7 — Anomalies massives dans les fichiers d’un vendeur

### 🎬 Situation simulée
Le vendeur VendorBadQuality envoie :

- 42 % de prix manquants
- 18 % de catégories non reconnues
- 650 produits dupliqués

### 🔧 Processus
1. Le process qualité charge automatiquement les anomalies dans :
   - `fact_data_quality`
2. Son **score qualité** dans dim_vendor baisse.
3. Un dashboard expose :

| KPI | Valeur |
|-----|--------|
| % anomalies | 42% |
| Score qualité | 45/100 |

4. Une alerte est envoyée à l’équipe Vendor Management.

---

# 🧰 5. Outils Résumés & Leur Rôle Concret

| Outil Azure | Rôle | Apport Marketplace |
|------------|------|--------------------|
| **ADF** | ingestion fichiers + API | gère hétérogénéité, qualité |
| **Azure Functions** | nettoyage avancé API | standardise formats |
| **Event Hubs** | ingestion temps réel | stock en streaming |
| **Stream Analytics** | pipeline streaming | transformation + détection anomalies |
| **SQL Database (DWH)** | stockage structuré | modèle étoile étendu |
| **Log Analytics** | logs & MCO | supervision |
| **Azure Monitor** | alertes | SLA, incidents |
| **Terraform** | IaC | réplicabilité & audit |

---

# 🏁 Conclusion

Ces scénarios démontrent :
- la pertinence des outils Azure choisis,
- leur impact direct sur la transformation Marketplace,
- la cohérence avec les compétences **C16 / C17**,
- la capacité à maintenir, sécuriser et faire évoluer un DWH multi-sources.


---

# 📎 Fin du fichier
