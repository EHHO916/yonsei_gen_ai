const express = require('express');
const router = express.Router();
const DiaryEntry = require('../models/DiaryEntry');

// Test endpoint
router.get('/test', (req, res) => {
  res.status(200).json({ message: 'Diary API is working!' });
});

// 새로운 일기 생성
router.post('/create', async (req, res) => {
  try {
    console.log('Received diary entry creation request:', req.body);
    const diaryEntry = new DiaryEntry(req.body);
    const savedEntry = await diaryEntry.save();
    console.log('Successfully saved diary entry:', savedEntry);
    res.status(201).json(savedEntry);
  } catch (err) {
    console.error('Error creating diary entry:', err);
    res.status(400).json({ error: err.message });
  }
});

// 특정 사용자 일기 목록 가져오기
router.get('/:user_id', async (req, res) => {
  try {
    const entries = await DiaryEntry.find({ user_id: req.params.user_id });
    res.status(200).json(entries);
  } catch (err) {
    res.status(404).json({ error: err.message });
  }
});

// 특정 일기 가져오기
router.get('/:user_id/:date', async (req, res) => {
  try {
    const entry = await DiaryEntry.findOne({
      user_id: req.params.user_id,
      date: req.params.date,
    });
    if (!entry) throw new Error('Diary entry not found');
    res.status(200).json(entry);
  } catch (err) {
    res.status(404).json({ error: err.message });
  }
});

// 특정 일기 수정
router.put('/update/:id', async (req, res) => {
  try {
    const updatedEntry = await DiaryEntry.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });
    res.status(200).json(updatedEntry);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// 특정 일기 삭제
router.delete('/delete/:id', async (req, res) => {
  try {
    await DiaryEntry.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Diary entry deleted successfully' });
  } catch (err) {
    res.status(404).json({ error: err.message });
  }
});

module.exports = router;