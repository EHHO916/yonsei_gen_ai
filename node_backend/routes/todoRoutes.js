const express = require('express');
const router = express.Router();
const ToDoItem = require('../models/ToDoItem');

// 새로운 To-Do 생성
router.post('/create', async (req, res) => {
  try {
    const todo = new ToDoItem(req.body);
    const savedTodo = await todo.save();
    res.status(201).json(savedTodo);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// 특정 일기에 해당하는 To-Do 목록 가져오기
router.get('/:diary_entry_id', async (req, res) => {
  try {
    const todos = await ToDoItem.find({ diary_entry_id: req.params.diary_entry_id });
    res.status(200).json(todos);
  } catch (err) {
    res.status(404).json({ error: err.message });
  }
});

// 특정 To-Do 수정 (완료 상태 변경)
router.put('/update/:id', async (req, res) => {
  try {
    const updatedTodo = await ToDoItem.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });
    res.status(200).json(updatedTodo);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// 특정 To-Do 삭제
router.delete('/delete/:id', async (req, res) => {
  try {
    await ToDoItem.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'To-Do item deleted successfully' });
  } catch (err) {
    res.status(404).json({ error: err.message });
  }
});

module.exports = router;