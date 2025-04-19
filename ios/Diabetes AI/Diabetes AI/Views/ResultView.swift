import SwiftUI

struct ResultView: View {
    let result: FoodAnalysisResponse.FoodAnalysisData
    let image: UIImage
    @ObservedObject var viewModel: FoodAnalysisViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isSpeaking = true
    
    // 根据适合度返回颜色
    func suitabilityColor(_ suitability: String) -> Color {
        switch suitability.lowercased() {
        case "适量食用", "低", "适合": return .green
        case "谨慎少量食用", "中": return .orange
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 食物图片
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding()
                
                // 食物名称
                Text(result.foodName)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 碳水化合物含量
                HStack {
                    Text("碳水化合物含量:")
                        .fontWeight(.medium)
                    Text(result.carbContent)
                        .fontWeight(.bold)
                        .foregroundColor(carbContentColor(result.carbContent))
                }
                .padding(.horizontal)
                
                // 适合度信息
                HStack {
                    Text("适合控糖人群:")
                        .fontWeight(.medium)
                    Text(result.suitabilityIndex)
                        .fontWeight(.bold)
                        .foregroundColor(suitabilityColor(result.suitabilityIndex))
                }
                .padding(.horizontal)
                
                // 建议食用量
                VStack(alignment: .leading, spacing: 10) {
                    Text("建议食用量")
                        .font(.headline)
                    
                    Text(result.recommendedAmount)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // 营养成分
                VStack(alignment: .leading, spacing: 10) {
                    Text("营养价值")
                        .font(.headline)
                    
                    Text(result.nutrients)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // 健康小贴士
                VStack(alignment: .leading, spacing: 10) {
                    Text("健康饮食小贴士")
                        .font(.headline)
                    
                    Text(result.healthTips)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // 语音控制按钮
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
                            .font(.title)
                        Text(isSpeaking ? "停止语音" : "播放语音")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
                
                // 返回按钮
                Button(action: {
                    viewModel.stopSpeaking()
                    viewModel.clearAnalysis()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("返回")
                        .padding()
                        .foregroundColor(.white)
                        .frame(width: 150)
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
        .onDisappear {
            viewModel.stopSpeaking()
        }
    }
}