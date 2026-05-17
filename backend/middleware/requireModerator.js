const User = require('../models/User');

module.exports = async function requireModerator(req, res, next) {
  try {
    const user = await User.findById(req.user.id).select('role').lean();
    if (!user) return res.status(401).json({ error: 'User not found' });
    if (user.role !== 'moderator' && user.role !== 'admin') {
      return res.status(403).json({ error: 'Moderator access required' });
    }
    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};