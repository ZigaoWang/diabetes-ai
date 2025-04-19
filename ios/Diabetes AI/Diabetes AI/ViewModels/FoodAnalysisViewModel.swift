import Foundation
import UIKit
import SwiftUI
import AVFoundation

class FoodAnalysisViewModel: ObservableObject {
    @Published var isAnalyzing = false
    @Published var selectedImage: UIImage?
    @Published var analysisResult: FoodAnalysisResponse.FoodAnalysisData?
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var historyItems: [HistoryItem] = []
    
    private let synthesizer = AVSpeechSynthesizer()
    
    // 分析食物图片
    func analyzeImage(_ image: UIImage) {
        selectedImage = image
        isAnalyzing = true
        errorMessage = nil
        
        NetworkService.shared.analyzeFoodImage(image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                
                switch result {
                case .success(let response):
                    self?.analysisResult = response.data
                    
                    // 将结果添加到历史记录
                    let historyItem = HistoryItem(
                        id: UUID(),
                        date: Date(),
                        foodName: response.data.foodName,
                        image: image,
                        analysisData: response.data
                    )
                    self?.historyItems.insert(historyItem, at: 0)
                    
                    // 语音播报结果
                    self?.speakAnalysisResult(response.data)
                    
                case .failure(let error):
                    self?.errorMessage = "分析失败: \(error.localizedDescription)"
                    self?.showError = true
                }
            }
        }
    }
    
    // 语音播报分析结果
    func speakAnalysisResult(_ result: FoodAnalysisResponse.FoodAnalysisData) {
        let speechText = """
        食物名称：\(result.foodName)。
        碳水化合物含量：\(result.carbContent)。
        适合控糖人群：\(result.suitabilityIndex)。
        建议食用量：\(result.recommendedAmount)。
        营养价值：\(result.nutrients)。
        健康小贴士：\(result.healthTips)
        """
        
        let utterance = AVSpeechUtterance(string: speechText)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    // 停止语音播报
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    // 清除当前分析结果
    func clearAnalysis() {
        selectedImage = nil
        analysisResult = nil
        errorMessage = nil
    }
}

// 历史记录项目模型
struct HistoryItem: Identifiable {
    let id: UUID
    let date: Date
    let foodName: String
    let image: UIImage
    let analysisData: FoodAnalysisResponse.FoodAnalysisData
} 