# 7.3 Situation DRP

## Démarche
- Réplication géographique
- Plan de restauration automatisé
- Sauvegarde GRS/RA-GRS

## 🖼️ Capture recommandée
- Paramétrage GRS du Storage Account

flowchart LR
  A[Zone primaire] -->|Réplication| B[Zone secondaire]
  B --> C[Activation DRP]
  C --> D[Reprise services]
