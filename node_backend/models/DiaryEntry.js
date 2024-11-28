const mongoose = require('mongoose');

// DiaryEntry 스키마 정의
const DiaryEntrySchema = new mongoose.Schema({
  user_id: { type: String, required: true }, // UserProfile과 연결 (user_id 사용)
  date: { type: Date, required: true }, // 일기 작성 날짜
  mood: { type: [String], default: [] }, // 오늘의 기분 (복수 선택 가능)
  conflict_or_mistake: { type: String, default: null }, // 갈등 또는 실수 상황
  parent_response_child_reaction: { type: String, default: null }, // 부모 대처와 아이 반응
  praise_situation: { type: String, default: null }, // 칭찬한 상황
}, { timestamps: true }); // createdAt, updatedAt 자동 추가

module.exports = mongoose.model('DiaryEntry', DiaryEntrySchema);
