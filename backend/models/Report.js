const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
  beachId:   { type: String, required: true, index: true },
  userId:    { type: String, required: true, index: true },
  type:      {
    type: String,
    required: true,
    enum: ['erosion', 'pollution', 'wildlife', 'infrastructure', 'photo', 'other'],
    default: 'other',
  },
  severity:  { type: Number, min: 1, max: 5, default: 3 },
  message:   { type: String, default: '', maxlength: 1000 },
  photoUrl:  { type: String, default: '', maxlength: 1000 },
  status:    { type: String, enum: ['pending', 'verified', 'resolved', 'rejected'], default: 'pending' },
  lat:       { type: Number, min: -90,  max: 90  },
  lng:       { type: Number, min: -180, max: 180 },
  aiScore:   { type: Number, min: 0, max: 100 },
  aiReason:  { type: String, maxlength: 240 },
}, { timestamps: true });

module.exports = mongoose.model('Report', reportSchema);