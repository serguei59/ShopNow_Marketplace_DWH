# Référence technique — Lot 1 : Socle C16 (Maintenance en Condition Opérationnelle)

**Projet :** E6 – DWH ShopNow Marketplace
**Auteur :** Serge Buasa
**Date :** 2026-03-11
**Certification :** RNCP 37638 – Expert en infrastructures de données massives
**Compétence couverte :** C16 – Gérer l'entrepôt de données (supervision, RGPD, backups, accès, documentation)

---

## Architecture de référence

```
Event Hubs (eh-sbuasa)
  orders / products / clickstream
      │
      ▼
Stream Analytics Job (continu, 1 streaming unit)
      │
      ▼
Azure SQL Database S0
  dwh-shopnow
  sql-server-rg-e6-sbuasa.database.windows.net
      │
      ├─ dim_customer   (PII : name, email, address)
      ├─ dim_product
      ├─ fact_order     (PII indirect : customer_id)
      └─ fact_clickstream (PII : user_id, ip_address)

Resource Group : rg-e6-sbuasa
Région         : francecentral
IaC            : Terraform (azurerm v4.54.0)
```

---

## Phase préliminaire — Déploiement de la plateforme

> Ces étapes ne sont pas des livrables C16 mais des **prérequis techniques** sans lesquels aucun artefact de monitoring, backup ou sécurité ne peut être validé en conditions réelles.

### P1 — Corriger les chemins Terraform et la subscription

| Fichier | Correction |
|---------|-----------|
| `terraform/1_main.tf` | `./modules/` → `../modules/` (×4) + `${path.root}/dwh_schema.sql` → `${path.root}/../dwh_schema.sql` |
| `terraform/terraform.tfvars` | `subscription_id` → `51a5ea3c-2ada-4f97-b2a1-a26eda3b14f2` (subscription personnelle) |

Contexte : les modules Terraform sont à la racine du projet (`modules/`) et non dans `terraform/modules/`. Le fichier `1_main.tf` référençait des chemins relatifs incorrects. La subscription école (`029b3537...`) a expiré après 90 jours d'inactivité.

Voir détail : [docs/09_terraform/plan_deploiement.md](../docs/09_terraform/plan_deploiement.md)

### P2 — Déployer l'infrastructure

```bash
cd terraform/
terraform init
terraform plan
terraform apply   # ~10-15 min
```

Ressources créées dans `rg-e6-sbuasa` (francecentral) :
- Event Hubs namespace `eh-sbuasa` + hubs orders/products/clickstream
- SQL Server `sql-server-rg-e6-sbuasa` + base `dwh-shopnow` (S0, schéma initialisé)
- Stream Analytics job `asa-shopnow` (démarré automatiquement)
- ACI `aeh-producers` (producteurs Python actifs)

### P3 — Reconstruire l'image Docker des producers

L'image `sengsathit/event_hub_producers:latest` (prof) est privée/supprimée. Image reconstruite depuis les sources locales et publiée sur DockerHub :

```bash
cd _events_producers/
docker build --network=host -t blackphoenix2020/event_hub_producers:latest .
docker push blackphoenix2020/event_hub_producers:latest
# Puis : terraform apply -target=module.container_producers
```

**Statut :** [x] P1 corrigé / [x] P2 déployé / [x] P3 image reconstruite (2026-03-11)

---

## Principes d'ordonnancement

1. **Dépendance logique** — un artefact référencé vient après sa création
2. **Conception avant implémentation** — schedule avant scripts, SLA avant alertes
3. **Code avant documentation** — les pages docs/ décrivent ce qui existe
4. **Fondation légale en premier** — RGPD et RBAC conditionnent toutes les décisions suivantes

---

## Cartographie critères C16 → étapes

