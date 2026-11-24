-- CreateEnum
CREATE TYPE "Role" AS ENUM ('CLIENT', 'ADMINISTRATEUR');

-- CreateEnum
CREATE TYPE "StatutProduit" AS ENUM ('BROUILLON', 'EN_STOCK', 'EPUISE');

-- CreateEnum
CREATE TYPE "StatutTaxe" AS ENUM ('TAXABLE', 'NON_TAXABLE');

-- CreateEnum
CREATE TYPE "Saison" AS ENUM ('PRINTEMPS', 'ETE', 'AUTOMNE', 'HIVER');

-- CreateEnum
CREATE TYPE "StatutCommande" AS ENUM ('EN_ATTENTE', 'PAYEE', 'ANNULEE', 'REMBOURSEE');

-- CreateEnum
CREATE TYPE "StatutAbonnement" AS ENUM ('ACTIF', 'EN_RETARD', 'IMPAYE', 'ANNULE', 'INCOMPLET');

-- CreateTable
CREATE TABLE "Utilisateur" (
    "id" TEXT NOT NULL,
    "clerkId" TEXT,
    "prenom" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "courriel" TEXT NOT NULL,
    "telephone" TEXT,
    "role" "Role" NOT NULL DEFAULT 'CLIENT',
    "stripeCustomerId" TEXT,
    "anonymiseLe" TIMESTAMP(3),
    "creeLe" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "modifieLe" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Utilisateur_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Adresse" (
    "id" TEXT NOT NULL,
    "utilisateurId" TEXT NOT NULL,
    "ligne1" TEXT NOT NULL,
    "ligne2" TEXT,
    "ville" TEXT NOT NULL,
    "province" TEXT NOT NULL DEFAULT 'QC',
    "codePostal" TEXT NOT NULL,
    "parDefaut" BOOLEAN NOT NULL DEFAULT false,
    "creeLe" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Adresse_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Produit" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "format" TEXT NOT NULL,
    "prixEnCents" INTEGER NOT NULL,
    "quantiteDisponible" INTEGER NOT NULL,
    "saison" "Saison" NOT NULL,
    "annee" INTEGER NOT NULL,
    "imageUrl" TEXT,
    "statutTaxe" "StatutTaxe" NOT NULL DEFAULT 'TAXABLE',
    "statut" "StatutProduit" NOT NULL DEFAULT 'BROUILLON',
    "epuiseLe" TIMESTAMP(3),
    "creeLe" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "modifieLe" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Produit_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Panier" (
    "id" TEXT NOT NULL,
    "utilisateurId" TEXT NOT NULL,
    "creeLe" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "modifieLe" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Panier_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProduitPanier" (
    "panierId" TEXT NOT NULL,
    "produitId" TEXT NOT NULL,
    "quantite" INTEGER NOT NULL,
    "ajouteLe" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ProduitPanier_pkey" PRIMARY KEY ("panierId","produitId")
);

