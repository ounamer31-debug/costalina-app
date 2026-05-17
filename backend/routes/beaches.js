const express          = require('express');
const router           = express.Router();
const Beach            = require('../models/Beach');
const auth             = require('../middleware/auth');
const requireModerator = require('../middleware/requireModerator');

const ALLOWED_FIELDS = ['id', 'name', 'city', 'photoUrl', 'photos', 'risk',
                        'lastUpdate', 'erosionMeters', 'lat', 'lng'];

function pick(obj) {
  const out = {};
  for (const k of ALLOWED_FIELDS) if (obj[k] !== undefined) out[k] = obj[k];
  return out;
}

// GET /api/beaches
router.get('/', async (req, res) => {
  try {
    const beaches = await Beach.find().sort({ name: 1 });
    res.json(beaches);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/beaches/:id
router.get('/:id', async (req, res) => {
  try {
    const beach = await Beach.findOne({ id: req.params.id });
    if (!beach) return res.status(404).json({ error: 'Beach not found' });
    res.json(beach);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/beaches — moderator only
router.post('/', auth, requireModerator, async (req, res) => {
  try {
    const beach = new Beach(pick(req.body));
    await beach.save();
    res.status(201).json(beach);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /api/beaches/:id — moderator only
router.put('/:id', auth, requireModerator, async (req, res) => {
  try {
    const beach = await Beach.findOneAndUpdate(
      { id: req.params.id }, pick(req.body), { new: true, runValidators: true }
    );
    if (!beach) return res.status(404).json({ error: 'Beach not found' });
    res.json(beach);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;