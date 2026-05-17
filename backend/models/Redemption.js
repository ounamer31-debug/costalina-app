const mongoose = require('mongoose');

const redemptionSchema = new mongoose.Schema({
  userId:     { type: String, required: true, index: true },
  rewardId:   { type: mongoose.Schema.Types.ObjectId, ref: 'Reward', required: true },
  rewardName: { type: String, required: true },
  cost:       { type: Number, required: true },
  code:       { type: String, required: true },   // claim code
  status:     { type: String, enum: ['pending', 'fulfilled', 'cancelled'], default: 'pending' },
}, { timestamps: true });

module.exports = mongoose.model('Redemption', redemptionSchema);