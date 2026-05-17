const mongoose = require('mongoose');

const rewardSchema = new mongoose.Schema({
  name:        { type: String, required: true },
  description: { type: String, default: '' },
  cost:        { type: Number, required: true, min: 1 },
  category:    { type: String, default: 'experience' },
  imageUrl:    { type: String, default: '' },
  active:      { type: Boolean, default: true },
}, { timestamps: true });

module.exports = mongoose.model('Reward', rewardSchema);