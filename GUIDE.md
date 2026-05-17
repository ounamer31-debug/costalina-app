# Costalina — Guide de présentation

> Application mobile de surveillance citoyenne du littoral tunisien.
> Conçue pour signaler l'érosion, la pollution et les risques côtiers, et
> récompenser les contributeurs.

---

## 1. Le contexte

La côte tunisienne — particulièrement la région de Monastir — subit une
érosion accélérée : recul du trait de côte, dégradation des plages,
pollution croissante. Les autorités manquent de **données de terrain à jour**
et les citoyens n'ont pas d'outil simple pour signaler ce qu'ils observent.

**Costalina** comble ce vide. C'est une application participative
(*citizen science*) qui transforme chaque visiteur de plage en capteur
humain : il photographie un problème, le situe, le décrit, et la donnée
remonte vers une base centralisée consultable par les autorités et les
chercheurs.

---

## 2. La solution en une phrase

> **Une plateforme mobile + web qui agrège des signalements géolocalisés
> sur l'état du littoral, calcule un score de risque par plage, et
> récompense les contributeurs via un système de points.**

---

## 3. Public cible

- **Citoyens / touristes** — signalent ce qu'ils voient sur la plage.
- **Modérateurs** (associations, agents municipaux) — vérifient les
  signalements et publient des alertes.
- **Décideurs publics, chercheurs, ONG** — consultent les données
  agrégées via le tableau de bord web (développé en parallèle).

---

## 4. Parcours utilisateur principal

```
Splash → Onboarding (3 écrans)   → Login / Inscription
                                   ↓
                            App principale (4 onglets + bouton "+")
                                   ↓
   ┌─────────┬──────────┬──────────┬──────────┐
   │ Accueil │  Carte   │ Alertes  │  Profil  │
   └─────────┴──────────┴──────────┴──────────┘
       │         │           │          │
       │         │           │          ├─ Mes signalements
       │         │           │          ├─ Récompenses (boutique)
       │         │           │          ├─ Classement (leaderboard)
       │         │           │          ├─ Thème clair/sombre
       │         │           │          └─ Langue (6 langues)
       │         │           │
       │         │           └─ Liste des alertes officielles
       │         │              (point bleu = non lu)
       │         │
       │         └─ Carte interactive avec marqueurs de risque
       │            par plage + position GPS de l'utilisateur
       │
       └─ Hero card de la plage la plus surveillée
          + statistiques + liste de plages

         Bouton flottant "+" (toujours visible)
                  ↓
         Sheet de signalement :
         - Plage (sélecteur)
         - Type (érosion / pollution / faune / infrastructure / photo / autre)
         - Sévérité (1 → 5)
         - Photo (caméra ou galerie, uploadée vers le serveur)
         - Message libre
         - GPS automatique
                  ↓
         Envoi → +5 points immédiatement
                  ↓
         Quand un modérateur vérifie → +20 pts (+10 si photo)
                  ↓
         Points échangés contre des récompenses
         (cocktail, t-shirt, paddle, excursion, etc.)
```

---

## 5. Fonctionnalités majeures

### 5.1 Signalement participatif

- **6 types** : érosion, pollution, faune en détresse, infrastructure
  endommagée, photo libre, autre.
- **Sévérité** notée de 1 à 5 (auto-coloration de l'icône).
- **Photo** prise sur place ou depuis la galerie, redimensionnée à 1200 px
  et uploadée vers le serveur (stockage local dans `backend/uploads/`).
- **GPS** capturé automatiquement à l'ouverture du formulaire (avec
  fallback gracieux si l'utilisateur refuse la permission).
- **File d'attente hors-ligne** : si l'envoi échoue (pas de réseau), le
  signalement est sauvegardé localement et **renvoyé automatiquement
  dès que la connexion revient** (écoute de la connectivité système).

### 5.2 Score de risque par plage

Chaque plage a un statut **stable / modéré / élevé**. Le score est
**recalculé automatiquement** côté serveur dès qu'un signalement est créé
ou vérifié (fonction `recomputeBeachRisk`). Cela alimente la couleur des
marqueurs sur la carte et les badges sur la liste.

### 5.3 Carte interactive

- Tuiles **ESRI World Imagery** (gratuit, sans clé API).
- Marqueurs colorés par niveau de risque.
- Centrage GPS sur l'utilisateur (avec animation de halo).
- Card flottante d'info au tap sur une plage.

### 5.4 Alertes officielles

Publiées par les modérateurs. Décorées d'un **point bleu** tant qu'elles
ne sont pas lues. L'ouverture de l'écran marque toutes les alertes
comme lues pour l'utilisateur courant (lecture **par utilisateur**, pas
globale — chaque utilisateur a son propre état).