| Critère C16 | Étapes |
|-------------|--------|
| Journalisation catégorisée alertes/erreurs | 5, 6, 19 |
| Système d'alerte activé | 10, 20 |
| Tâches priorisées selon SLA | 22 |
| Tâches assignées (RACI) | 22 |
| Indicateurs basés sur SLA | 7, 9, 20 |
| Tableau de bord indicateurs | 9, 20 |
| Backup complet planifié et fonctionnel | 12, 13, 21 |
| Backup partiel planifié et fonctionnel | 12, 14, 21 |
| Documentation cas d'usage (sources, accès, stockage) | 19, 20, 21, 22, 23, 24 |
| Nouvelles sources configurées + ETL à jour | 19 (référence), Lot 3 |
| Nouveaux accès configurés conformément | 2, 24 |
| Registre RGPD complet | 1 |
| Procédures tri données personnelles | 3 |
| Traitements conformité avec fréquence | 3 |

---

## Roadmap détaillée — 26 étapes

---

### PHASE 0 — Fondation légale et gouvernance des accès

---

#### Étape 1 — `security/rgpd/registre_traitements.md`
- **Statut :** [x] Fait — 2026-03-11
- **Critère C16 :** Registre des traitements de données personnelles (art. 30 RGPD)
- **Contenu :**
  - Traitement 1 : Commandes clients — `dim_customer` + `fact_order` — base légale contrat — 10 ans
  - Traitement 2 : Clickstream — `fact_clickstream` — base légale intérêt légitime — 13 mois (CNIL)
  - Traitement 3 : Vendeurs tiers (anticipé C17) — `dim_vendor` — base légale contrat
  - Tableau des droits des personnes (accès, rectification, effacement, portabilité, opposition)
- **Justification jury :** Critère binaire C16 — absent = compétence non validée. Placé en 1er pour signaler que la conformité est une posture, pas un ajout tardif.
- **Dépendances :** Aucune

---

#### Étape 2 — `security/rbac/rbac_mapping.md`
- **Statut :** [x] Fait — 2026-03-11
- **Critère C16 :** Nouveaux accès configurés conformément au besoin
- **Contenu :**
  - Matrice 5 rôles × (Azure RBAC role, SQL permission, périmètre données, MFA requis)
  - Rôles : Admin, Data Engineer, Data Steward, MCO, Vendeur
  - Azure roles : Owner, Contributor, Reader, Custom
  - SQL permissions : db_owner, db_datareader, db_datawriter, SELECT sur vues filtrées
  - Script exemple : création login SQL vendeur avec accès restreint
- **Justification jury :** Le RBAC mapping est requis avant les scripts de backup (qui exécute ?) et avant la doc d'accès. Prouve la conception délibérée des droits.
- **Dépendances :** Étape 1 (le registre identifie qui accède à quoi)

---

#### Étape 3 — `security/rgpd/procedures_conformite.md`
- **Statut :** [x] Fait — 2026-03-11 (fichier : `procédures conformite.md`)
- **Critère C16 :** Procédures de tri des données personnelles + traitements de conformité avec fréquence
- **Contenu :**
  - Procédure anonymisation `fact_clickstream` (purge J+13 mois)
  - Procédure droit à l'effacement `dim_customer` (pseudonymisation ou suppression)
  - Procédure droit à la portabilité (export JSON client)
  - Procédure droit de rectification (`dim_customer`)
  - Tableau des fréquences : purge mensuelle, audit trimestriel, revue annuelle registre
- **Justification jury :** C16 distingue le registre (what) des procédures (how + when). Les deux sont évalués séparément. Les fréquences sont un critère C16 explicite.
- **Dépendances :** Étapes 1 et 2

---

#### Étape 4 — `security/README.md`
- **Statut :** [x] Fait — 2026-03-11
- **Critère C16 :** Documentation structurée
- **Contenu :** Index du dossier security/, références aux fichiers, contexte légal (RGPD art. 30, CNIL)
- **Justification jury :** Point d'entrée du dossier sécurité pour le jury. Signal de rigueur organisationnelle.
- **Dépendances :** Étapes 1, 2, 3

---

### PHASE 1 — Observabilité (monitoring/queries/)

