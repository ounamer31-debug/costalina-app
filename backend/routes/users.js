const express          = require('express');
const User             = require('../models/User');
const auth             = require('../middleware/auth');
const requireModerator = require('../middleware/requireModerator');

const router = express.Router();

// GET /api/users  — moderator/admin only
router.get('/', auth, requireModerator, async (req, res) => {
  try {
    const users = await User.find()
      .select('-password -resetOtp -resetOtpExpiry')
      .sort({ createdAt: -1 });
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── Followed beaches ─────────────────────────────────────────────────────────

// GET /api/users/me/follows — current user's followed beach ids
router.get('/me/follows', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('followedBeaches').lean();
    res.json({ followedBeaches: user?.followedBeaches || [] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/users/me/follows/:beachId — follow a beach
router.post('/me/follows/:beachId', auth, async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $addToSet: { followedBeaches: req.params.beachId } },
      { new: true }
    ).select('followedBeaches').lean();
    res.json({ followedBeaches: user.followedBeaches });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/users/me/follows/:beachId — unfollow
router.delete('/me/follows/:beachId', auth, async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $pull: { followedBeaches: req.params.beachId } },
      { new: true }
    ).select('followedBeaches').lean();
    res.json({ followedBeaches: user.followedBeaches });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/users/leaderboard — top contributors by points (public)
router.get('/leaderboard', async (req, res) => {
  try {
    const limit = Math.min(50, parseInt(req.query.limit) || 20);
    const users = await User.find()
      .select('name avatarUrl points')
      .sort({ points: -1 })
      .limit(limit)
      .lean();
    res.json(users.map(u => ({ ...u, _id: u._id.toString() })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;