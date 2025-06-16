import Foundation
import UIKit

class NetworkService {
    private let baseURL = "https://api.food.zigao.wang/api"
    
    // 单例模式
    static let shared = NetworkService()
    
    private init() {}
    
    // 上传食物图片并获取分析结果
    func analyzeFoodImage(_ image: UIImage, completion: @escaping (Result<FoodAnalysisResponse, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NetworkError.invalidImage))
            return
        }
        
        let url = URL(string: "\(baseURL)/analyze-food")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(with: imageData, boundary: boundary, fieldName: "foodImage", fileName: "food.jpg")
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("网络请求错误: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // 打印HTTP响应状态
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP状态码: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("没有返回数据")
                completion(.failure(NetworkError.noData))
                return
            }
            
            // 打印原始JSON数据以帮助调试
            print("收到的API响应: \(String(data: data, encoding: .utf8) ?? "无法读取")")
            
            do {
                let decoder = JSONDecoder()
                
                // 尝试解析JSON响应
                let response = try decoder.decode(FoodAnalysisResponse.self, from: data)
                completion(.success(response))
            } catch {
                print("解码错误: \(error)")
                
                // 尝试检查JSON结构
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("原始JSON结构: \(json)")
                    
                    // 尝试手动创建响应对象
                    if let success = json["success"] as? Bool,
                       let responseData = json["data"] as? [String: Any] {
                        
                        // 从JSON中提取字段
                        let foodName = responseData["foodName"] as? String ?? "未知食物"
                        let carbContent = responseData["carbContent"] as? String ?? "未知"
                        let suitabilityIndex = responseData["suitabilityIndex"] as? String ?? "不确定"
                        let recommendedAmount = responseData["recommendedAmount"] as? String ?? "未知"
                        let nutrients = responseData["nutrients"] as? String ?? "未知"
                        let healthTips = responseData["healthTips"] as? String ?? "未知"
                        
                        // 创建响应数据
                        let analysisData = FoodAnalysisResponse.FoodAnalysisData(
                            foodName: foodName,
                            carbContent: carbContent,
                            suitabilityIndex: suitabilityIndex,
                            recommendedAmount: recommendedAmount,
                            nutrients: nutrients,
                            healthTips: healthTips
                        )
                        
                        let response = FoodAnalysisResponse(
                            success: success,
                            data: analysisData,
                            imageUrl: json["imageUrl"] as? String
                        )
                        
                        completion(.success(response))
                        return
                    }
                }
                
                completion(.failure(NetworkError.decodingFailed))
            }
        }.resume()
    }
    
    // 创建Multipart表单数据
    private func createMultipartBody(with imageData: Data, boundary: String, fieldName: String, fileName: String) -> Data {
        var body = Data()
        
        // 添加图像数据
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // 结束边界
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}

// 网络错误类型
enum NetworkError: Error {
    case invalidImage
    case noData
    case decodingFailed
}

// API响应模型
struct FoodAnalysisResponse: Codable {
    let success: Bool
    let data: FoodAnalysisData
    let imageUrl: String?
    
    struct FoodAnalysisData: Codable {
        let foodName: String
        let carbContent: String
        let suitabilityIndex: String
        let recommendedAmount: String
        let nutrients: String
        let healthTips: String
    }
} 