---

#### Étape 5 — `monitoring/queries/log_errors_last24h.sql`
- **Statut :** [x] Fait — 2026-03-11
- **Critère C16 :** Journalisation catégorisée alertes et erreurs
- **Contenu (4 requêtes) :**
  - `sys.event_log` — connexions échouées, deadlocks, throttling (24h)
  - `sys.dm_exec_requests` — sessions bloquantes actives + temps d'attente
  - `sys.dm_db_resource_stats` — CPU/IO/log_write/mémoire avec seuils (ALERTE/ATTENTION/OK)
  - `sys.dm_exec_query_stats` — top 10 requêtes coûteuses
- **Justification jury :** Preuve directe et exécutable de la journalisation catégorisée. Le jury peut lire le SQL et voir les labels ALERTE/ATTENTION/OK dans les CASE WHEN.
- **Dépendances :** Aucune (Azure SQL natif)

---

#### Étape 6 — `monitoring/queries/data_freshness.sql`
- **Statut :** [x] Fait — 2026-03-11
- **Critère C16 :** Alertes ingestion ratée, supervision pipeline
- **Contenu (4 requêtes) :**
  - Vue consolidée fraîcheur par table (FRAIS / ATTENTION / STALE)
  - Alerte pipeline orders : 0 commande dans les 15 dernières minutes
  - Volume journalier J-7 (détection dérive tendancielle)
  - Détection doublons récents sur `fact_clickstream` (event_id non unique)
- **Justification jury :** Le risque silencieux numéro 1 d'une architecture streaming est le pipeline arrêté sans erreur visible. Cette requête prouve qu'on y a pensé et qu'on l'a instrumenté.
- **Dépendances :** Étape 5 (même pattern, approfondissement métier)

---

#### Étape 7 — `monitoring/queries/sla_availability.sql`
- **Statut :** [x] Fait — 2026-03-11
- **Critère C16 :** Indicateurs de service basés sur SLA
- **Contenu (3 requêtes) :**
  - Taux disponibilité par jour sur 30 jours (connexions ok/total depuis `sys.event_log`) + statut SLA OK/KO
  - Fraîcheur temps réel `fact_order` et `fact_clickstream` avec étiquettes SLA
  - Synthèse mensuelle KPI (rapport direction)
- **SLA cibles définis dans la requête :**
  - Disponibilité base : ≥ 99,9 % / mois
  - Latence `fact_order` : ≤ 5 min
  - Latence `fact_clickstream` : ≤ 2 min
- **Justification jury :** C16 exige "les indicateurs de service se basent sur les SLA". Cette requête est la matérialisation calculable des SLA — sans elle, les SLA restent de la rhétorique.
- **Dépendances :** Étapes 5 et 6

---

#### Étape 8 — `monitoring/queries/pipeline_latency.sql`
- **Statut :** [x] Fait — 2026-03-11
- **Critère C16 :** Indicateurs de service, performance pipeline
- **Contenu (3 requêtes) :**
  - Intervalle moyen entre insertions `fact_order` avec `LAG()` (latence min/max/écart-type sur 500 lignes)
  - Gaps clickstream > 10 s avec severité (ALERTE > 60s, ATTENTION > 30s)
  - Volume horaire J-7 comparé à la moyenne de la même heure (détection dégradation progressive)
- **Justification jury :** Signal de maturité Bac+5 — passage du monitoring réactif (alerte sur erreur) au monitoring prédictif (détection de dégradation avant rupture).
- **Dépendances :** Étapes 6 et 7

---

### PHASE 2 — Spécifications supervision (monitoring/dashboards/)

---

