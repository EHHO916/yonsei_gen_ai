const mongoose = require('mongoose');

// 사용자 프로필 스키마 정의
const UserProfileSchema = new mongoose.Schema({
  user_id: { type: String, unique: true, required: true },
  mbti_result: { type: String, maxlength: 4 },
}, { timestamps: true }); // timestamps는 createdAt, updatedAt 필드 자동 추가

module.exports = mongoose.model('UserProfile', UserProfileSchema);