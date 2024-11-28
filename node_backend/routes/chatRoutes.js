const express = require('express');
const router = express.Router();
const ChatHistory = require('../models/ChatHistory');

// 새로운 채팅 기록 저장
router.post('/save', async (req, res) => {
  try {
    const chat = new ChatHistory(req.body);
    const savedChat = await chat.save();
    res.status(201).json(savedChat);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// 특정 일기에 해당하는 채팅 기록 가져오기
router.get('/:diary_entry_id', async (req, res) => {
  try {
    const chats = await ChatHistory.find({ diary_entry_id: req.params.diary_entry_id });
    res.status(200).json(chats);
  } catch (err) {
    res.status(404).json({ error: err.message });
  }
});

// 특정 채팅 기록 삭제
router.delete('/delete/:id', async (req, res) => {
  try {
    await ChatHistory.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Chat history deleted successfully' });
  } catch (err) {
    res.status(404).json({ error: err.message });
  }
});

module.exports = router;