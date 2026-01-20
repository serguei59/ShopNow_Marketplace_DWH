# Résumé du contexte Marketplace

ShopNow évolue d’un modèle interne (vendeur unique) vers une **Marketplace multi-vendeurs**.

Cette transformation implique :

- l’intégration de vendeurs tiers,
- la diversification des formats sources (CSV, Excel, API),
- une complexification des données produit et stock,
- de nouvelles exigences réglementaires (sécurité, accès, RLS),
- la nécessité d’historiser les variations vendeurs/produits,
- la gestion de la qualité des données en amont,
- l’adaptation du Data Warehouse existant.

L’entrepôt doit désormais :
- absorber de nouvelles sources,
- rester fiable,
- historiser les évolutions métiers,
- garantir un cloisonnement strict par vendeur,
- fournir des KPIs cohérents malgré l’hétérogénéité.

→ Ces besoins correspondent précisément aux compétences C16 (MCO) et C17 (SCD).  
