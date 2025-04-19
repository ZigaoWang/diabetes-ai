require('dotenv').config();
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const foodRoutes = require('./routes/foodRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件配置
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 静态文件目录
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// 路由配置
app.use('/api', foodRoutes);

// 测试路由
app.get('/', (req, res) => {
  res.json({ message: '糖尿病AI饮食助手API已启动' });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`服务器运行在端口: ${PORT}`);
}); 