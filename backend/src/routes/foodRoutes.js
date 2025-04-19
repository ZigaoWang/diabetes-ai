const express = require('express');
const multer = require('multer');
const path = require('path');
const router = express.Router();
const { analyzeFoodFromImage, getAnalysisHistory } = require('../controllers/foodController');

// 配置文件上传
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../../uploads'));
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 限制10MB
  fileFilter: (req, file, cb) => {
    // 只接受图片文件
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('只支持上传图片文件！'));
    }
  }
});

// 上传和分析食物图片路由
router.post('/analyze-food', upload.single('foodImage'), analyzeFoodFromImage);

// 获取历史分析记录
router.get('/history', getAnalysisHistory);

// 测试路由
router.get('/test', (req, res) => {
  res.json({ message: '食物分析API测试成功' });
});

module.exports = router; 