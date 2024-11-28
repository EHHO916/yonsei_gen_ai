const mongoose = require('mongoose');

const userProfileSchema = new mongoose.Schema({
  googleId: {
    type: String,
    required: true,
    unique: true
  },
  email: String,
  displayName: String,
  photoUrl: String,
  mbti_result: String
}, {
  timestamps: true
});

module.exports = mongoose.model('UserProfile', userProfileSchema);