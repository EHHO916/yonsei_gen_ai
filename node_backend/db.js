const mongoose = require('mongoose');
const dotenv = require('dotenv');

// .env 파일 로드
dotenv.config({ path: './node_backend/.env' });

const connectDB = async () => {
  try {
    console.log('MONGO_URI:', process.env.MONGO_URI);
    dotenv.config();
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error(`MongoDB connection failed: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;