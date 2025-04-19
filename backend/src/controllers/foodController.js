const path = require('path');
const fs = require('fs');
const { analyzeFoodImage } = require('../services/openaiService');

/**
 * 处理食物图片上传和分析
 * @param {Object} req - Express请求对象
 * @param {Object} res - Express响应对象
 */
async function analyzeFoodFromImage(req, res) {
  try {
    if (!req.file) {
      return res.status(400).json({ 
        success: false,
        error: '请上传食物图片'
      });
    }

    console.log(`收到图片上传: ${req.file.originalname}, 大小: ${req.file.size} 字节`);
    const imagePath = req.file.path;
    
    // 检查文件是否有效
    if (!fs.existsSync(imagePath)) {
      return res.status(500).json({
        success: false,
        error: '服务器文件处理错误'
      });
    }
    
    console.log(`开始分析图片: ${imagePath}`);
    
    // 分析图片
    const analysisResult = await analyzeFoodImage(imagePath);
    
    console.log('分析完成，返回结果');
    
    // 返回分析结果
    res.json({
      success: true,
      data: analysisResult,
      imageUrl: `/uploads/${path.basename(imagePath)}`
    });
  } catch (error) {
    console.error('处理食物图片出错:', error);
    
    // 确保返回格式一致的结构化响应
    res.status(500).json({
      success: false,
      data: {
        foodName: "分析失败",
        carbContent: "未知",
        suitabilityIndex: "不确定",
        recommendedAmount: "无法确定",
        nutrients: "未知",
        healthTips: "服务器处理失败，请稍后重试"
      },
      error: error.message || '分析食物图片时出错'
    });
  }
}

/**
 * 获取历史分析结果
 * 注意：实际应用中应该连接数据库存储历史记录
 * 这里只是一个简化的示例
 */
function getAnalysisHistory(req, res) {
  // 这里应该连接数据库，为简化演示，返回模拟数据
  res.json({
    success: true,
    data: []
  });
}

module.exports = {
  analyzeFoodFromImage,
  getAnalysisHistory
}; 