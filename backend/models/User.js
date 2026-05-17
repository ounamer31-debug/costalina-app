const mongoose = require('mongoose');
const bcrypt   = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name:           { type: String, required: true, trim: true },
  email:          { type: String, required: true, unique: true, lowercase: true, trim: true },
  password:       { type: String, required: true, minlength: 6 },
  avatarUrl:      { type: String, default: '' },
  resetOtp:       { type: String, default: null },
  resetOtpExpiry: { type: Date,   default: null },
  points:           { type: Number, default: 0 },
  role:             { type: String, enum: ['user', 'moderator', 'admin'], default: 'user' },
  followedBeaches:  { type: [String], default: [] },
}, { timestamps: true });

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

userSchema.methods.comparePassword = function (plain) {
  return bcrypt.compare(plain, this.password);
};

module.exports = mongoose.model('User', userSchema);