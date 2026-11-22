# Journal IA — LeMiel-sur-Quévillon

Trace des sessions où une IA a contribué au projet : ce qui a été demandé,
ce qui a été produit, et ce qui a été vérifié par un humain.

---

## 2026-11-21 — Migration technologique: adapter-neon -> PrismaPg
- **Outil :** Claude (Opus 5.5)
- **Demande :** Passer le projet en PrismaPg plutôt qu'utiliser l'adapteur neon
- **Résultat :** Les dépendances à neon ont été supprimées, le code se rapportant a l'adapteur neon utilise maintenant PrismaPg.
- **Décision :** package et prisma.ts mis à jour.
- **Vérifié :** ✅ Conforme a ce qui a été vu en cours dans le projet symposiQ