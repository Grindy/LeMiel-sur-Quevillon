# CLAUDE.md

Ce fichier fournit des indications à Claude Code (claude.ai/code) pour travailler avec le code de ce dépôt.

## Projet

Site web transactionnel pour Le-Miel-sur-Quévillon, un organisme apicole à but non lucratif de Lebel-sur-Quévillon (Nord-du-Québec). Projet scolaire (Maisonneuve, Web transactionnel, A26) construit à partir d'un prototype d'une session précédente. Tous les textes de l'interface, identifiants, noms de classes CSS et commentaires sont en **français** — garder cette convention (ex. `entete`, `contenu`, `produits`, `texteGros`). La fiche de projet (personas, SWOT, etc.) se trouve dans `docs/Seance02_Fiche_Projet_v01.pdf` (protégée par mot de passe).

## Commandes

```bash
npm run dev      # serveur de développement Next.js
npm run build    # build de production
npm run lint     # ESLint (config flat, next core-web-vitals + typescript)
npx prisma generate          # régénérer le client Prisma après une modification du schéma
npx prisma migrate dev       # créer/appliquer les migrations (prisma/migrations)
npx prisma db seed           # exécute la commande de seed définie dans prisma.config.ts
```

Aucun framework de tests n'est configuré.

## Stack

- Next.js 16 (App Router) avec React 19 et le React Compiler activé (`reactCompiler: true` dans `next.config.ts`) — éviter la mémoïsation manuelle avec `useMemo`/`useCallback`.
- Tailwind CSS v4 via `@tailwindcss/postcss`. Les couleurs de la marque sont définies dans `@theme` dans `src/app/globals.css` (`miel`, `ambre`, `brule`, `encre`, `aile`), mais la majorité du style est écrite à la main sous forme de classes CSS sémantiques dans `globals.css` plutôt qu'avec des utilitaires Tailwind.
- Prisma 7 + PostgreSQL via `@prisma/adapter-pg` (`PrismaPg`). `bcrypt` est installé pour l'authentification à venir.
- Alias de chemin `@/*` → `src/*`.

## Architecture

**Navigation entre pages côté client, pas par le routage de fichiers.** `src/app/page.tsx` est un composant `"use client"` qui contient `useState<Page>("accueil" | "produits" | "abeilles")`; il affiche `Header`, l'un des composants de section, puis `Footer`. Les dossiers `accueil/`, `produits/` et `abeilles/` contiennent des fichiers `page.tsx`, donc ils sont *aussi* accessibles comme de vraies routes (`/produits`, etc.), mais en utilisation normale ils sont importés et affichés comme composants dans la page racine. `Accueil` et `Header` reçoivent un callback `onNavigate`. Le type union `Page` est dupliqué dans `page.tsx`, `Header.tsx` et `accueil/page.tsx` — les mettre tous à jour lors de l'ajout d'une section.

**Les données des produits sont codées en dur** sous forme de tableau dans `src/app/produits/page.tsx` (nom, prix, format, enStock, saison, annee, badge…); elles ne proviennent pas encore de la base de données.

**Bouton d'accessibilité pour la taille du texte :** `Header` ajoute/retire la classe `texte-gros` sur `<html>`; `globals.css` agrandit les polices sous `html.texte-gros`.

**Couche base de données (en cours) :**
- `src/lib/prisma.ts` — `PrismaClient` singleton avec l'adaptateur `PrismaPg`, mis en cache sur `globalThis` hors production, marqué `import "server-only"` (ne l'importer que depuis des Server Components / server actions / route handlers, jamais depuis l'arborescence client de `page.tsx`).
- `prisma.config.ts` — configuration Prisma 7 : lit `DATABASE_URL` depuis `.env` via `dotenv/config`; l'URL de la source de données est définie ici, pas dans `schema.prisma`.
- `prisma/schema.prisma` contient le modèle de données (10 modèles, 6 énumérations, noms en français) décrit dans `docs/classes.md` et à la section 9 de `docs/cahier-des-charges.md`; il utilise le générateur `prisma-client-js` (`.gitignore` prévoit déjà `/src/generated/prisma` pour le nouveau générateur `prisma-client`). Toute modification du schéma doit être reportée dans ces deux documents.

## Journal d'utilisation de l'IA (obligatoire)

Chaque session de travail avec une IA doit être consignée dans `docs/journal-ia.md`, **avant de terminer la tâche** (et avant tout commit qui inclut le travail de la session). Ajouter une ligne par demande significative au tableau du journal, avec les colonnes :

| Colonne | Contenu |
|---|---|
| Date | AAAA-MM-JJ |
| Membre | Le membre de l'équipe qui a fait la demande (nom de l'utilisateur git) |
| Outil | L'outil et le modèle (ex. Claude Code, Opus 5.5) |
| Demande | Ce qui a été demandé, en une ou deux phrases |
| Gardé | Ce qui a été produit et conservé |
| Corrigé et pourquoi | Ce que le membre a refusé, modifié ou tranché, et la raison; « — » si rien |
| Vérification | Comment le résultat a été vérifié (commande exécutée, relecture, test) et par qui |

Règles :
- Ne consigner que les demandes qui produisent ou modifient un livrable (code, schéma, documents du projet). Les petits diagnostics, questions ponctuelles et problèmes d'environnement local (ex. extension VS Code) ne sont pas consignés.
- Ne jamais inventer une vérification : n'écrire que ce qui a réellement été exécuté ou confirmé par le membre.
- Ne pas réécrire ni supprimer les entrées existantes; seulement en ajouter.
- Les entrées sont en ordre chronologique, la plus récente en bas.

## Environnement

`.env` (ignoré par git) doit définir `DATABASE_URL` (chaîne de connexion Postgres; pour Neon, inclure `?sslmode=require`).
