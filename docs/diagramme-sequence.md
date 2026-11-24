# Diagrammes de séquence — LeMiel-sur-Quévillon

Version 1.1. Les règles métier (RM) citées sont décrites à la section 7 du cahier des charges (`docs/cahier-des-charges.md`).

## 1. Achat de produits (paiement unique)

```mermaid
sequenceDiagram
  participant N as Navigateur
  participant S as Serveur Next.js
  participant BD as Base de données
  participant ST as Stripe
  N->>S: 1. POST /checkout (adresseId, code?)
  S->>BD: 2. lire le panier, les prix, le stock et l'adresse
  BD-->>S: lignes, prix, stock, adresse
  S->>S: 3. valider l'adresse (RM-03)
  opt code promo saisi
    S->>BD: 4. valider le code (RM-10, RM-06)
    BD-->>S: rabais
  end
  S->>BD: 5. transaction : Commande EN_ATTENTE + décrémenter le stock (RM-01)
  BD-->>S: ok
  S->>ST: 6. créer Checkout Session (total recalculé, commandeId)
  ST-->>S: 7. session.url
  S-->>N: 8. redirection vers Stripe
  N->>ST: 9. saisie de la carte (+ 3-D Secure)
  alt paiement réussi
    ST->>S: 10. webhook checkout.session.completed
    S->>S: 11. vérifier signature + idempotence
    S->>BD: 12. Commande = PAYEE, vider le panier (+ reçus)
    S-->>ST: 13. 200 OK
  else session expirée ou abandonnée
    ST->>S: 14. webhook checkout.session.expired
    S->>BD: 15. Commande = ANNULEE, produits remis en stock
  end
```

Le prix est recalculé par le serveur (RM-12) et seule la réception du webhook signé marque la commande payée (RM-15).

## 2. Échec de renouvellement de l'abonnement Amis du Rûcher

```mermaid
sequenceDiagram
  participant C as Client
  participant ST as Stripe
  participant S as Serveur Next.js
  participant BD as Base de données
  ST->>S: 1. webhook invoice.payment_failed
  S->>BD: 2. statut = EN_RETARD, graceJusquA = +7 jours
  S-)C: 3. courriel « mettez à jour votre carte »
  alt le client met sa carte à jour
    C->>ST: 4. nouvelle carte (portail client)
    ST->>S: 5. webhook invoice.paid
    S->>BD: 6. statut = ACTIF
  else toutes les relances échouent
    ST->>S: 7. webhook customer.subscription.deleted
    S->>BD: 8. statut = ANNULE
    S-)C: 9. courriel « vous n'êtes plus un Ami du Rûcher »
  end
```

Règles appliquées : RM-05 (période de grâce), RM-06 (avantages réservés aux Amis du Rûcher valides).
