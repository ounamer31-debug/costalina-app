const express = require('express');
const jwt     = require('jsonwebtoken');
const crypto  = require('crypto');
const User    = require('../models/User');
const auth    = require('../middleware/auth');
const mailer  = require('../utils/mailer');

const router = express.Router();

// Reject obviously weak passwords. We keep the bar reasonable for a beach app;
// real risk is mass-credential-stuffing, which rate-limiting also handles.
function validatePassword(pw) {
  if (typeof pw !== 'string' || pw.length < 8) return 'weak_password';
  if (!/[a-zA-Z]/.test(pw) || !/[0-9]/.test(pw)) return 'weak_password';
  return null;
}

function makeToken(user) {
  return jwt.sign(
    { id: user._id, email: user.email, name: user.name },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
}

// POST /api/auth/register
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password)
    return res.status(400).json({ error: 'Name, email and password are required' });

  const pwErr = validatePassword(password);
  if (pwErr) return res.status(400).json({ error: pwErr });

  if (await User.findOne({ email }))
    return res.status(409).json({ error: 'email_in_use' });

  try {
    const user  = await User.create({ name, email, password });
    const token = makeToken(user);
    res.status(201).json({ token, name: user.name, email: user.email, avatarUrl: user.avatarUrl, points: user.points, role: user.role });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ error: 'Email and password are required' });

  const user = await User.findOne({ email });
  if (!user || !(await user.comparePassword(password)))
    return res.status(401).json({ error: 'invalid_credential' });

  const token = makeToken(user);
  res.json({ token, name: user.name, email: user.email, avatarUrl: user.avatarUrl, points: user.points, role: user.role });
});

// GET /api/auth/me
router.get('/me', auth, async (req, res) => {
  const user = await User.findById(req.user.id).select('-password -resetOtp -resetOtpExpiry');
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});

// PUT /api/auth/me — update profile (name, avatarUrl)
router.put('/me', auth, async (req, res) => {
  try {
    const { name, avatarUrl } = req.body;
    const updates = {};
    if (name)      updates.name      = name.trim();
    if (avatarUrl !== undefined) updates.avatarUrl = avatarUrl;

    const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true })
      .select('-password -resetOtp -resetOtpExpiry');
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /api/auth/forgot-password — send 6-digit OTP to email
router.post('/forgot-password', async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: 'Email required' });

  const user = await User.findOne({ email });
  // Always respond OK so we don't leak whether the email exists
  if (!user) return res.json({ message: 'otp_sent' });

  const otp    = String(crypto.randomInt(100000, 999999));
  const expiry = new Date(Date.now() + 15 * 60 * 1000); // 15 min

  // Store hashed OTP
  user.resetOtp       = crypto.createHash('sha256').update(otp).digest('hex');
  user.resetOtpExpiry = expiry;
  await user.save({ validateBeforeSave: false });

  // Send email (falls back to console log if email not configured)
  const sent = await mailer.sendOtp(email, user.name, otp);
  if (!sent) console.log(`[DEV] Password reset OTP for ${email}: ${otp}`);

  res.json({ message: 'otp_sent' });
});

// POST /api/auth/reset-password — verify OTP and set new password
router.post('/reset-password', async (req, res) => {
  const { email, otp, newPassword } = req.body;
  if (!email || !otp || !newPassword)
    return res.status(400).json({ error: 'email, otp and newPassword are required' });

  const pwErr = validatePassword(newPassword);
  if (pwErr) return res.status(400).json({ error: pwErr });

  const user = await User.findOne({ email });
  if (!user || !user.resetOtp || !user.resetOtpExpiry)
    return res.status(400).json({ error: 'invalid_otp' });

  if (user.resetOtpExpiry < new Date())
    return res.status(400).json({ error: 'otp_expired' });

  const hashed = crypto.createHash('sha256').update(otp).digest('hex');
  if (hashed !== user.resetOtp)
    return res.status(400).json({ error: 'invalid_otp' });

  user.password       = newPassword;
  user.resetOtp       = null;
  user.resetOtpExpiry = null;
  await user.save();

  res.json({ message: 'password_reset' });
});

module.exports = router;