const express    = require('express');
const crypto     = require('crypto');
const Reward     = require('../models/Reward');
const Redemption = require('../models/Redemption');
const User       = require('../models/User');
const auth       = require('../middleware/auth');

const router = express.Router();

// GET /api/rewards — public catalog
router.get('/', async (req, res) => {
  try {
    const rewards = await Reward.find({ active: true }).sort({ cost: 1 });
    res.json(rewards);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/rewards/:id/redeem — auth, atomically deducts points
router.post('/:id/redeem', auth, async (req, res) => {
  try {
    const reward = await Reward.findById(req.params.id);
    if (!reward || !reward.active) return res.status(404).json({ error: 'Reward not found' });

    // Atomic deduction — only succeeds if user has enough points
    const user = await User.findOneAndUpdate(
      { _id: req.user.id, points: { $gte: reward.cost } },
      { $inc: { points: -reward.cost } },
      { new: true }
    );
    if (!user) return res.status(400).json({ error: 'insufficient_points' });

    const code = crypto.randomBytes(4).toString('hex').toUpperCase();
    const redemption = await Redemption.create({
      userId:     req.user.id,
      rewardId:   reward._id,
      rewardName: reward.name,
      cost:       reward.cost,
      code,
    });

    res.status(201).json({
      redemption,
      remainingPoints: user.points,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/rewards/redemptions/me — auth
router.get('/redemptions/me', auth, async (req, res) => {
  try {
    const list = await Redemption.find({ userId: req.user.id }).sort({ createdAt: -1 });
    res.json(list);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;