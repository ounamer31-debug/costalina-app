# Costalina — Technical Guide

How the app is built, the full stack used, and how to package it so anyone, anywhere, can install and use it.

---

## Table of contents

1. [What Costalina is](#1-what-costalina-is)
2. [Architecture at a glance](#2-architecture-at-a-glance)
3. [Full technology stack](#3-full-technology-stack)
4. [Project layout](#4-project-layout)
5. [Running it locally](#5-running-it-locally)
6. [Building the production APK](#6-building-the-production-apk)
7. [Distributing the APK so others can install and use it](#7-distributing-the-apk-so-others-can-install-and-use-it)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. What Costalina is

A citizen-science mobile app for the Tunisian coast. Users photograph and geo-locate problems they see on a beach (erosion, pollution, wildlife in distress, damaged infrastructure). Moderators verify these reports. Each verified report awards points; points are redeemed for real rewards (cocktail, t-shirt, paddle session, boat trip…).

- **Mobile**: Flutter (Android + iOS from a single Dart codebase).
- **API**: Node.js + Express.
- **Database**: MongoDB (Mongoose ODM).
- **Hosting**: any Node-capable host + MongoDB Atlas (or self-hosted).

---

## 2. Architecture at a glance

```
┌──────────────────────────────────────────────────────────────────┐
│                       MOBILE APPLICATION                         │
│                          Flutter / Dart                          │
│   Screens · Services · Models · ValueNotifier state              │
└──────────────────────────────────────────────────────────────────┘
                              │ HTTPS / JSON + Bearer JWT
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                          REST API                                │
│                  Node.js · Express · helmet                      │
│   Routes · middleware (auth, rate-limit, CORS) · controllers     │
└──────────────────────────────────────────────────────────────────┘
                              │ Mongoose
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                          MongoDB                                 │
│   users · beaches · reports · alerts · rewards · redemptions     │
│   photos (binary stored in DB)                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. Full technology stack

### Mobile (Flutter)

| Concern                | Package / Tool                         |
|------------------------|----------------------------------------|
| Framework              | Flutter `3.x` · Dart `^3.11.5`        |
| HTTP client            | `http`                                 |
| Secure token storage   | `flutter_secure_storage` (Keystore/Keychain) |
| Local cache            | `shared_preferences`                   |
| Image cache            | `cached_network_image`                 |
| Image picker           | `image_picker`                         |
| Native share sheet     | `share_plus`                           |
| Offline queue trigger  | `connectivity_plus`                    |
| Geolocation            | `geolocator`                           |
| Maps                   | `flutter_map` + ESRI tiles (no API key) |
| Charts                 | `fl_chart`                             |
| Typography             | `google_fonts` (Plus Jakarta Sans + Jost) |
| Icons                  | `lucide_icons`                         |
| Internationalization   | `flutter_localizations` (FR/EN/AR/ES/DE/IT) |
| State                  | `ValueNotifier` (no framework — KISS)  |

### Backend (Node.js)

| Concern              | Package                              |
|----------------------|--------------------------------------|
| Runtime              | Node.js `20+` (tested on Node 24)    |
| HTTP framework       | `express`                            |
| ODM                  | `mongoose`                           |
| Password hashing     | `bcryptjs` (12 rounds)               |
| JSON Web Tokens      | `jsonwebtoken` (HS256, 30-day TTL)   |
| Rate limiting        | `express-rate-limit`                 |
| Security headers     | `helmet`                             |
| File uploads         | `multer` (memory storage)            |
| CORS                 | `cors`                               |
| Env variables        | `dotenv`                             |
| Email (optional)     | SMTP via `nodemailer`                |

### Database (MongoDB)

Collections:

- `users` — auth, points, role, followed beaches
- `beaches` — name, GPS, risk level, photos
- `reports` — user-submitted observations
- `alerts` — moderator-published alerts
- `rewards` — gift catalogue
- `redemptions` — exchanges (with unique codes)
- `photos` — uploaded binary data + Content-Type

### Build / dev tooling

- **`flutter`** CLI for build, run, test
- **`adb`** for installing debug APKs and tunneling ports
- **`gradle`** for Android build (invoked by Flutter)
- **`npm`** for backend dependency management

---

## 4. Project layout

```
coastwatch/
├── lib/                          # Flutter app source
│   ├── main.dart                 # entrypoint (theme + locale persistence)
│   ├── screens/                  # one file per top-level screen
│   ├── services/                 # ApiService, AuthService, ReportQueue…
│   ├── models/                   # plain Dart data classes
│   ├── widgets/                  # reusable widgets (RiskPill, IconBtn…)
│   ├── theme/app_theme.dart      # CoastPalette + design tokens
│   └── l10n/app_strings.dart     # 6-language string table
│
├── backend/                      # Node.js API
│   ├── server.js                 # express bootstrap
│   ├── routes/                   # one file per resource
│   ├── models/                   # Mongoose schemas
│   ├── middleware/               # auth, requireModerator
│   ├── utils/                    # riskService, mailer
│   ├── seed.js                   # initial beaches
│   ├── seed_rewards.js           # initial rewards
│   ├── uploads/                  # (gitignored) — files live in MongoDB anyway
│   ├── .env                      # local secrets (gitignored)
│   ├── .env.example              # template
│   └── README.md                 # backend-specific docs
│
├── android/                      # native Android shell
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       └── res/xml/network_security_config.xml  # cleartext only for localhost
│
├── ios/                          # native iOS shell (Info.plist permissions)
├── test/                         # Dart tests (currently: gps_test.dart)
│
├── pubspec.yaml                  # Flutter dependencies
├── CLAUDE.md                     # project notes for Claude Code
├── GUIDE.md                      # presentation-ready French guide
└── TECHNICAL.md                  # this file
```

---

## 5. Running it locally

### Prerequisites
- Flutter SDK (`flutter --version` → 3.x)
- Node.js 20+
- MongoDB 7+ running locally on `mongodb://127.0.0.1:27017`
- Android Studio or just the Android SDK (`adb`)

### Backend
```bash
cd backend
cp .env.example .env        # then edit JWT_SECRET, MONGODB_URI
npm install
node seed.js                # one-time: 6 mock beaches
node seed_rewards.js        # one-time: 6 rewards
node server.js
```
Verify: <http://localhost:3000/api/health> → `{"status":"ok",...}`.

### Mobile (debug, on a USB-connected Android phone)
```bash
# Make the device's localhost point to your PC
adb reverse tcp:3000 tcp:3000

flutter pub get
flutter run                 # or: flutter build apk --debug && adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

That's it. The `--dart-define=API_BASE=...` default points at `http://localhost:3000/api`, which the `adb reverse` tunnel forwards to your machine.

---

## 6. Building the production APK

There are **two builds** that matter, and the difference is where the app talks to:

### a) Debug build (your laptop)
Talks to `http://localhost:3000/api` via `adb reverse`. Useful for development only.
```bash
flutter build apk --debug
```

### b) Release build (anyone, anywhere)
Must point to a **public** backend URL.
```bash
flutter build apk --release \
  --dart-define=API_BASE=https://your-backend.example.com/api
```
The output APK is at `build/app/outputs/flutter-apk/app-release.apk`. ⚠️ Signed with the debug key by default — fine for sharing as a side-load, **not** acceptable for the Play Store.

For Play Store releases, generate a release keystore and configure `android/app/build.gradle` signing block. See <https://docs.flutter.dev/deployment/android#signing-the-app>.

---

## 7. Distributing the APK so others can install and use it

The bottleneck is **the backend**: the APK can be sent anywhere by file, but the recipients can only sign in / load data if the backend is reachable from their device.

Pick one of three setups.

### 🟢 Option A — Same Wi-Fi only (free, 5 minutes)

Good for: showing it to someone next to you, jury demo in the same room.

1. Find your PC's local IP:
   ```powershell
   ipconfig | findstr IPv4    # → e.g. 192.168.1.42
   ```
2. Open port 3000 in Windows Firewall (one time):
   ```powershell
   New-NetFirewallRule -DisplayName "Costalina API" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
   ```
3. Start the backend on your PC: `node server.js`.
4. Build the APK pointed at your PC:
   ```bash
   flutter build apk --release --dart-define=API_BASE=http://192.168.1.42:3000/api
   ```
   (Note: `localhost` and `127.0.0.1` are the only cleartext-allowed hosts in the manifest; your private IP works too because the network security config tags `192.168.x.x` as cleartext-permitted in debug. For broader compatibility in release, either use HTTPS via ngrok (Option B) or extend `network_security_config.xml` to whitelist your IP.)
5. Share the file `build/app/outputs/flutter-apk/app-release.apk` over WhatsApp, USB, etc.
6. Recipient: enable *"Install from unknown sources"*, install, launch.

### 🟡 Option B — Internet-wide, laptop still hosts (free, 15 minutes)

Good for: letting a remote friend test before you deploy properly.

1. Install ngrok and authenticate (free token at <https://ngrok.com>):
   ```powershell
   winget install ngrok.ngrok
   ngrok config add-authtoken <your-token>
   ```
2. Tunnel the backend:
   ```bash
   ngrok http 3000
   ```
   You get a URL like `https://1a2b-41-x-x-x.ngrok-free.app`.
3. Build the APK:
   ```bash
   flutter build apk --release \
     --dart-define=API_BASE=https://1a2b-41-x-x-x.ngrok-free.app/api
   ```
4. Send the APK. As long as your PC + ngrok + backend stay running, anyone in the world can use it.

### 🔵 Option C — Cloud deploy (free, the proper way — 1–2 hours)

Good for: jury presentation, demo that works tomorrow, beta testers.

#### Step 1 — Database on MongoDB Atlas (free M0 cluster)
1. Create an account at <https://cloud.mongodb.com>.
2. Build a free **M0** cluster, choose a region near you.
3. Database access → add a user (`costalina` + a strong password).
4. Network access → "Allow access from anywhere" (`0.0.0.0/0`).
5. "Connect" → "Drivers" → copy the connection string. It looks like:
   ```
   mongodb+srv://costalina:<password>@cluster0.xxxx.mongodb.net/costalina
   ```

#### Step 2 — Backend on Render.com (free Web Service)
1. Push your repo to GitHub.
2. Create an account at <https://render.com>.
3. **New → Web Service**, connect your GitHub repo.
4. Configure:
   - **Root directory**: `backend`
   - **Build command**: `npm install`
   - **Start command**: `node server.js`
   - **Environment**: Node
5. Add environment variables in Render's dashboard:
   - `MONGODB_URI` → the Atlas string from Step 1
   - `JWT_SECRET` → generate with `node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"`
   - `PORT` → `10000` (Render's expected port)
   - `CORS_ORIGINS` → leave empty for now (mobile app, no browser origin)
6. Deploy. You get a URL like `https://costalina-api.onrender.com`.
7. Seed the production DB once:
   ```bash
   MONGODB_URI="mongodb+srv://..." node backend/seed.js
   MONGODB_URI="mongodb+srv://..." node backend/seed_rewards.js
   ```

#### Step 3 — Build the public APK
```bash
flutter build apk --release \
  --dart-define=API_BASE=https://costalina-api.onrender.com/api
```

#### Step 4 — Share the APK
Upload `build/app/outputs/flutter-apk/app-release.apk` to:
- **Google Drive** (right-click → share → "anyone with the link") — easiest
- **GitHub Releases** if you want versioning
- **Direct WhatsApp / Telegram / email** for one-off recipients

#### Step 5 — Recipient instructions

Send them this short message:

> 1. Download the APK file.
> 2. Open it. Android will warn "Install from unknown sources" — tap **Settings** → enable for your browser/file manager, go back, **Install**.
> 3. Once installed, open Costalina, sign up (any email + password 8+ chars with letters and digits), and you're in.
> 4. The first request might take 20–30 seconds — Render's free tier sleeps the service when idle and needs a moment to wake up. Subsequent requests are instant.

---

## 8. Troubleshooting

### "Build fails: invalid version"
Your `pubspec.yaml` Flutter SDK constraint is `^3.11.5`. Run `flutter upgrade`.

### "APK installs but the screen is blank / can't log in"
The build doesn't know the API URL — you forgot `--dart-define=API_BASE=...`. Rebuild with the right URL.

### "Request failed" on the recipient's phone
- Backend not reachable. Test from any browser: `https://<your-backend>/api/health`. Should return `{"status":"ok",...}`.
- If Render: the free tier sleeps after 15 min idle, first request takes 30 s.
- If same-Wi-Fi setup: make sure firewall lets port 3000 in.

### "Cleartext HTTP traffic not permitted"
The release build refuses `http://` to a non-localhost address (correct, secure behavior). Either:
- Use HTTPS (Option B with ngrok, or Option C with Render — both give you HTTPS for free).
- Or extend `android/app/src/main/res/xml/network_security_config.xml` to whitelist your specific HTTP host (not recommended for anything except short-lived tests).

### "Photo upload fails with 413 / 500"
Default limit is 10 MB per photo. Either downsize the image (the app already does `maxWidth: 1200`) or bump `multer`'s `limits.fileSize` in `backend/routes/uploads.js`.

### "All requests time out"
- Mobile data may block port 3000 — use a proper cloud deploy (Option C).
- Render service sleeping — first request wakes it, second works.

---

## In summary

- **Same-room demo** → Option A (5 min, free).
- **Friend abroad** → Option B (15 min, free).
- **Jury / professor / client** → Option C (1–2 h, free, looks professional).

Once the backend is deployed, the APK lifecycle is just: change something in the Flutter code → `flutter build apk --release --dart-define=API_BASE=https://...` → re-share the new file. Recipients install it on top of the previous one and keep their account.