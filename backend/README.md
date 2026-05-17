# Costalina API

REST backend for the Costalina mobile app — Node.js + Express + MongoDB.

## Prerequisites

- Node.js 20+ (tested on Node 24)
- MongoDB running locally on `mongodb://127.0.0.1:27017` _or_ a MongoDB Atlas connection string

## Getting started

```bash
cd backend
npm install
cp .env.example .env       # then edit .env
node seed.js               # one-time: seed 6 mock beaches
node seed_rewards.js       # one-time: seed 6 rewards
node server.js
```

Health check: <http://localhost:3000/api/health>

## Environment variables

See [`.env.example`](.env.example). The two required ones are:
- `MONGODB_URI` — connection string
- `JWT_SECRET` — long random string used to sign JWTs

## Running tests

There is currently no backend test suite. Mobile tests live at the repo root in `test/`.

## Project layout

```
backend/
├── server.js              # express app, middleware, route mounting
├── seed.js                # initial beaches
├── seed_rewards.js        # initial reward catalogue
├── middleware/
│   ├── auth.js            # JWT verifier — populates req.user
│   └── requireModerator.js
├── models/                # Mongoose schemas
│   ├── User.js
│   ├── Beach.js
│   ├── Report.js
│   ├── Alert.js
│   ├── Photo.js
│   ├── Reward.js
│   └── Redemption.js
├── routes/
│   ├── auth.js            # /api/auth
│   ├── beaches.js         # /api/beaches
│   ├── reports.js         # /api/reports
│   ├── alerts.js          # /api/alerts
│   ├── users.js           # /api/users
│   ├── uploads.js         # /api/uploads/photo
│   └── rewards.js         # /api/rewards
└── utils/
    ├── riskService.js     # beach risk recomputation
    └── mailer.js          # OTP email delivery
```

## Security model

- **Auth**: JWT (HS256, 30-day TTL), Bearer header.
- **Passwords**: bcrypt (12 rounds), minimum 8 chars with letters and digits.
- **Rate limits**: `login`/`register`/`forgot`/`reset` capped at 20 req / 15 min per IP. Reports capped at 10 / min. Global cap of 300 / 15 min.
- **Headers**: `helmet` enabled (CSP, HSTS, X-Frame-Options, etc.).
- **CORS**: origin list configurable via `CORS_ORIGINS` env var.
- **Body size**: capped at 256 KB.
- **Field whitelisting**: writes to `Beach` and `Report` accept only known fields (no mass-assignment).
- **Atomic state transitions**: report verification is atomic — no double-award races.

## API summary

See [the project guide](../GUIDE.md#10-endpoints-api-principaux) for the full endpoint list grouped by feature.

## Deployment

For a hosted demo, the easiest setup is:
1. MongoDB Atlas free tier for the database.
2. Render.com / Railway / Fly.io for the API (a free Node web service).
3. Build the Flutter APK with `--dart-define=API_BASE=https://<your-host>/api`.

Run the seeds once against the production DB:
```bash
MONGODB_URI=<atlas-uri> node seed.js
MONGODB_URI=<atlas-uri> node seed_rewards.js
```