### 5.5 Système de récompenses (gamification)

- **+5 points** à chaque signalement soumis.
- **+20 points** quand un modérateur vérifie le signalement.
- **+10 points bonus** si une photo était jointe.
- **Boutique** de 6 récompenses pré-paramétrées :
  - Cocktail offert (100 pts)
  - Plantation d'arbre à votre nom (200 pts)
  - T-shirt Costalina édition limitée (250 pts)
  - Massage spa 30 min (500 pts)
  - Session de paddle 2h (1000 pts)
  - Excursion bateau aux îles Kuriat (1500 pts)
- **Échange atomique** côté MongoDB : `findOneAndUpdate` avec garde
  `$gte` sur les points, ce qui rend impossible la double-dépense même
  sous forte concurrence.
- **Code de réclamation** unique généré à chaque échange, présenté chez
  le partenaire.

### 5.6 Classement (leaderboard)

Top 20 contributeurs triés par points. L'utilisateur connecté est
**mis en évidence** en couleur teal avec son rang exact.

### 5.7 Suivre une plage

Bouton cœur dans l'en-tête de la fiche de plage. Permet à terme de
filtrer les alertes sur ses plages préférées (endpoint backend prêt).

### 5.8 Multilangue

Six langues supportées : **français, anglais, arabe, espagnol, allemand,
italien**. Sélecteur de drapeau en haut à droite. Préférence
**persistée** sur l'appareil.

### 5.9 Thème clair / sombre

Bascule manuelle dans le profil. Persistée également. L'interface utilise
un `ThemeExtension` Flutter (`CoastPalette`) pour gérer proprement les
deux jeux de couleurs.

### 5.10 Réinitialisation de mot de passe par OTP

Code à 6 chiffres envoyé par email (en mode dev : affiché dans la console
serveur). Hash SHA-256 stocké, expiration 15 minutes.

---

## 6. Architecture technique

```
┌────────────────────────────────────────────────────────────────┐
│                       APPLICATION MOBILE                       │
│                          Flutter / Dart                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Screens : Home, Map, Alertes, Profil, Login, Onboard,   │  │
│  │            BeachDetail, Rewards, Leaderboard, Splash     │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  Services :                                              │  │
│  │   • ApiService       (http vers backend)                 │  │
│  │   • AuthService      (JWT, FlutterSecureStorage)         │  │
│  │   • StorageService   (multipart upload photo)            │  │
│  │   • LocationService  (geolocator, abstraction testable)  │  │
│  │   • CacheService     (SharedPreferences offline cache)   │  │
│  │   • ReportQueue      (queue offline + auto-flush)        │  │
│  │   • WeatherService   (Open-Meteo, météo plage)           │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  State : ValueNotifiers (theme / locale / tab)           │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
                            │  HTTPS / JSON
                            ▼
┌────────────────────────────────────────────────────────────────┐
│                       API BACKEND                              │
│                   Node.js + Express.js                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Routes :  /auth   /beaches   /reports   /alerts         │  │
│  │            /users  /uploads   /rewards                   │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  Middleware : auth (JWT) · requireModerator · rate-limit │  │
│  │               (login/register/forgot/reset + global)     │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  Utils :   riskService.recomputeBeachRisk()              │  │
│  │            mailer.sendOtp()                              │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
                            │  Mongoose ODM
                            ▼
┌────────────────────────────────────────────────────────────────┐
│                    BASE DE DONNÉES                             │
│                       MongoDB                                  │
│   Collections :  users · beaches · reports · alerts            │
│                  rewards · redemptions                         │
└────────────────────────────────────────────────────────────────┘
```

---

## 7. Stack technique

### Mobile