#### Étape 9 — `monitoring/dashboards/dashboard_sla_spec.md`
- **Statut :** [x] Fait — 2026-03-11
- **Critère C16 :** Tableau de bord permettant de rendre compte de l'ensemble des indicateurs de service
- **Contenu :**
  - 6 tiles Power BI : disponibilité %, latence fact_order, latence clickstream, taux erreurs connexion, volume journalier, statut SLA global
  - Seuils visuels : vert (OK) / orange (ATTENTION) / rouge (ALERTE) par tile
  - Source de données : Azure SQL DMV via DirectQuery ou Import (15 min refresh)
  - Filtres : période (7j / 30j), table source, statut SLA
  - Section "Vue MCO" (technique) vs "Vue Direction" (synthèse)
- **Justification jury :** Le jury n'a pas accès à Power BI. La spécification prouve que le candidat sait concevoir un tableau de bord, ce qui est suffisant en environnement de test.
- **Dépendances :** Étapes 5 à 8 (les tiles référencent les requêtes)

---

#### Étape 10 — `monitoring/dashboards/alert_rules_spec.md`
- **Statut :** [x] Fait — 2026-03-11
- **Critère C16 :** Système d'alerte mis en place et activé en cas d'erreur notifiée dans les journaux
- **Contenu :**
  - 6 règles Azure Monitor Alert avec : nom, condition, seuil, fenêtre, fréquence évaluation, sévérité, destinataire, action
  - Règles : CPU > 80%, DTU > 90%, connexions échouées > 10/5min, fraîcheur fact_order > 10min, fraîcheur clickstream > 5min, stockage > 80%
  - Action Groups : email MCO, email Data Engineer, webhook Slack (optionnel)
  - Procédure de création Azure CLI (az monitor metrics alert create)
- **Justification jury :** C16 : "un système d'alerte est mis en place et activé en cas d'erreur notifiée dans les journaux". La spec Azure Monitor est la preuve concrète en environnement de test.
- **Dépendances :** Étape 9 (seuils alignés avec les tiles du dashboard)

---

#### Étape 11 — `monitoring/README.md`
- **Statut :** [x] Fait — 2026-03-11
- **Critère C16 :** Documentation structurée par cas d'usage
- **Contenu :** Index du dossier, description des 6 requêtes et 2 spécifications, contexte technique Azure SQL, ressources de référence
- **Dépendances :** Étapes 5 à 10

---

### PHASE 3 — Backups (sql/backups/)

---

#### Étape 12 — `sql/backups/backup_schedule.md`
- **Statut :** [ ] À faire
- **Critère C16 :** Tâches planifiées de backup programmées et configurées
- **Contenu :**
  - Tableau planning : Full BACPAC hebdo (dimanche 02h00), LTR mensuel (1er du mois), LTR annuel (1er janvier)
  - RPO cible : < 15 minutes (PITR natif Azure SQL toutes les 5-12 min)
  - RTO cible : < 2 heures (restauration PITR depuis le portail)
  - Stockage cible : Azure Blob Storage `stshopnowbackup` / container `sql-backups/`
  - Rétentions : PITR 35 jours, BACPAC 12 mois, LTR annuel 5 ans
  - Responsable exécution : Data Engineer (voir RBAC étape 2)
- **Justification jury :** Conception avant implémentation — le schedule prouve que les choix de rétention sont délibérés et conformes aux obligations légales (RGPD + durée fiscale).
- **Dépendances :** Étape 1 (durées de conservation RGPD), Étape 2 (responsable)

---

#### Étape 13 — `sql/backups/backup_full.sh`
- **Statut :** [ ] À faire
- **Critère C16 :** Backup complet planifié et configuré, résultats attendus produits
- **Contenu :** Script Azure CLI — `az sql db export` vers Azure Blob Storage (BACPAC), avec variables d'environnement pour les credentials, log de résultat, notification email en cas d'échec
- **Note technique :** Azure SQL Database (non Managed Instance) ne supporte pas `BACKUP DATABASE TO DISK`. Le BACPAC via `az sql db export` est l'équivalent du backup complet portable.
- **Justification jury :** Script exécutable, commenté, référençant le schedule (étape 12). Preuve directe et vérifiable du backup complet.
- **Dépendances :** Étape 12

---

