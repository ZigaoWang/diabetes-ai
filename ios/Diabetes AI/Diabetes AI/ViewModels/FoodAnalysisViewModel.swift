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
        // 简化食用建议
        let suitabilityText: String
        let lowerSuitability = result.suitabilityIndex.lowercased()
        if lowerSuitability.contains("适量") || lowerSuitability.contains("适合") || lowerSuitability.contains("低") {
            suitabilityText = "建议食用"
        } else if lowerSuitability.contains("谨慎") || lowerSuitability.contains("少量") || lowerSuitability.contains("中") {
            suitabilityText = "适量食用"
        } else if lowerSuitability.contains("避免") || lowerSuitability.contains("不适合") || lowerSuitability.contains("高") {
            suitabilityText = "不建议食用"
        } else {
            suitabilityText = "建议参考营养师意见"
        }
        
        let speechText = """
        食物：\(result.foodName)。
        食用建议：\(suitabilityText)。
        碳水含量：\(result.carbContent)。
        建议食用量：\(result.recommendedAmount)。
        小贴士：\(result.healthTips)
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