| Domaine            | Technologie                                  |
|--------------------|----------------------------------------------|
| Framework          | **Flutter 3.x** (Dart `^3.11.5`)             |
| Cartographie       | `flutter_map` + tuiles ESRI                  |
| Géolocalisation    | `geolocator`                                 |
| Graphiques         | `fl_chart` (timeline, courbe d'érosion)      |
| Stockage sécurisé  | `flutter_secure_storage` (JWT)               |
| Cache local        | `shared_preferences`                         |
| Images réseau      | `cached_network_image`                       |
| Sélection photo    | `image_picker`                               |
| Partage natif      | `share_plus`                                 |
| Connectivité       | `connectivity_plus` (auto-flush offline)     |
| Typographie        | `google_fonts` (Plus Jakarta Sans + Jost)    |
| Icônes             | `lucide_icons`                               |

### Backend

| Domaine            | Technologie                                  |
|--------------------|----------------------------------------------|
| Runtime            | **Node.js v24**                              |
| Framework HTTP     | **Express.js**                               |
| Base de données    | **MongoDB** (driver Mongoose)                |
| Authentification   | **JWT** signés (HS256, expiration 30 j)      |
| Hash mot de passe  | `bcryptjs` (12 rounds)                       |
| Rate limiting      | `express-rate-limit`                         |
| Upload fichiers    | `multer` (multipart/form-data)               |
| Variables d'env.   | `dotenv`                                     |
| CORS               | `cors` (origines configurables)              |

---

## 8. Modèle de données

### `User`
```js
{
  name, email (unique), password (bcrypt),
  avatarUrl, points, role: 'user'|'moderator'|'admin',
  followedBeaches: [String],
  resetOtp, resetOtpExpiry,
  createdAt, updatedAt
}
```

### `Beach`
```js
{
  id (slug), name, city,
  photoUrl, photos: [String],
  risk: 'stable'|'modere'|'eleve',
  lastUpdate, erosionMeters,
  lat, lng
}
```

### `Report`
```js
{
  beachId, userId (depuis JWT, jamais le body),
  type, severity (1-5), message (≤1000), photoUrl,
  status: 'pending'|'verified'|'resolved'|'rejected',
  lat (-90..90), lng (-180..180),
  createdAt, updatedAt
}
```

### `Alert`
```js
{
  beachId, beachName, message,
  risk: 'stable'|'modere'|'eleve',
  readBy: [userId],            // état de lecture par utilisateur
  createdAt
}
```

### `Reward`
```js
{ name, description, cost, category, imageUrl, active }
```

### `Redemption`
```js
{
  userId, rewardId, rewardName, cost,
  code (6 caractères unique),
  status: 'pending'|'fulfilled'|'cancelled',
  createdAt
}
```

---

## 9. Sécurité

| Mesure                                         | Détail                                              |
|------------------------------------------------|-----------------------------------------------------|
| Mots de passe                                  | Hash bcrypt 12 rounds                               |
| Politique de mot de passe                      | 8 caractères minimum, lettres + chiffres requis     |
| JWT                                            | Signature HS256, expiration 30 jours                |
| Stockage du token                              | Keystore Android / Keychain iOS                     |
| Rate limiting                                  | login/register/forgot/reset : 20 req / 15 min      |
|                                                | global : 300 req / 15 min · reports : 10 / min     |
| CORS                                           | Origines configurables via `CORS_ORIGINS`           |
| Limite de payload JSON                         | 256 KB max                                          |
| Whitelist des champs en écriture               | `Beach`, `Report` : aucune mass-assignment possible |
| Routes modérateur                              | `requireModerator` middleware                       |
| Échange de récompense                          | Atomic `findOneAndUpdate` + `$gte` (anti-replay)    |
| OTP de reset                                   | SHA-256 stocké, expiration 15 min                   |
| Vérification de propriété                      | DELETE /reports/:id contrôle `userId == req.user.id` |

---

## 10. Endpoints API principaux

### Authentification (`/api/auth`)
- `POST /register` — création de compte
- `POST /login` — retourne JWT + profil
- `GET  /me` — profil de l'utilisateur courant
- `PUT  /me` — mise à jour nom / avatar
- `POST /forgot-password` — déclenche l'envoi de l'OTP
- `POST /reset-password` — vérifie l'OTP et change le mot de passe

### Plages (`/api/beaches`)
- `GET  /` — liste toutes les plages
- `GET  /:id` — détail d'une plage
- `POST /` — créer (modérateur)
- `PUT  /:id` — modifier (modérateur)

### Signalements (`/api/reports`)
- `GET  /?beachId=&page=&limit=` — liste paginée
- `POST /` — créer (auth) → +5 points
- `GET  /me` — mes signalements
- `GET  /stats/me` — mes statistiques
- `GET  /timeline?beachId=` — agrégats mensuels sur 12 mois
- `GET  /export?beachId=` — export CSV (`beachId` requis sinon modérateur)
- `PATCH /:id/status` — vérifier (modérateur) → +20/+30 points à l'auteur
- `DELETE /:id` — supprimer (auteur seulement)

### Alertes (`/api/alerts`)
- `GET  /` — liste paginée (décorée de l'état `read` par utilisateur)
- `POST /` — publier (modérateur)
- `PATCH /:id/read` — marquer une alerte lue
- `POST /read-all` — marquer toutes les alertes lues
- `DELETE /:id` — supprimer (modérateur)

### Utilisateurs (`/api/users`)
- `GET  /` — liste complète (modérateur)
- `GET  /leaderboard?limit=20` — top contributeurs (public)
- `GET  /me/follows` — plages suivies
- `POST /me/follows/:beachId` — suivre
- `DELETE /me/follows/:beachId` — ne plus suivre

### Récompenses (`/api/rewards`)
- `GET  /` — catalogue
- `POST /:id/redeem` — échanger (auth)
- `GET  /redemptions/me` — historique des échanges

### Upload (`/api/uploads`)
- `POST /photo` — upload multipart (auth)

---

## 11. Points forts à mettre en avant

1. **Vraie utilité sociétale** — outil concret pour un problème réel
   (érosion côtière tunisienne), pas un POC technique.
2. **Gamification efficace** — le système de points + récompenses
   tangibles motive la contribution continue.
3. **Robustesse hors-ligne** — l'app fonctionne sans réseau ; les
   signalements sont sauvegardés et renvoyés automatiquement.
4. **Architecture clean** — séparation services / écrans / modèles,
   abstraction testable de la géolocalisation, état global via
   `ValueNotifier`.
5. **Sécurité de production** — JWT, bcrypt, rate-limiting, CORS,
   whitelist des champs, validations côté schéma Mongoose, échanges
   atomiques.
6. **Internationalisation native** — 6 langues, persistance des
   préférences.
7. **Conception soignée** — design system cohérent (typographie serif
   pour les titres, sans-serif pour le corps, palette teal référencée
   au littoral méditerranéen), thème sombre complet.
8. **Stack moderne** — Flutter pour iOS + Android d'un seul code,
   Node.js + MongoDB pour un backend scalable.

---

## 12. Démonstration suggérée (5 minutes)

1. **Splash + onboarding** (10 s) — l'identité visuelle.
2. **Inscription** — montrer la validation du mot de passe et de la
   confirmation.
3. **Accueil** — la hero card + la liste des plages avec leur risque.
4. **Carte** — centrer sur l'utilisateur, taper sur une plage.
5. **Fiche plage** — photos, graphique d'érosion, timeline 12 mois,
   bouton cœur (suivre), bouton partager.
6. **Création d'un signalement** via le bouton "+" — choisir une plage,
   prendre une photo, sévérité, envoyer. Montrer le +5 points.
7. **Alertes** — montrer le point bleu, revenir → il disparaît.
8. **Profil → Récompenses** — boutique avec photos réelles, échanger
   un cocktail (100 pts), montrer le code généré.
9. **Profil → Classement** — l'utilisateur courant mis en évidence.
10. **Profil → Thème sombre + langue** — basculer en anglais, montrer
    la persistance en relançant l'app.
11. **(Bonus) Mode avion** — créer un signalement hors-ligne, désactiver
    le mode avion, montrer le renvoi automatique.

---

## 13. Pistes d'évolution

À court terme :
- Authentification sociale Google / Apple (OAuth en place, à activer).
- Tableau de bord web pour modérateurs (en cours par l'équipe web).
- Notifications push (réception des alertes en temps réel).
- Envoi réel des emails OTP (SMTP / SendGrid).

À moyen terme :
- Téléversement vidéo en plus des photos.
- IA d'analyse automatique des photos (détection d'érosion).
- Partenariats officiels avec l'APAL et les municipalités côtières.
- Deep-linking (ouvrir une plage / une alerte depuis une notification).
- Télémétrie d'erreurs (Sentry).

---

## 14. Équipe

- **Mobile (Flutter)** : conception UX, architecture services, intégration
  API, géolocalisation, file offline, gamification, thème.
- **Backend (Node/Mongo)** : modèles, routes REST, JWT, rate-limiting,
  recompute de risque, atomicité des récompenses.
- **Web (en parallèle)** : tableau de bord modérateur (équipe distincte).

---

## 15. Repères chiffrés

- **6** types de signalement · **3** niveaux de risque · **5** niveaux
  de sévérité.
- **6** récompenses pré-paramétrées entre 100 et 1500 points.
- **6** langues d'interface.
- **20** entrées affichées dans le leaderboard.
- **12** mois d'historique sur la timeline d'une plage.
- **15** minutes de validité pour l'OTP de réinitialisation.
- **256 KB** de payload JSON maximum par requête.

---

## En résumé

> Costalina, c'est **une app citoyenne qui donne à la côte tunisienne une
> mémoire numérique vivante**, alimentée par ceux qui l'aiment, structurée
> pour ceux qui doivent la protéger.

Made with ❤️ for the Tunisian coast.