#### Étape 14 — `sql/backups/backup_ltr_config.sh`
- **Statut :** [ ] À faire
- **Critère C16 :** Backup partiel planifié et configuré
- **Contenu :** Script Azure CLI — `az sql db ltr-policy set` pour configurer Long-Term Retention (4 semaines, 12 mois, 5 ans) + `az sql db ltr-backup list` pour vérifier les backups existants
- **Justification jury :** Le LTR est la réponse Azure SQL au backup différentiel/partiel. Utiliser la solution native prouve la maîtrise de la plateforme.
- **Dépendances :** Étape 12

---

#### Étape 15 — `sql/backups/restore_procedure.sh`
- **Statut :** [ ] À faire
- **Critère C16 :** Les tâches planifiées produisent les résultats attendus (inclut la restauration)
- **Contenu :** Deux cas de restauration :
  - PITR (Point-In-Time Restore) — `az sql db restore` — pour corruption ou suppression récente (≤ 35j)
  - Restauration depuis BACPAC — `az sql db import` — pour restauration inter-environnement ou au-delà de 35j
- **Justification jury :** Un backup sans restauration documentée et testable n'a aucune valeur opérationnelle. Le jury cherche précisément cette rigueur.
- **Dépendances :** Étapes 13 et 14

---

### PHASE 4 — Maintenance SQL (sql/maintenance/)

---

#### Étape 16 — `sql/maintenance/check_integrity.sql`
- **Statut :** [ ] À faire
- **Critère C16 :** Tâches de maintenance priorisées selon objectifs
- **Contenu :**
  - Vérification intégrité logique : comptages, orphelins (fact_order sans dim_customer), valeurs nulles critiques
  - Statistiques tables : taille, nombre de lignes, date dernière mise à jour stats
  - Espace disque : `sys.dm_db_partition_stats`, utilisation vs limite S0 (2 GB)
  - Requête de santé globale : score de cohérence 0-100
- **Justification jury :** Maintenance préventive — on vérifie avant de sauvegarder (un backup de données corrompues est inutile). Cohérent avec la posture MCO.
- **Dépendances :** Aucune

---

#### Étape 17 — `sql/maintenance/index_maintenance.sql`
- **Statut :** [ ] À faire
- **Critère C16 :** Tâches de maintenance — performance
- **Contenu :**
  - Analyse fragmentation : `sys.dm_db_index_physical_stats` — seuils 10% (REORGANIZE) / 30% (REBUILD)
  - Script conditionnel : REORGANIZE si < 30%, REBUILD si ≥ 30%, UPDATE STATISTICS systématique
  - Estimation durée et impact sur DTU (à planifier hors heures de charge)
- **Justification jury :** Complète le tableau de maintenance : on surveille (étapes 5-8), on sauvegarde (étapes 12-15), on entretient (étapes 16-17).
- **Dépendances :** Étape 16

---

#### Étape 18 — `sql/README.md`
- **Statut :** [ ] À faire
- **Critère C16 :** Documentation structurée
- **Contenu :** Index du dossier sql/, planning de maintenance, références scripts, note sur les spécificités Azure SQL
- **Dépendances :** Étapes 12 à 17

---

### PHASE 5 — Documentation exploitation (docs/)

---

#### Étape 19 — `docs/05_socle_MCO/supervision_logging.md`
- **Statut :** [ ] À faire (remplace stub 5 lignes)
- **Critère C16 :** Journalisation, documentation cas d'usage
- **Contenu :**
  - Architecture de logs : Azure SQL Event Log → DMV → Azure Monitor → Log Analytics
  - Catégories de logs : ERREUR (bloquant), ALERTE (dégradation), INFO (nominal)
  - Tableau des sources de logs avec fréquence et rétention
  - Procédure de consultation (étapes numérotées)
  - Références vers `monitoring/queries/` (4 fichiers)
  - Cas d'usage : diagnostic incident, rapport mensuel, audit RGPD
- **Dépendances :** Étapes 5 à 8

