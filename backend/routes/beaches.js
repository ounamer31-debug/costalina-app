const express = require('express');
const router  = express.Router();
const Beach   = require('../models/Beach');

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

// POST /api/beaches
router.post('/', async (req, res) => {
  try {
    const beach = new Beach(req.body);
    await beach.save();
    res.status(201).json(beach);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /api/beaches/:id
router.put('/:id', async (req, res) => {
  try {
    const beach = await Beach.findOneAndUpdate(
      { id: req.params.id }, req.body, { new: true }
    );
    if (!beach) return res.status(404).json({ error: 'Beach not found' });
    res.json(beach);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;