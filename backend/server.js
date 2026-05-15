require('dotenv').config();
const express  = require('express');
const mongoose = require('mongoose');
const cors     = require('cors');
const path     = require('path');

const app = express();
app.use(cors());
app.use(express.json());

// Serve uploaded files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api/auth',    require('./routes/auth'));
app.use('/api/beaches', require('./routes/beaches'));
app.use('/api/reports', require('./routes/reports'));
app.use('/api/alerts',  require('./routes/alerts'));
app.use('/api/uploads', require('./routes/uploads'));
app.use('/api/users',   require('./routes/users'));

// Health check
app.get('/api/health', (_, res) => res.json({ status: 'ok', time: new Date() }));

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