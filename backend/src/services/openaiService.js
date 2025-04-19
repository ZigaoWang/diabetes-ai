require('dotenv').config();
const { OpenAI } = require('openai');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

/**
 * 分析食物图片并提供健康饮食参考信息
 * @param {string} imagePath - 图片路径
 * @returns {Promise<Object>} - 包含食物分析和建议的对象
 */
async function analyzeFoodImage(imagePath) {
  try {
    const base64Image = await fileToBase64(imagePath);

    console.log('开始调用OpenAI分析图片...');
    const response = await openai.chat.completions.create({
      model: "gpt-4o",  // 确保使用gpt-4o模型
      max_tokens: 1000,
      messages: [
        {
          role: "system",
          content: `你是一位食物营养分析助手。请分析图片中的食物，并提供以下参考信息（注意：这些只是一般性参考，不构成医疗建议）：
            1. 食物名称：识别图片中的主要食物
            2. 碳水化合物含量：估计高/中/低
            3. 适合控制血糖人群食用指数：参考值，分为"适量食用"/"谨慎少量食用"/"建议避免"
            4. 建议食用量：一般人群的参考量
            5. 营养价值：主要营养素简述
            6. 健康饮食小贴士：与这类食物相关的一般性健康饮食建议
            
            以JSON格式输出，字段包括：foodName, carbContent, suitabilityIndex, recommendedAmount, nutrients, healthTips。
            请确保输出的是有效的JSON格式。`
        },
        {
          role: "user",
          content: [
            { type: "text", text: "请分析这张食物图片，并给出健康饮食参考信息" },
            { type: "image_url", image_url: { url: `data:image/jpeg;base64,${base64Image}` } }
          ]
        }
      ]
    });

    console.log('OpenAI响应成功, 开始解析内容');
    
    // 解析JSON响应
    const content = response.choices[0].message.content;
    console.log('原始响应内容:', content);
    
    try {
      // 尝试直接解析JSON
      const parsedData = JSON.parse(content);
      console.log('成功解析JSON:', parsedData);
      return parsedData;
    } catch (parseError) {
      console.log('直接解析JSON失败，尝试提取JSON部分');
      // 如果不是纯JSON，尝试提取JSON部分
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const extractedJson = jsonMatch[0];
        console.log('提取的JSON:', extractedJson);
        const parsedData = JSON.parse(extractedJson);
        console.log('成功解析提取的JSON:', parsedData);
        return parsedData;
      }
      
      // 如果仍然无法解析，返回一个有结构的错误对象
      console.log('无法解析响应为JSON，返回结构化数据');
      
      // 尝试从内容中提取关键信息
      const foodNameMatch = content.match(/食物名称[：:]\s*([^\n]+)/);
      const carbMatch = content.match(/碳水化合物[^:：]*[：:]\s*([^\n]+)/);
      const suitabilityMatch = content.match(/适合[^:：]*[：:]\s*([^\n]+)/);
      const amountMatch = content.match(/建议食用量[：:]\s*([^\n]+)/);
      const nutrientsMatch = content.match(/营养[^:：]*[：:]\s*([^\n]+)/);
      const tipsMatch = content.match(/贴士[：:]\s*([^\n]+)/);
      
      return {
        foodName: foodNameMatch ? foodNameMatch[1].trim() : "未能识别食物",
        carbContent: carbMatch ? carbMatch[1].trim() : "未知",
        suitabilityIndex: suitabilityMatch ? suitabilityMatch[1].trim() : "不确定",
        recommendedAmount: amountMatch ? amountMatch[1].trim() : "参考量不详",
        nutrients: nutrientsMatch ? nutrientsMatch[1].trim() : "未能识别营养成分",
        healthTips: tipsMatch ? tipsMatch[1].trim() : "建议咨询营养师获取个性化建议"
      };
    }
  } catch (error) {
    console.error('分析食物图片出错:', error);
    // 返回一个默认的分析结果而不是抛出错误，避免前端崩溃
    return {
      foodName: "分析失败",
      carbContent: "未知",
      suitabilityIndex: "不确定",
      recommendedAmount: "无法确定",
      nutrients: "未知",
      healthTips: "请尝试使用更清晰的食物照片"
    };
  }
}

/**
 * 将文件转换为Base64编码
 * @param {string} filePath - 文件路径
 * @returns {Promise<string>} - Base64编码的字符串
 */
function fileToBase64(filePath) {
  const fs = require('fs');
  return new Promise((resolve, reject) => {
    fs.readFile(filePath, (err, data) => {
      if (err) {
        console.error('读取文件失败:', err);
        reject(err);
      } else {
        resolve(data.toString('base64'));
      }
    });
  });
}

module.exports = {
  analyzeFoodImage
}; 