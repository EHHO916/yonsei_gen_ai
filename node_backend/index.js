const express = require('express');
const connectDB = require('./db');
const dotenv = require('dotenv');
const cors = require('cors'); // CORS 에러 방지를 위한 미들웨어, 터미널에 npm install cors 하셈
const morgan = require('morgan'); // 로깅 미들웨어

dotenv.config({ path: './node_backend/.env' });

const app = express();
const PORT = process.env.NODE_PORT || 3000;

// MongoDB 연결
connectDB();

// 미들웨어
app.use(cors()); // 클라이언트와의 Cross-Origin 문제 해결, npm install cors 꼬옥 하기~~!!
app.use(express.json()); // JSON 요청을 처리하기 위한 미들웨어
app.use(morgan('dev')); // 요청 및 응답 로깅

// 기본 라우트
app.get('/', (req, res) => {
  res.send('API is running...');
});

// 라우트 연결
app.use('/api/diary', require('./routes/diaryRoutes'));
app.use('/api/todo', require('./routes/todoRoutes'));
app.use('/api/chat', require('./routes/chatRoutes'));

// 404 처리 (라우트 없음)
app.use((req, res, next) => {
  res.status(404).json({ error: 'Route not found' });
});

// 서버 에러 처리
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal Server Error' });
});

// 서버 시작
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});