-- CreateTable
CREATE TABLE "Commande" (
    "id" TEXT NOT NULL,
    "numero" SERIAL NOT NULL,
    "utilisateurId" TEXT NOT NULL,
    "adresseId" TEXT,
    "codePromoId" TEXT,
    "statut" "StatutCommande" NOT NULL DEFAULT 'EN_ATTENTE',
    "livraisonNom" TEXT NOT NULL,
    "livraisonTelephone" TEXT NOT NULL,
    "livraisonLigne1" TEXT NOT NULL,
    "livraisonLigne2" TEXT,
    "livraisonVille" TEXT NOT NULL,
    "livraisonCodePostal" TEXT NOT NULL,
    "sousTotalEnCents" INTEGER NOT NULL,
    "rabaisEnCents" INTEGER NOT NULL DEFAULT 0,
    "tpsEnCents" INTEGER NOT NULL DEFAULT 0,
    "tvqEnCents" INTEGER NOT NULL DEFAULT 0,
    "totalEnCents" INTEGER NOT NULL,
    "stripeCheckoutSessionId" TEXT,
    "stripePaymentIntentId" TEXT,
    "expireLe" TIMESTAMP(3) NOT NULL,
    "payeeLe" TIMESTAMP(3),
    "creeLe" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Commande_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LigneCommande" (
    "id" TEXT NOT NULL,
    "commandeId" TEXT NOT NULL,
    "produitId" TEXT NOT NULL,
    "quantite" INTEGER NOT NULL,
    "prixUnitaireEnCents" INTEGER NOT NULL,
    "nomProduit" TEXT NOT NULL,
    "formatProduit" TEXT NOT NULL,
    "saison" "Saison" NOT NULL,
    "annee" INTEGER NOT NULL,
    "statutTaxe" "StatutTaxe" NOT NULL,
    "rabaisEnCents" INTEGER NOT NULL DEFAULT 0,
    "tpsEnCents" INTEGER NOT NULL DEFAULT 0,
    "tvqEnCents" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "LigneCommande_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CodePromo" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "pourcentage" INTEGER NOT NULL,
    "expireLe" TIMESTAMP(3) NOT NULL,
    "utilisationsMax" INTEGER,
    "utilisations" INTEGER NOT NULL DEFAULT 0,
    "reserveAmis" BOOLEAN NOT NULL DEFAULT true,
    "actif" BOOLEAN NOT NULL DEFAULT true,
    "creeLe" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CodePromo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Abonnement" (
    "id" TEXT NOT NULL,
    "utilisateurId" TEXT NOT NULL,
    "stripeSubscriptionId" TEXT NOT NULL,
    "stripePriceId" TEXT NOT NULL,
    "statut" "StatutAbonnement" NOT NULL,
    "finPeriodeCourante" TIMESTAMP(3) NOT NULL,
    "annuleFinPeriode" BOOLEAN NOT NULL DEFAULT false,
    "graceJusquA" TIMESTAMP(3),
    "creeLe" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "modifieLe" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Abonnement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EvenementWebhook" (
    "id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "recuLe" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EvenementWebhook_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Utilisateur_clerkId_key" ON "Utilisateur"("clerkId");

-- CreateIndex
CREATE UNIQUE INDEX "Utilisateur_courriel_key" ON "Utilisateur"("courriel");

-- CreateIndex
CREATE UNIQUE INDEX "Utilisateur_stripeCustomerId_key" ON "Utilisateur"("stripeCustomerId");

-- CreateIndex
CREATE INDEX "Adresse_utilisateurId_idx" ON "Adresse"("utilisateurId");

-- CreateIndex
CREATE INDEX "Produit_statut_idx" ON "Produit"("statut");

-- CreateIndex
CREATE UNIQUE INDEX "Panier_utilisateurId_key" ON "Panier"("utilisateurId");

-- CreateIndex
CREATE INDEX "ProduitPanier_produitId_idx" ON "ProduitPanier"("produitId");

-- CreateIndex
CREATE UNIQUE INDEX "Commande_numero_key" ON "Commande"("numero");

-- CreateIndex
CREATE UNIQUE INDEX "Commande_stripeCheckoutSessionId_key" ON "Commande"("stripeCheckoutSessionId");

-- CreateIndex
CREATE UNIQUE INDEX "Commande_stripePaymentIntentId_key" ON "Commande"("stripePaymentIntentId");

-- CreateIndex
CREATE INDEX "Commande_utilisateurId_idx" ON "Commande"("utilisateurId");

-- CreateIndex
CREATE INDEX "Commande_statut_payeeLe_idx" ON "Commande"("statut", "payeeLe");

-- CreateIndex
CREATE INDEX "LigneCommande_commandeId_idx" ON "LigneCommande"("commandeId");

-- CreateIndex
CREATE INDEX "LigneCommande_produitId_idx" ON "LigneCommande"("produitId");

-- CreateIndex
CREATE UNIQUE INDEX "CodePromo_code_key" ON "CodePromo"("code");

-- CreateIndex
CREATE UNIQUE INDEX "Abonnement_utilisateurId_key" ON "Abonnement"("utilisateurId");

-- CreateIndex
CREATE UNIQUE INDEX "Abonnement_stripeSubscriptionId_key" ON "Abonnement"("stripeSubscriptionId");

-- AddForeignKey
ALTER TABLE "Adresse" ADD CONSTRAINT "Adresse_utilisateurId_fkey" FOREIGN KEY ("utilisateurId") REFERENCES "Utilisateur"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Panier" ADD CONSTRAINT "Panier_utilisateurId_fkey" FOREIGN KEY ("utilisateurId") REFERENCES "Utilisateur"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProduitPanier" ADD CONSTRAINT "ProduitPanier_panierId_fkey" FOREIGN KEY ("panierId") REFERENCES "Panier"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProduitPanier" ADD CONSTRAINT "ProduitPanier_produitId_fkey" FOREIGN KEY ("produitId") REFERENCES "Produit"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Commande" ADD CONSTRAINT "Commande_utilisateurId_fkey" FOREIGN KEY ("utilisateurId") REFERENCES "Utilisateur"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Commande" ADD CONSTRAINT "Commande_adresseId_fkey" FOREIGN KEY ("adresseId") REFERENCES "Adresse"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Commande" ADD CONSTRAINT "Commande_codePromoId_fkey" FOREIGN KEY ("codePromoId") REFERENCES "CodePromo"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LigneCommande" ADD CONSTRAINT "LigneCommande_commandeId_fkey" FOREIGN KEY ("commandeId") REFERENCES "Commande"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LigneCommande" ADD CONSTRAINT "LigneCommande_produitId_fkey" FOREIGN KEY ("produitId") REFERENCES "Produit"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Abonnement" ADD CONSTRAINT "Abonnement_utilisateurId_fkey" FOREIGN KEY ("utilisateurId") REFERENCES "Utilisateur"("id") ON DELETE CASCADE ON UPDATE CASCADE;
