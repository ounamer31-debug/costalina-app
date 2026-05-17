const mongoose = require('mongoose');

const photoSchema = new mongoose.Schema({
  data:        { type: Buffer, required: true },
  contentType: { type: String, required: true },
  uploadedBy:  { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
}, { timestamps: true });

module.exports = mongoose.model('Photo', photoSchema);