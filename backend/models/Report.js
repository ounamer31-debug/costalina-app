const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
  beachId:   { type: String, required: true },
  userId:    { type: String, required: true },
  type:      { type: String, required: true },
  message:   { type: String, default: '' },
  photoUrl:  { type: String, default: '' },
  status:    { type: String, enum: ['pending', 'verified', 'resolved'], default: 'pending' },
  lat:       { type: Number },
  lng:       { type: Number },
}, { timestamps: true });

module.exports = mongoose.model('Report', reportSchema);