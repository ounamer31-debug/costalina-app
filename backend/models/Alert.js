const mongoose = require('mongoose');

const alertSchema = new mongoose.Schema({
  beachId:    { type: String, required: true },
  beachName:  { type: String, required: true },
  message:    { type: String, required: true },
  risk:       { type: String, enum: ['stable', 'modere', 'eleve'], default: 'stable' },
  read:       { type: Boolean, default: false },
}, { timestamps: true });

module.exports = mongoose.model('Alert', alertSchema);