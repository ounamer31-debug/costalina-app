const express  = require('express');
const router   = express.Router();
const auth     = require('../middleware/auth');
const Beach    = require('../models/Beach');
const Report   = require('../models/Report');
const ai       = require('../utils/aiService');

// POST /api/ai/analyze-photo  { photoUrl }
router.post('/analyze-photo', auth, async (req, res) => {
  const { photoUrl } = req.body;
  if (!photoUrl) return res.status(400).json({ error: 'photoUrl required' });
  try {
    const result = await ai.analyzePhoto(photoUrl);
    res.json(result);
  } catch (err) {
    console.error('analyzePhoto:', err.message);
    res.status(err.status || 502).json({ error: err.message });
  }
});

// POST /api/ai/chat  { messages: [{role, content}], lang? }
router.post('/chat', auth, async (req, res) => {
  const { messages, lang } = req.body;
  if (!Array.isArray(messages) || messages.length === 0) {
    return res.status(400).json({ error: 'messages required' });
  }
  if (messages.length > 20) {
    return res.status(400).json({ error: 'too_many_messages' });
  }
  try {
    const result = await ai.chat(messages, lang || 'fr');
    res.json(result);
  } catch (err) {
    console.error('chat:', err.message);
    res.status(err.status || 502).json({ error: err.message });
  }
});

// GET /api/ai/forecast/:beachId
router.get('/forecast/:beachId', async (req, res) => {
  try {
    const beach = await Beach.findOne({ id: req.params.beachId }).lean();
    if (!beach) return res.status(404).json({ error: 'beach_not_found' });

    const reports = await Report.find({ beachId: req.params.beachId })
      .sort({ createdAt: -1 })
      .limit(60)
      .lean();

    const result = await ai.forecastBeach(beach, reports);
    res.json(result);
  } catch (err) {
    console.error('forecast:', err.message);
    res.status(err.status || 502).json({ error: err.message });
  }
});

// POST /api/ai/improve-message  { text, lang? }
router.post('/improve-message', auth, async (req, res) => {
  const text = String(req.body.text || '').trim();
  if (!text) return res.status(400).json({ error: 'text required' });
  if (text.length > 1000) return res.status(400).json({ error: 'too_long' });
  try {
    const result = await ai.improveMessage(text, req.body.lang || 'fr');
    res.json(result);
  } catch (err) {
    console.error('improveMessage:', err.message);
    res.status(err.status || 502).json({ error: err.message });
  }
});

// GET /api/ai/weekly-digest — public, cached in-memory for 1h
let _digestCache = { at: 0, payload: null };
const DIGEST_TTL = 60 * 60 * 1000;
router.get('/weekly-digest', async (req, res) => {
  if (_digestCache.payload && Date.now() - _digestCache.at < DIGEST_TTL) {
    return res.json(_digestCache.payload);
  }
  try {
    const since = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const reports = await Report.find({ createdAt: { $gte: since } })
      .select('type status beachId')
      .lean();

    const stats = {
      total:    reports.length,
      byType:   {},
      byStatus: {},
      topBeaches: {},
    };
    for (const r of reports) {
      stats.byType[r.type]     = (stats.byType[r.type] || 0) + 1;
      stats.byStatus[r.status] = (stats.byStatus[r.status] || 0) + 1;
      stats.topBeaches[r.beachId] = (stats.topBeaches[r.beachId] || 0) + 1;
    }
    // Convert topBeaches to a sorted top-3 with names
    const beachIds = Object.entries(stats.topBeaches)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([id]) => id);
    const beaches = await Beach.find({ id: { $in: beachIds } }).select('id name').lean();
    stats.topBeaches = beachIds.map(id => {
      const b = beaches.find(x => x.id === id);
      return { id, name: b?.name || id, count: stats.topBeaches[id] };
    });

    if (stats.total === 0) {
      const payload = {
        text: "Aucun signalement cette semaine. Sois le premier à contribuer !",
        stats,
      };
      _digestCache = { at: Date.now(), payload };
      return res.json(payload);
    }

    const result = await ai.weeklyDigest(stats);
    const payload = { text: result.text, stats };
    _digestCache = { at: Date.now(), payload };
    res.json(payload);
  } catch (err) {
    console.error('weekly-digest:', err.message);
    res.status(err.status || 502).json({ error: err.message });
  }
});

module.exports = router;