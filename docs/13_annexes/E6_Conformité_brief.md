# Vérification de la conformité aux exigences du brief Marketplace

Ce document démontre que les propositions techniques, les situations fictives et le socle MCO conçu pour E6 répondent **intégralement** aux exigences du brief Marketplace.

---

# 🎯 1. Suivi des vendeurs dans le temps  
### Exigence du brief  
Les vendeurs disposent de données évolutives (profil, statut, catégorie) et ces évolutions doivent être historisées et exploitables.

### Réponse apportée par le projet  
| Composant | Contribution |
|----------|--------------|
| **SCD2 vendeur** | Conserve toutes les versions historiques des attributs vendeurs. |
| **Situation : "Changement d’adresse vendeur"** | Scénario montrant l’ajout automatique d’une nouvelle version + fermeture de l’ancienne. |
| **Zone CURATED structurée** | Organisation des données pour faciliter l’usage analytique historique. |
| **Contrôles ETL normalisés** | Garantissent la bonne application des règles SCD. |

➡️ **Exigence couverte à 100 %.**

---

# 🎯 2. Qualité des données envoyées par les vendeurs tiers  
### Exigence du brief  
Les vendeurs envoient des données incohérentes ou incomplètes.  
L’entreprise doit identifier, isoler et fiabiliser ces données.

### Réponse apportée par le projet  
| Composant | Contribution |
|----------|--------------|
| **Zone REJECT** | Stockage isolé des lignes invalides, auditables. |
| **Tests de qualité (comptages / règles métier)** | Permettent d’identifier anomalies, doublons, valeurs manquantes. |
| **Logs ETL + alertes** | Déclenchent un signal au support lors de dérives. |
| **Situation : "Flux vendeur qui envoie un stock négatif"** | Exemples concrets et exploitables pour la rédaction du rapport. |
| **Normalisation des schémas vendeurs** | Assure une cohérence analytique malgré la variété des formats. |

➡️ **Exigence couverte à 100 %.**

---

# 🎯 3. Intégration de nouvelles sources externes  
### Exigence du brief  
ShopNow veut intégrer de nouvelles informations (stocks, disponibilités, updates produits), souvent via API externes ou systèmes hétérogènes.

### Réponse apportée par le projet  
| Composant | Contribution |
|----------|--------------|
| **Ingestion API → Event Hub → stockage** | Permet de gérer des sources non maîtrisées. |
| **Situation : "API vendeur non fiable"** | Gestion des timeouts, retries, datation, logs. |
| **Event Hub & Stream Analytics** | Adaptés aux flux temps réel et semi-temps réel. |
| **Connecteurs fichiers (CSV, JSON, Excel)** | Permettent d’absorber les sources hétérogènes classiques. |
| **Pipeline unifié RAW → CLEAN → CURATED** | Assure cohérence et homogénéité analytique. |

➡️ **Exigence couverte à 100 %.**

---

# 🎯 4. Sécurité et cloisonnement des données  
### Exigence du brief  
Les vendeurs doivent accéder uniquement à leurs données.  
Les équipes internes doivent conserver une vision globale.

### Réponse apportée par le projet  
| Composant | Contribution |
|----------|--------------|
| **RBAC vendeur (niveau dossier et tables)** | Cloisonnement par ID vendeur. |
| **Exemples : "vendeur A ne voit pas vendeur B"** | Cas simulé, facile à présenter à l’oral. |
| **Stockage structuré par partition vendeur_id=xxx** | Cloisonnement physique + logique. |
| **Log d’accès / audit** | Suivi et traçabilité des consultations. |
| **Key Vault / secrets non exposés** | Pratique obligatoire en contexte Marketplace multi-tenant. |

➡️ **Exigence couverte à 100 %.**

---

# 🎯 5. Objectif global du brief  
> *Analyser l’impact, évaluer les limites, proposer adaptations, garantir qualité, disponibilité, sécurité, cohérence dans un contexte Marketplace.*

### Correspondance complète avec ton projet

| Objectif du brief | Réponse du projet |
|-------------------|-------------------|
| **Analyser l’impact Marketplace** | Analyse critique : variabilité vendeurs, qualité disparate, montée en charge, besoin d’historisation, sécurité multi-tenant. |
| **Évaluer les limites et risques** | Identifiés : absence de SCD, pas de cloisonnement, qualité non contrôlée, ingestion non extensible. |
| **Proposer adaptations structurelles** | Modèle SCD vendeur, zones RAW/CLEAN/CURATED/REJECT, normalisation vendeurs, cloisonnement RBAC. |
| **Proposer adaptations techniques** | Event Hub, pipelines modifiés, API ingestion, monitoring complet. |
| **Assurer qualité et disponibilité** | QA, alerting, supervision, REJECT, SCD, documentation opérationnelle. |
| **Cohérence analytique multi-vendeurs** | Normalisation + CURATED aligné sur modèle commun + validation schémas. |

➡️ **Le socle + les scénarios couvrent intégralement le brief Marketplace.**

---

# ✔️ Conclusion  
Le projet proposé :  

- répond **complètement** au **brief officiel Marketplace**,  
- couvre **100 % des compétences C16 et C17**,  
- repose sur un **socle solide de MCO**,  
- offre des **évolutions facultatives mais fortement valorisantes**,  


