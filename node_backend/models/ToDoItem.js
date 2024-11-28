const mongoose = require('mongoose');

// ToDoItem 스키마 정의
const ToDoItemSchema = new mongoose.Schema({
  diary_entry_id: { type: mongoose.Schema.Types.ObjectId, ref: 'DiaryEntry', required: true }, // DiaryEntry와 연결
  task: { type: String, required: true }, // To-Do 항목 내용
  is_completed: { type: Boolean, default: false }, // 완료 여부
}, { timestamps: true }); // createdAt, updatedAt 자동 추가

module.exports = mongoose.model('ToDoItem', ToDoItemSchema);
