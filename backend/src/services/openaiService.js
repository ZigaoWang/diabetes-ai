require('dotenv').config();
const { OpenAI } = require('openai');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

/**
 * 分析食物图片并提供基本营养信息
 * @param {string} imagePath - 图片路径
 * @returns {Promise<Object>} - 包含食物分析和信息的对象
 */
async function analyzeFoodImage(imagePath) {
  try {
    const base64Image = await fileToBase64(imagePath);

    console.log('开始调用OpenAI分析图片...');
    const response = await openai.chat.completions.create({
      model: "gpt-4.1",
      max_tokens: 1000,
      messages: [
        {
          role: "system",
          content: `请识别图片中的食物，并提供基本营养信息。不要提供任何医疗或健康建议，仅提供客观信息。
            请包含以下信息：
            1. 食物名称：图片中展示的是什么食物
            2. 大致热量：这类食物通常的热量水平（高/中/低）
            3. 主要营养成分：例如蛋白质、碳水、脂肪等主要成分
            4. 一般食用量：一般人的参考食用量
            5. 相关食物：与这种食物类似或可替代的其他食物
            
            请以JSON格式输出，包含以下字段：foodName, carbContent, suitabilityIndex, recommendedAmount, nutrients, healthTips。
            suitabilityIndex字段使用"适量食用"/"适合多数人食用"/"建议少量食用"等中性表述。
            healthTips字段仅提供一般性的食物信息，不包含健康建议。`
        },
        {
          role: "user",
          content: [
            { type: "text", text: "这是什么食物？请提供基本信息。" },
            { type: "image_url", image_url: { url: `data:image/jpeg;base64,${base64Image}` } }
          ]
        }
      ]
    });

    console.log('OpenAI响应成功, 开始解析内容');
    
    // 解析JSON响应
    const content = response.choices[0].message.content;
    console.log('原始响应内容:', content);
    
    // 如果AI拒绝分析，提供默认回复
    if (content.includes("unable to") || content.includes("can't help") || content.includes("cannot")) {
      console.log('OpenAI拒绝分析，返回默认数据');
      return {
        foodName: "未能识别的食物",
        carbContent: "信息不足",
        suitabilityIndex: "建议咨询营养师",
        recommendedAmount: "信息不足",
        nutrients: "需要更清晰的图片",
        healthTips: "请尝试上传更清晰的食物图片以获取准确分析"
      };
    }
    
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
      
      // 如果仍然无法解析，尝试从文本中提取信息
      console.log('无法解析响应为JSON，尝试从文本提取信息');
      
      // 尝试从文本中找到食物名称
      let foodName = "未能识别食物";
      if (content.includes("食物") || content.includes("图片")) {
        const foodMatches = content.match(/是(.*?)(?:。|，|,|\.|$)/);
        if (foodMatches && foodMatches[1]) {
          foodName = foodMatches[1].trim();
        }
      }
      
      // 返回一个简单的结果
      return {
        foodName: foodName,
        carbContent: "信息不足",
        suitabilityIndex: "建议咨询营养师获取个性化建议",
        recommendedAmount: "参考量不详",
        nutrients: "需要更详细分析",
        healthTips: "这是" + foodName + "，请咨询专业人士获取更多信息"
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