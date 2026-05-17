const mongoose = require('mongoose');

const alertSchema = new mongoose.Schema({
  beachId:    { type: String, required: true, index: true },
  beachName:  { type: String, required: true, maxlength: 120 },
  message:    { type: String, required: true, maxlength: 1000 },
  risk:       { type: String, enum: ['stable', 'modere', 'eleve'], default: 'stable' },
  readBy:     { type: [String], default: [] },
}, { timestamps: true });

alertSchema.index({ createdAt: -1 });

module.exports = mongoose.model('Alert', alertSchema);