---

#### Étape 20 — `docs/05_socle_MCO/alerting_SLA.md`
- **Statut :** [ ] À faire (remplace stub 5 lignes)
- **Critère C16 :** SLA, système d'alerte, tableau de bord
- **Contenu :**
  - Tableau SLA formel : indicateur / cible / seuil alerte / seuil critique / fréquence mesure / responsable
  - Architecture alerting : Azure Monitor → Action Group → email/webhook
  - Référence vers `monitoring/dashboards/alert_rules_spec.md`
  - Référence vers `monitoring/dashboards/dashboard_sla_spec.md`
  - Procédure de réponse aux alertes (escalade)
- **Dépendances :** Étapes 7, 9, 10

---

#### Étape 21 — `docs/05_socle_MCO/backups_et_DRP.md`
- **Statut :** [ ] À faire (remplace stub 5 lignes)
- **Critère C16 :** Backups, documentation cas d'usage
- **Contenu :**
  - Architecture backup : PITR natif + BACPAC hebdo + LTR long terme
  - Tableau RPO/RTO par scénario (corruption logique, suppression accidentelle, perte région)
  - Planning des sauvegardes (référence `sql/backups/backup_schedule.md`)
  - Procédure de restauration (référence `sql/backups/restore_procedure.sh`)
  - Cas d'usage : restauration post-incident, migration environnement, test DRP
- **Dépendances :** Étapes 12 à 15

---

#### Étape 22 — `docs/05_socle_MCO/processus_MCO.md`
- **Statut :** [ ] À faire (remplace stub 10 lignes)
- **Critère C16 :** Tâches priorisées, tâches assignées (RACI)
- **Contenu :**
  - Matrice priorisation P1/P2/P3 : délais de prise en charge, délais résolution, escalade
    - P1 (critique) : pipeline arrêté, données inaccessibles → 15 min / 2h
    - P2 (majeur) : fraîcheur dégradée, backup échoué → 1h / 8h
    - P3 (mineur) : lenteur requête, fragmentation index → 4h / 48h
  - Matrice RACI (Responsable / Approbateur / Consulté / Informé) par type d'incident
  - Processus en 5 étapes : Détection → Qualification → Traitement → Reprocess → Clôture
  - Liens vers runbooks (Lot 3)
- **Dépendances :** Étapes 10 et 20 (niveaux SLA alignés avec alertes)

---

#### Étape 23 — `docs/07_securite/gestion_identites.md`
- **Statut :** [ ] À faire (remplace stub 3 lignes)
- **Critère C16 :** Accès configurés, documentation, RGPD
- **Contenu :**
  - Architecture Azure AD : groupes par rôle, MFA obligatoire pour Admin et Data Engineer
  - RBAC Azure : mapping rôle → Azure built-in role
  - SQL logins : logins nominatifs + login service Stream Analytics
  - Procédure de création d'accès (cas d'usage C16 explicite)
  - Lien vers registre RGPD (`security/rgpd/registre_traitements.md`)
  - Lien vers matrice RBAC (`security/rbac/rbac_mapping.md`)
- **Dépendances :** Étapes 1 et 2

---

#### Étape 24 — `docs/07_securite/roles_permissions.md`
- **Statut :** [ ] À faire (remplace stub 10 lignes)
- **Critère C16 :** Accès configurés conformément au besoin, documentation
- **Contenu :**
  - Matrice complète 5 rôles × permissions (transcription narrative du RBAC mapping)
  - Procédure de création d'un accès vendeur (étapes numérotées avec commandes SQL)
  - Procédure de révocation d'accès
  - Procédure d'audit des accès (requête SQL sur `sys.database_principals`)
  - Cas particulier : accès temporaire pour incident (durée limitée, traçabilité)
- **Dépendances :** Étape 2

---

### PHASE 6 — Synthèse rapport (docs_rapport/)

---

