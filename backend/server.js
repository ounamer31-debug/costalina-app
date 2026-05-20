require('dotenv').config();
const express   = require('express');
const mongoose  = require('mongoose');
const cors      = require('cors');
const path      = require('path');
const rateLimit = require('express-rate-limit');
const helmet    = require('helmet');

const app = express();
app.use(helmet({
  // Allow cross-origin image embedding so the Flutter app can load /uploads/photo/:id
  crossOriginResourcePolicy: { policy: 'cross-origin' },
}));
app.disable('x-powered-by');

// CORS — allow configured origins, fall back to permissive for dev
const allowedOrigins = (process.env.CORS_ORIGINS || '')
  .split(',').map(s => s.trim()).filter(Boolean);
app.use(cors({
  origin: (origin, cb) => {
    if (!origin) return cb(null, true);              // mobile apps, curl
    if (allowedOrigins.length === 0) return cb(null, true); // dev: allow all
    if (allowedOrigins.includes(origin)) return cb(null, true);
    return cb(new Error('Not allowed by CORS'));
  },
  credentials: true,
}));
app.use(express.json({ limit: '256kb' }));

// Rate limiting
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later' },
});
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { error: 'Too many auth attempts, please try again later' },
});
const reportLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10,
  message: { error: 'Too many reports submitted, slow down' },
});
app.use(globalLimiter);
app.use('/api/auth/login',           authLimiter);
app.use('/api/auth/register',        authLimiter);
app.use('/api/auth/forgot-password', authLimiter);
app.use('/api/auth/reset-password',  authLimiter);
app.use('/api/reports',              reportLimiter);

// Serve uploaded files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api/auth',    require('./routes/auth'));
app.use('/api/beaches', require('./routes/beaches'));
app.use('/api/reports', require('./routes/reports'));
app.use('/api/alerts',  require('./routes/alerts'));
app.use('/api/uploads', require('./routes/uploads'));
app.use('/api/users',   require('./routes/users'));
app.use('/api/rewards', require('./routes/rewards'));
app.use('/api/ai',      require('./routes/ai'));

// Health check
app.get('/api/health', (_, res) => res.json({ status: 'ok', time: new Date() }));

// 404 — unknown route
app.use((req, res) => res.status(404).json({ error: 'not_found', path: req.originalUrl }));

// Centralised error handler — never leak stack traces in production
app.use((err, req, res, _next) => {
  console.error(`[${req.method} ${req.originalUrl}]`, err);
  const status = err.status || 500;
  res.status(status).json({ error: err.expose ? err.message : 'internal_error' });
});

// Connect to MongoDB then start
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('✅  MongoDB connected');
    const port = process.env.PORT || 3000;
    app.listen(port, '0.0.0.0', () =>
      console.log(`🚀  Costalina API running on http://0.0.0.0:${port}`)
    );
  })
  .catch(err => {
    console.error('❌  MongoDB connection failed:', err.message);
    process.exit(1);
  });