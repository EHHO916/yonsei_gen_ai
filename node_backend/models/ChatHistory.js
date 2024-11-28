const mongoose = require('mongoose');

// ChatHistory 스키마 정의
const ChatHistorySchema = new mongoose.Schema({
  diary_entry_id: { type: mongoose.Schema.Types.ObjectId, ref: 'DiaryEntry', required: true }, // DiaryEntry와 연결
  message: { type: String, required: true }, // 사용자 메시지
  response: { type: String, required: true }, // AI 응답
  timestamp: { type: Date, default: Date.now }, // 대화 발생 시간
}, { timestamps: true });

module.exports = mongoose.model('ChatHistory', ChatHistorySchema);