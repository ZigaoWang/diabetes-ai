import SwiftUI

struct ResultView: View {
    let result: FoodAnalysisResponse.FoodAnalysisData
    let image: UIImage
    @ObservedObject var viewModel: FoodAnalysisViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isSpeaking = true
    
    // 检查是否有有效的分析结果
    var hasValidResult: Bool {
        !(result.foodName == "未能识别的食物" || 
          result.foodName == "分析失败" || 
          result.foodName == "未能识别食物")
    }
    
    // 根据适合度返回颜色
    func suitabilityColor(_ suitability: String) -> Color {
        switch suitability.lowercased() {
        case "适量食用", "低", "适合", "适合多数人食用": return .green
        case "谨慎少量食用", "中", "建议少量食用": return .orange
        case "建议避免", "高", "不适合": return .red
        default: return .gray
        }
    }
    
    // 根据碳水含量返回颜色
    func carbContentColor(_ content: String) -> Color {
        switch content.lowercased() {
        case "低": return .green
        case "中": return .orange
        case "高": return .red
        default: return .gray
        }
    }
    
    // 获取简单的食用建议
    func simplifiedSuitability(_ suitability: String) -> (text: String, icon: String, color: Color) {
        let lowerSuitability = suitability.lowercased()
        if lowerSuitability.contains("适量") || lowerSuitability.contains("适合") || lowerSuitability.contains("低") {
            return ("建议食用", "checkmark.circle.fill", .green)
        } else if lowerSuitability.contains("谨慎") || lowerSuitability.contains("少量") || lowerSuitability.contains("中") {
            return ("适量食用", "exclamationmark.triangle.fill", .orange)
        } else if lowerSuitability.contains("避免") || lowerSuitability.contains("不适合") || lowerSuitability.contains("高") {
            return ("不建议食用", "xmark.circle.fill", .red)
        } else {
            return ("不确定", "questionmark.circle.fill", .gray)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 食物图片和名称
                ZStack(alignment: .bottom) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    
                    // 食物名称覆盖在图片底部
                    Text(result.foodName)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Material.ultraThinMaterial)
                        .cornerRadius(10)
                        .padding(.bottom, 16)
                }
                .padding(.top, 8)
                
                if hasValidResult {
                    // 正常的分析结果显示
                    
                    // 食用建议指示器
                    let recommendation = simplifiedSuitability(result.suitabilityIndex)
                    VStack(spacing: 10) {
                        Text("食用建议")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 16) {
                            Image(systemName: recommendation.icon)
                                .font(.system(size: 40))
                                .foregroundColor(recommendation.color)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recommendation.text)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(recommendation.color)
                                
                                Text(result.suitabilityIndex)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(recommendation.color.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // 营养信息卡片
                    VStack(spacing: 20) {
                        // 碳水含量和建议食用量卡片
                        HStack(spacing: 12) {
                            // 碳水含量卡片
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundColor(carbContentColor(result.carbContent))
                                    Text("碳水含量")
                                        .font(.headline)
                                }
                                
                                Text(result.carbContent)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(carbContentColor(result.carbContent))
                            }
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // 建议食用量卡片
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "fork.knife")
                                        .foregroundColor(.blue)
                                    Text("建议量")
                                        .font(.headline)
                                }
                                
                                Text(result.recommendedAmount)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // 营养价值
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                                Text("营养价值")
                                    .font(.headline)
                            }
                            
                            Text(result.nutrients)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        // 健康小贴士
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("健康小贴士")
                                    .font(.headline)
                            }
                            
                            Text(result.healthTips)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // 无法识别食物时的友好提示
                    VStack(spacing: 25) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                        
                        Text("无法识别图片中的食物")
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                        
                        Text("请尝试拍摄更清晰的食物照片，或从不同角度拍摄。确保照片光线充足，食物特征明显。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        // 小贴士卡片
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("拍照小贴士")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                TipRow(text: "保持食物在画面中央")
                                TipRow(text: "确保光线充足")
                                TipRow(text: "拍摄单一食物效果更好")
                                TipRow(text: "避免过度模糊或阴影")
                            }
                            .padding(.leading)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                    }
                    .padding(.vertical, 20)
                }
                
                Spacer(minLength: 20)
                
                // 语音播报和返回按钮
                VStack(spacing: 16) {
                    // 语音控制按钮（只在有有效结果时才显示）
                    if hasValidResult {
                        Button(action: {
                            if isSpeaking {
                                viewModel.stopSpeaking()
                            } else {
                                viewModel.speakAnalysisResult(result)
                            }
                            isSpeaking.toggle()
                        }) {
                            HStack {
                                Image(systemName: isSpeaking ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.title2)
                                Text(isSpeaking ? "停止语音" : "语音播报")
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    // 返回按钮
                    Button(action: {
                        viewModel.stopSpeaking()
                        viewModel.clearAnalysis()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(hasValidResult ? "返回" : "重新拍照")
                            .fontWeight(.medium)
                            .padding(.vertical, 12)
                            .frame(width: 150)
                            .background(hasValidResult ? Color.gray.opacity(0.2) : Color.blue)
                            .foregroundColor(hasValidResult ? .primary : .white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 30)
            }
            .padding(.bottom)
        }
        .onDisappear {
            viewModel.stopSpeaking()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 小贴士行组件
struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 14))
                .padding(.top, 2)
            
            Text(text)
                .font(.subheadline)
        }
    }
}