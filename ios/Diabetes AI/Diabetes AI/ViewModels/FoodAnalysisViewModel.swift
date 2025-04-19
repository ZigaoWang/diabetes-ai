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
    private let historyKey = "foodAnalysisHistory"
    
    init() {
        loadHistory()
    }
    
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
                    
                    // 保存历史记录到本地
                    self?.saveHistory()
                    
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
    
    // 保存历史记录到本地
    private func saveHistory() {
        do {
            let historyData = try historyItems.map { try $0.encoded() }
            UserDefaults.standard.set(historyData, forKey: historyKey)
            print("历史记录已保存，共\(historyData.count)条")
        } catch {
            print("保存历史记录失败: \(error)")
        }
    }
    
    // 从本地加载历史记录
    private func loadHistory() {
        guard let historyData = UserDefaults.standard.array(forKey: historyKey) as? [Data] else {
            print("没有找到历史记录")
            return
        }
        
        historyItems = historyData.compactMap { data in
            do {
                return try HistoryItem.decode(from: data)
            } catch {
                print("解码历史记录项目失败: \(error)")
                return nil
            }
        }
        
        print("成功加载\(historyItems.count)条历史记录")
    }
    
    // 删除历史记录
    func clearHistory() {
        historyItems.removeAll()
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
}

// 历史记录项目模型
struct HistoryItem: Identifiable {
    let id: UUID
    let date: Date
    let foodName: String
    let image: UIImage
    let analysisData: FoodAnalysisResponse.FoodAnalysisData
    
    // 编码历史记录项目，包括图片
    func encoded() throws -> Data {
        // 将图像转换为JPEG数据
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "FoodAnalysis", code: 1001, userInfo: [NSLocalizedDescriptionKey: "无法编码图像"])
        }
        
        // 创建包含所有数据的字典
        let encodableData: [String: Any] = [
            "id": id.uuidString,
            "date": date.timeIntervalSince1970,
            "foodName": foodName,
            "imageData": imageData,
            "analysisData": try JSONEncoder().encode(analysisData)
        ]
        
        return try NSKeyedArchiver.archivedData(withRootObject: encodableData, requiringSecureCoding: false)
    }
    
    // 从数据解码历史记录项目
    static func decode(from data: Data) throws -> HistoryItem {
        guard let decodedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: Any] else {
            throw NSError(domain: "FoodAnalysis", code: 1002, userInfo: [NSLocalizedDescriptionKey: "解码失败"])
        }
        
        guard let idString = decodedData["id"] as? String,
              let id = UUID(uuidString: idString),
              let timeInterval = decodedData["date"] as? TimeInterval,
              let foodName = decodedData["foodName"] as? String,
              let imageData = decodedData["imageData"] as? Data,
              let image = UIImage(data: imageData),
              let analysisDataEncoded = decodedData["analysisData"] as? Data else {
            throw NSError(domain: "FoodAnalysis", code: 1003, userInfo: [NSLocalizedDescriptionKey: "数据格式无效"])
        }
        
        let analysisData = try JSONDecoder().decode(FoodAnalysisResponse.FoodAnalysisData.self, from: analysisDataEncoded)
        
        return HistoryItem(
            id: id,
            date: Date(timeIntervalSince1970: timeInterval),
            foodName: foodName,
            image: image,
            analysisData: analysisData
        )
    }
} 