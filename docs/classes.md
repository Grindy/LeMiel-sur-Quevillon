# Diagramme de classes — LeMiel-sur-Quévillon

Version 1.1. Tous les montants sont en cents (`Int`). Le schéma Prisma correspondant est dans `prisma/schema.prisma` ; les attributs, relations et choix de modélisation sont décrits à la section 9 du cahier des charges.

Légende : `*--` composition (la partie disparaît avec le tout), `-->` association. Les champs suivis de `?` sont optionnels.

```mermaid
classDiagram
  direction LR

  class Utilisateur {
    -String id
    -String? clerkId
    -String prenom
    -String nom
    -String courriel
    -String? telephone
    -Role role
    -String? stripeCustomerId
    -DateTime? anonymiseLe
    -DateTime creeLe
    -DateTime modifieLe
    +anonymiser() void
    +estAmiDuRucher() Boolean
  }

  class Adresse {
    -String id
    -String utilisateurId
    -String ligne1
    -String? ligne2
    -String ville
    -String province
    -String codePostal
    -Boolean parDefaut
    -DateTime creeLe
    +estLivrable() Boolean
  }

  class Panier {
    -String id
    -String utilisateurId
    -DateTime creeLe
    -DateTime modifieLe
    +prixTotalEnCents() Int
    +ajouterAuPanier(produit: Produit, quantite: Int) ProduitPanier
    +retirerDuPanier(produitId: String) void
    +modifierQuantite(produit: Produit, quantite: Int) ProduitPanier
    +vider() void
  }

  class ProduitPanier {
    -String panierId
    -String produitId
    -Int quantite
    -DateTime ajouteLe
  }

  class Produit {
    -String id
    -String nom
    -String description
    -String format
    -Int prixEnCents
    -Int quantiteDisponible
    -Saison saison
    -Int annee
    -String? imageUrl
    -StatutTaxe statutTaxe
    -StatutProduit statut
    -DateTime? epuiseLe
    -DateTime creeLe
    -DateTime modifieLe
    +estDisponible(quantite: Int) Boolean
    +deduireStock(quantite: Int) void
    +remettreStock(quantite: Int) void
    +publier() void
  }

  class Commande {
    -String id
    -Int numero
    -String utilisateurId
    -String? adresseId
    -String? codePromoId
    -StatutCommande statut
    -String livraisonNom
    -String livraisonTelephone
    -String livraisonLigne1
    -String? livraisonLigne2
    -String livraisonVille
    -String livraisonCodePostal
    -Int sousTotalEnCents
    -Int rabaisEnCents
    -Int tpsEnCents
    -Int tvqEnCents
    -Int totalEnCents
    -String? stripeCheckoutSessionId
    -String? stripePaymentIntentId
    -DateTime expireLe
    -DateTime? payeeLe
    -DateTime creeLe
    +calculerTotaux() void
    +marquerPayee() void
    +annuler() void
  }

  class LigneCommande {
    -String id
    -String commandeId
    -String produitId
    -Int quantite
    -Int prixUnitaireEnCents
    -String nomProduit
    -String formatProduit
    -Saison saison
    -Int annee
    -StatutTaxe statutTaxe
    -Int rabaisEnCents
    -Int tpsEnCents
    -Int tvqEnCents
    +sousTotalEnCents() Int
  }

  class CodePromo {
    -String id
    -String code
    -Int pourcentage
    -DateTime expireLe
    -Int? utilisationsMax
    -Int utilisations
    -Boolean reserveAmis
    -Boolean actif
    -DateTime creeLe
    +estValide(utilisateur: Utilisateur) Boolean
    +rabaisEnCents(montantEnCents: Int) Int
  }

  class Abonnement {
    -String id
    -String utilisateurId
    -String stripeSubscriptionId
    -String stripePriceId
    -StatutAbonnement statut
    -DateTime finPeriodeCourante
    -Boolean annuleFinPeriode
    -DateTime? graceJusquA
    -DateTime creeLe
    -DateTime modifieLe
    +donneAcces() Boolean
  }

  class EvenementWebhook {
    -String id
    -String type
    -DateTime recuLe
  }

  class Role {
    <<enumeration>>
    CLIENT
    ADMINISTRATEUR
  }

  class StatutProduit {
    <<enumeration>>
    BROUILLON
    EN_STOCK
    EPUISE
  }

  class StatutTaxe {
    <<enumeration>>
    TAXABLE
    NON_TAXABLE
  }

  class Saison {
    <<enumeration>>
    PRINTEMPS
    ETE
    AUTOMNE
    HIVER
  }

  class StatutCommande {
    <<enumeration>>
    EN_ATTENTE
    PAYEE
    ANNULEE
    REMBOURSEE
  }

  class StatutAbonnement {
    <<enumeration>>
    ACTIF
    EN_RETARD
    IMPAYE
    ANNULE
    INCOMPLET
  }

  Utilisateur "1" *-- "0..*" Adresse : 1 — 0..*
  Utilisateur "1" *-- "0..1" Panier : 1 — 0..1
  Panier "1" *-- "0..*" ProduitPanier : 1 — 0..*
  Produit "1" <-- "0..*" ProduitPanier : 1 — 0..*
  Utilisateur "1" <-- "0..*" Commande : 1 — 0..*
  Adresse "0..1" <-- "0..*" Commande : 0..1 — 0..*
  Commande "1" *-- "1..*" LigneCommande : 1 — 1..*
  Produit "1" <-- "0..*" LigneCommande : 1 — 0..*
  Utilisateur "1" -- "0..1" Abonnement : 1 — 0..1
  CodePromo "0..1" <-- "0..*" Commande : 0..1 — 0..*
```

`EvenementWebhook` n'a pas de relation : c'est un registre des événements Stripe déjà traités (RM-14).
