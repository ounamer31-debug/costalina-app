const express          = require('express');
const router           = express.Router();
const Alert            = require('../models/Alert');
const auth             = require('../middleware/auth');
const requireModerator = require('../middleware/requireModerator');

// GET /api/alerts — annotated with current user's read state if logged in
router.get('/', async (req, res) => {
  try {
    const page  = Math.max(1, parseInt(req.query.page)  || 1);
    const limit = Math.min(100, parseInt(req.query.limit) || 50);
    const alerts = await Alert.find()
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .lean();

    // Decorate with read flag for current user if a JWT is present
    let userId = null;
    const authHeader = req.headers.authorization || '';
    if (authHeader.startsWith('Bearer ')) {
      try {
        const jwt = require('jsonwebtoken');
        const decoded = jwt.verify(authHeader.slice(7), process.env.JWT_SECRET);
        userId = String(decoded.id);
      } catch (_) { /* ignore invalid token, return public payload */ }
    }
    res.json(alerts.map(a => ({
      ...a,
      read: userId ? (a.readBy || []).map(String).includes(userId) : false,
    })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/alerts — moderator only (system/curated alerts)
router.post('/', auth, requireModerator, async (req, res) => {
  try {
    const { beachId, beachName, message, risk } = req.body;
    if (!beachId || !beachName || !message) {
      return res.status(400).json({ error: 'beachId, beachName and message required' });
    }
    const alert = new Alert({ beachId, beachName, message, risk });
    await alert.save();
    res.status(201).json(alert);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PATCH /api/alerts/:id/read — mark as read for current user
router.patch('/:id/read', auth, async (req, res) => {
  try {
    const alert = await Alert.findByIdAndUpdate(
      req.params.id,
      { $addToSet: { readBy: req.user.id } },
      { new: true }
    );
    if (!alert) return res.status(404).json({ error: 'Alert not found' });
    res.json({ ok: true });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /api/alerts/read-all — mark every alert read for current user
router.post('/read-all', auth, async (req, res) => {
  try {
    await Alert.updateMany({}, { $addToSet: { readBy: req.user.id } });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/alerts/:id — moderator only
router.delete('/:id', auth, requireModerator, async (req, res) => {
  try {
    const alert = await Alert.findByIdAndDelete(req.params.id);
    if (!alert) return res.status(404).json({ error: 'Alert not found' });
    res.json({ message: 'Deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;