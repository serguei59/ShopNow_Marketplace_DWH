# 7.1 Situation MCO (supervision & logs)

## Contexte
Le MCO est essentiel pour garantir la fiabilité de la plateforme.

## Actions réalisées
- Mise en place de logs centralisés.
- Création d’alertes SLA.
- Mise en place d’un tableau de bord global de supervision.

## 🖼️ Capture recommandée
- Interface Azure Monitor (overview)
- Logs filtrés par pipeline

flowchart TD
  A[Pipeline ADF] --> B[Logs vers Log Analytics]
  B --> C[Alertes Azure Monitor]
  C --> D[Envoi Email / Teams]
  B --> E[Dashboard MCO]
