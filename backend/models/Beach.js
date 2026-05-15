const mongoose = require('mongoose');

const beachSchema = new mongoose.Schema({
  id:             { type: String, required: true, unique: true },
  name:           { type: String, required: true },
  city:           { type: String, required: true },
  photoUrl:       { type: String, default: '' },
  risk:           { type: String, enum: ['stable', 'modere', 'eleve'], default: 'stable' },
  lastUpdate:     { type: String, default: '' },
  erosionMeters:  { type: Number, default: 0 },
  lat:            { type: Number, required: true },
  lng:            { type: Number, required: true },
}, { timestamps: true });

module.exports = mongoose.model('Beach', beachSchema);