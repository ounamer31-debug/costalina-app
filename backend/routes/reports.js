const express            = require('express');
const router             = express.Router();
const Report             = require('../models/Report');
const User               = require('../models/User');
const auth               = require('../middleware/auth');
const requireModerator   = require('../middleware/requireModerator');
const { recomputeBeachRisk } = require('../utils/riskService');

const POINTS_ON_SUBMIT     = 5;
const POINTS_ON_VERIFY     = 20;
const POINTS_PHOTO_BONUS   = 10;

const ALLOWED_REPORT_FIELDS = ['beachId', 'type', 'severity', 'message', 'photoUrl', 'lat', 'lng'];
function pickReport(obj) {
  const out = {};
  for (const k of ALLOWED_REPORT_FIELDS) if (obj[k] !== undefined) out[k] = obj[k];
  return out;
}

// GET /api/reports?beachId=xxx
router.get('/', async (req, res) => {
  try {
    const filter = req.query.beachId ? { beachId: req.query.beachId } : {};
    const page  = Math.max(1, parseInt(req.query.page)  || 1);
    const limit = Math.min(100, parseInt(req.query.limit) || 20);
    const reports = await Report.find(filter)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit);
    res.json(reports);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/reports — auth required, userId taken from JWT
router.post('/', auth, async (req, res) => {
  try {
    const report = new Report({ ...pickReport(req.body), userId: req.user.id });
    await report.save();

    // Submission points (small encouragement)
    User.findByIdAndUpdate(req.user.id, { $inc: { points: POINTS_ON_SUBMIT } })
      .catch(err => console.error('points award on submit failed:', err.message));

    // Fire-and-forget risk recompute — never blocks the response
    recomputeBeachRisk(report.beachId).catch(err =>
      console.error('riskRecompute on create failed:', err.message));
    res.status(201).json(report);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PATCH /api/reports/:id/status — moderator/admin only
router.patch('/:id/status', auth, requireModerator, async (req, res) => {
  try {
    const newStatus = req.body.status;
    if (!['pending', 'verified', 'resolved', 'rejected'].includes(newStatus)) {
      return res.status(400).json({ error: 'invalid_status' });
    }

    // Atomic transition to "verified": only succeeds if the report wasn't already verified.
    // This is what guarantees points are awarded exactly once even under concurrent requests.
    let report;
    let awardedNow = false;
    if (newStatus === 'verified') {
      report = await Report.findOneAndUpdate(
        { _id: req.params.id, status: { $ne: 'verified' } },
        { status: 'verified' },
        { new: true }
      );
      if (report) {
        awardedNow = true;
      } else {
        // Either not found OR already verified — disambiguate
        report = await Report.findById(req.params.id);
        if (!report) return res.status(404).json({ error: 'Report not found' });
      }
    } else {
      report = await Report.findByIdAndUpdate(
        req.params.id,
        { status: newStatus },
        { new: true }
      );
      if (!report) return res.status(404).json({ error: 'Report not found' });
    }

    if (awardedNow && report.userId) {
      const award = POINTS_ON_VERIFY + (report.photoUrl ? POINTS_PHOTO_BONUS : 0);
      User.findByIdAndUpdate(report.userId, { $inc: { points: award } })
        .catch(err => console.error('points award on verify failed:', err.message));
    }

    recomputeBeachRisk(report.beachId).catch(err =>
      console.error('riskRecompute on status failed:', err.message));
    res.json(report);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /api/reports/timeline?beachId=xxx — monthly aggregates for last 12 months
router.get('/timeline', async (req, res) => {
  try {
    const beachId = req.query.beachId;
    if (!beachId) return res.status(400).json({ error: 'beachId required' });
    const since = new Date();
    since.setMonth(since.getMonth() - 11);
    since.setDate(1);
    since.setHours(0, 0, 0, 0);
    const all = await Report.find({ beachId, createdAt: { $gte: since } })
      .select('type createdAt').lean();
    // Bucket per YYYY-MM
    const buckets = {};
    for (let i = 0; i < 12; i++) {
      const d = new Date(since.getFullYear(), since.getMonth() + i, 1);
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
      buckets[key] = { month: key, total: 0, erosion: 0, pollution: 0, other: 0 };
    }
    for (const r of all) {
      const d = r.createdAt;
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
      if (!buckets[key]) continue;
      buckets[key].total++;
      if (r.type === 'erosion') buckets[key].erosion++;
      else if (r.type === 'pollution') buckets[key].pollution++;
      else buckets[key].other++;
    }
    res.json(Object.values(buckets));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/reports/stats/me — current user's contribution stats
router.get('/stats/me', auth, async (req, res) => {
  try {
    const userId = req.user.id;
    const all = await Report.find({ userId }).select('type status').lean();
    const stats = {
      total:    all.length,
      pending:  all.filter(r => r.status === 'pending').length,
      verified: all.filter(r => r.status === 'verified').length,
      resolved: all.filter(r => r.status === 'resolved').length,
      rejected: all.filter(r => r.status === 'rejected').length,
      byType:   {},
    };
    for (const r of all) {
      stats.byType[r.type] = (stats.byType[r.type] || 0) + 1;
    }
    res.json(stats);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/reports/me — current user's reports (paginated)
router.get('/me', auth, async (req, res) => {
  try {
    const page  = Math.max(1, parseInt(req.query.page)  || 1);
    const limit = Math.min(50,  parseInt(req.query.limit) || 20);
    const reports = await Report.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit);
    res.json(reports);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/reports/export — returns CSV. Unscoped exports require moderator;
// users may export their own beach by passing ?beachId.
router.get('/export', auth, async (req, res) => {
  try {
    let filter;
    if (req.query.beachId) {
      filter = { beachId: req.query.beachId };
    } else {
      const user = await User.findById(req.user.id).select('role').lean();
      if (!user || (user.role !== 'moderator' && user.role !== 'admin')) {
        return res.status(403).json({ error: 'beachId required' });
      }
      filter = {};
    }
    const reports = await Report.find(filter).sort({ createdAt: -1 }).limit(1000);
    const header = 'ID,BeachID,UserID,Type,Message,Status,PhotoUrl,CreatedAt';
    const rows = reports.map(r => [
      r._id,
      r.beachId,
      r.userId,
      r.type,
      `"${(r.message || '').replace(/"/g, '""')}"`,
      r.status,
      r.photoUrl || '',
      r.createdAt ? r.createdAt.toISOString() : '',
    ].join(','));
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename=signalements.csv');
    res.send([header, ...rows].join('\n'));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/reports/:id — auth required, only author can delete
router.delete('/:id', auth, async (req, res) => {
  try {
    const report = await Report.findById(req.params.id);
    if (!report) return res.status(404).json({ error: 'Report not found' });
    if (report.userId.toString() !== req.user.id.toString()) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    await report.deleteOne();
    res.json({ message: 'Deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;