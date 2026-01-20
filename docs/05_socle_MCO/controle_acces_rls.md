# RLS – Row Level Security

Exemple : limitation à un vendeur.

📌 Exemple DAX :
FILTER(Ventes, Ventes.Vendeur = USERPRINCIPALNAME())
