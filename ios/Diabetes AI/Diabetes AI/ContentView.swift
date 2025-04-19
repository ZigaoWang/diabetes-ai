//
//  ContentView.swift
//  Diabetes AI
//
//  Created by Zigao Wang on 4/19/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FoodAnalysisViewModel()
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var showingHistory = false
    @State private var activeTab = "home"
    
    var body: some View {
        TabView(selection: $activeTab) {
            // 主页
            VStack {
                Spacer()
                
                // 应用标题
                Text("糖尿病食物助手")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // 应用简介
                Text("拍照识别食物，一键获取糖尿病饮食建议")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                
                if let image = viewModel.selectedImage {
                    // 显示选定的图片
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .cornerRadius(15)
                        .padding()
                    
                    // 分析按钮
                    Button(action: {
                        guard let image = viewModel.selectedImage else { return }
                        viewModel.analyzeImage(image)
                    }) {
                        Text("分析食物")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    .disabled(viewModel.isAnalyzing)
                    
                    // 重新选择按钮
                    Button(action: {
                        viewModel.clearAnalysis()
                    }) {
                        Text("重新选择")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                } else {
                    // 图片选择选项
                    VStack(spacing: 20) {
                        // 相机按钮
                        Button(action: {
                            showingCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                Text("拍照识别")
                                    .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                        
                        // 相册按钮
                        Button(action: {
                            showingPhotoLibrary = true
                        }) {
                            HStack {
                                Image(systemName: "photo.fill")
                                    .font(.title)
                                Text("从相册选择")
                                    .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                    }
                    
                    // 示例图片展示
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.top, 40)
                }
                
                Spacer()
            }
            .padding()
            .sheet(isPresented: $showingCamera) {
                CameraView(selectedImage: $viewModel.selectedImage)
            }
            .sheet(isPresented: $showingPhotoLibrary) {
                PhotoPickerView(selectedImage: $viewModel.selectedImage)
            }
            .sheet(item: $viewModel.analysisResult) { result in
                if let image = viewModel.selectedImage {
                    ResultView(result: result, image: image, viewModel: viewModel)
                }
            }
            .alert("错误", isPresented: $viewModel.showError, actions: {
                Button("确定", role: .cancel) { }
            }, message: {
                Text(viewModel.errorMessage ?? "未知错误")
            })
            .tabItem {
                Label("首页", systemImage: "house.fill")
            }
            .tag("home")
            
            // 历史记录
            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label("历史", systemImage: "clock.fill")
                }
                .tag("history")
            
            // 关于页面
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.red)
                    .padding(.top, 40)
                
                Text("糖尿病食物助手")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("版本 1.0")
                    .foregroundColor(.gray)
                
                Text("帮助糖尿病患者更科学地管理饮食，通过AI识别食物并提供专业的饮食建议。")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Text("© 2025 糖尿病科技无障AI")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
            .padding()
            .tabItem {
                Label("关于", systemImage: "info.circle.fill")
            }
            .tag("about")
        }
    }
}

// 为了在预览中能使用 analysisResult
extension FoodAnalysisResponse.FoodAnalysisData: Identifiable {
    public var id: String { foodName }
}

#Preview {
    ContentView()
}
