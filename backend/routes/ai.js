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

module.exports = router;