#### Étape 25 — `docs_rapport/05_socle_MCO/resume_socle_MCO.md`
- **Statut :** [ ] À faire (mise à jour avec ✅ et références)
- **Critère C16 :** Couverture complète dans le livrable certifiant
- **Contenu :**
  - Tableau des 14 critères C16 avec statut [x] et pointeur vers l'artefact
  - Résumé en 5 bullets par domaine : logging, alerting, backup, RGPD, accès
  - Référence aux dossiers `monitoring/`, `sql/`, `security/`
- **Dépendances :** Étapes 1 à 24

---

#### Étape 26 — `docs_rapport/07_securite/resume_securite.md`
- **Statut :** [ ] À faire (mise à jour avec références RGPD)
- **Critère C16 :** RGPD dans le livrable certifiant
- **Contenu :**
  - Résumé RBAC avec lien vers matrice
  - Résumé RGPD avec lien vers registre et procédures
  - Tableau cloisonnement vendeur (RLS + ADLS + Azure AD groups)
- **Dépendances :** Étapes 1 à 4

---

## Suivi d'avancement

| # | Fichier | Statut | Critère |
|---|---------|--------|---------|
| P1 | Corrections chemins Terraform + subscription_id | [x] | Prérequis infra |
| P2 | `terraform apply` — plateforme déployée | [x] | Prérequis infra |
| 1 | `security/rgpd/registre_traitements.md` | [ ] | RGPD registre |
| 2 | `security/rbac/rbac_mapping.md` | [ ] | RBAC accès |
| 3 | `security/rgpd/procedures_conformite.md` | [ ] | RGPD procédures |
| 4 | `security/README.md` | [ ] | — |
| 5 | `monitoring/queries/log_errors_last24h.sql` | [ ] | Journalisation |
| 6 | `monitoring/queries/data_freshness.sql` | [ ] | Alertes ingestion |
| 7 | `monitoring/queries/sla_availability.sql` | [ ] | SLA |
| 8 | `monitoring/queries/pipeline_latency.sql` | [ ] | Latence |
| 9 | `monitoring/dashboards/dashboard_sla_spec.md` | [ ] | Dashboard |
| 10 | `monitoring/dashboards/alert_rules_spec.md` | [ ] | Alerting |
| 11 | `monitoring/README.md` | [ ] | — |
| 12 | `sql/backups/backup_schedule.md` | [ ] | Planning backup |
| 13 | `sql/backups/backup_full.sh` | [ ] | Backup complet |
| 14 | `sql/backups/backup_ltr_config.sh` | [ ] | Backup partiel |
| 15 | `sql/backups/restore_procedure.sh` | [ ] | Restauration |
| 16 | `sql/maintenance/check_integrity.sql` | [ ] | Intégrité |
| 17 | `sql/maintenance/index_maintenance.sql` | [ ] | Index |
| 18 | `sql/README.md` | [ ] | — |
| 19 | `docs/05_socle_MCO/supervision_logging.md` | [ ] | Journalisation |
| 20 | `docs/05_socle_MCO/alerting_SLA.md` | [ ] | SLA alertes |
| 21 | `docs/05_socle_MCO/backups_et_DRP.md` | [ ] | Backup |
| 22 | `docs/05_socle_MCO/processus_MCO.md` | [ ] | RACI / P1P2P3 |
| 23 | `docs/07_securite/gestion_identites.md` | [ ] | Accès RGPD |
| 24 | `docs/07_securite/roles_permissions.md` | [ ] | RBAC |
| 25 | `docs_rapport/05_socle_MCO/resume_socle_MCO.md` | [ ] | C16 synthèse |
| 26 | `docs_rapport/07_securite/resume_securite.md` | [ ] | RGPD synthèse |

---

## Résultat attendu en fin de Lot 1

- **26 fichiers** créés ou mis à jour
- **100 % des critères C16** couverts avec artefacts concrets
- **Prérequis Lot 2 (C17)** satisfaits : registre RGPD prêt pour `dim_vendor`, backup documenté avant migration schéma
