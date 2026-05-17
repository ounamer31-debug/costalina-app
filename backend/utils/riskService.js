const Beach  = require('../models/Beach');
const Report = require('../models/Report');
const Alert  = require('../models/Alert');

/**
 * Recompute a beach's risk level from the last 90 days of reports.
 *
 * Scoring rule (intentionally simple, transparent for citizen-science):
 *   score = sum( severity * weight(status) )
 *     where weight = { verified: 1.0, pending: 0.5, resolved: 0.1, rejected: 0 }
 *   only erosion / infrastructure / pollution reports count toward risk
 *
 * Thresholds:
 *   score >= 12  → eleve
 *   score >=  5  → modere
 *   else         → stable
 *
 * When the risk level *changes*, an Alert document is also created so the
 * change shows up in the in-app alerts feed.
 */
async function recomputeBeachRisk(beachId) {
  if (!beachId) return null;

  const beach = await Beach.findOne({ id: beachId });
  if (!beach) return null;

  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - 90);

  const reports = await Report.find({
    beachId,
    createdAt: { $gte: cutoff },
    type: { $in: ['erosion', 'infrastructure', 'pollution'] },
  }).select('type severity status').lean();

  const statusWeight = {
    verified: 1.0,
    pending:  0.5,
    resolved: 0.1,
    rejected: 0,
  };

  let score = 0;
  for (const r of reports) {
    const sev = r.severity || 3;
    const w   = statusWeight[r.status] ?? 0.5;
    score += sev * w;
  }

  let risk;
  if      (score >= 12) risk = 'eleve';
  else if (score >=  5) risk = 'modere';
  else                  risk = 'stable';

  const prevRisk = beach.risk;
  beach.risk = risk;
  beach.lastUpdate = new Date().toISOString().slice(0, 10);
  await beach.save();

  if (prevRisk !== risk) {
    await Alert.create({
      beachId:   beach.id,
      beachName: beach.name,
      risk,
      message:   _alertMessage(prevRisk, risk, beach.name),
    });
  }

  return { beachId, risk, score, changed: prevRisk !== risk };
}

function _alertMessage(prev, next, name) {
  const escalated =
    (prev === 'stable' && next !== 'stable') ||
    (prev === 'modere' && next === 'eleve');

  if (next === 'eleve' && escalated)  return `Risque élevé détecté sur ${name} — action recommandée`;
  if (next === 'modere' && escalated) return `Niveau de risque relevé à "modéré" sur ${name}`;
  if (next === 'stable') return `Bonne nouvelle : ${name} revient à un état stable`;
  return `Mise à jour du risque sur ${name} : ${prev} → ${next}`;
}

module.exports = { recomputeBeachRisk };