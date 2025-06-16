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
    @State private var activeTab = "home"
    @State private var isLoading = false
    
    var body: some View {
        TabView(selection: $activeTab) {
            // 主页
            ZStack {
                VStack(spacing: 0) {
                    // 应用标题区域
                    VStack(spacing: 8) {
                        Text("食物助手")
                            .font(.system(size: 38, weight: .bold))
                            .padding(.top, 30)
                        
                        Text("拍照识别食物，获取饮食建议")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 5)
                    }
                    
                    if let image = viewModel.selectedImage {
                        // 选中图片后的界面
                        VStack(spacing: 20) {
                            // 图片预览
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 280)
                                    .cornerRadius(24)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .padding(.horizontal, 30)
                                    .accessibilityLabel("已选择的食物图片")
                                
                                // 取消按钮 (更大更易点击)
                                Button(action: {
                                    viewModel.clearAnalysis()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.4)).frame(width: 36, height: 36))
                                        .padding(.top, 15)
                                        .padding(.trailing, 40)
                                }
                                .accessibilityLabel("删除图片")
                            }
                            
                            // 分析按钮 (更大更易读)
                            Button(action: {
                                guard let image = viewModel.selectedImage else { return }
                                isLoading = true
                                viewModel.analyzeImage(image)
                                
                                // 2秒后关闭加载
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isLoading = false
                                }
                            }) {
                                HStack {
                                    if viewModel.isAnalyzing || isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 12)
                                    } else {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 24))
                                            .padding(.trailing, 12)
                                    }
                                    
                                    Text(viewModel.isAnalyzing ? "正在分析..." : "开始分析")
                                        .font(.system(size: 22, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            .disabled(viewModel.isAnalyzing || isLoading)
                            .padding(.horizontal, 30)
                            .padding(.top, 15)
                            .accessibilityHint("点击分析图片中的食物")
                        }
                    } else {
                        // 未选中图片时的界面 - 简化视图
                        VStack(spacing: 40) {
                            // 欢迎图示区域 - 更友好的插图
                            Image(systemName: "camera.viewfinder")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.blue)
                                .padding(30)
                                .background(
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .accessibilityHidden(true)
                            
                            // 大按钮区域 - 更大更醒目
                            VStack(spacing: 25) {
                                // 拍照按钮 - 更大更明显
                                Button(action: {
                                    showingCamera = true
                                }) {
                                    HStack(spacing: 15) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 28))
                                        
                                        Text("拍照")
                                            .font(.system(size: 24, weight: .medium))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 25)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                    .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                                .accessibilityLabel("拍照")
                                .accessibilityHint("打开相机拍摄食物照片")
                                
                                // 相册按钮 - 清晰的视觉区分
                                Button(action: {
                                    showingPhotoLibrary = true
                                }) {
                                    HStack(spacing: 15) {
                                        Image(systemName: "photo.on.rectangle")
                                            .font(.system(size: 28))
                                        
                                        Text("相册选择")
                                            .font(.system(size: 24, weight: .medium))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 25)
                                    .background(Color.white)
                                    .foregroundColor(.blue)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                    .shadow(color: Color.gray.opacity(0.2), radius: 6, x: 0, y: 3)
                                }
                                .accessibilityLabel("从相册选择")
                                .accessibilityHint("从手机相册中选择食物照片")
                            }
                            .padding(.horizontal, 30)
                        }
                        .padding(.top, 30)
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
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
                
                // 加载动画
                if viewModel.isAnalyzing && !isLoading {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 25) {
                            ProgressView()
                                .scaleEffect(2.0)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            
                            Text("正在分析食物...")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(35)
                        .background(Color(.systemBackground).opacity(0.9))
                        .cornerRadius(20)
                        .shadow(radius: 15)
                    }
                    .accessibilityLabel("正在分析")
                }
            }
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
            
            // 关于页面 - 更友好更易读
            ScrollView {
                VStack(spacing: 35) {
                    // Logo和标题
                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.15))
                                .frame(width: 150, height: 150)
                            
                            Image(systemName: "heart.text.square.fill")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.red)
                        }
                        .padding(.top, 50)
                        
                        Text("食物分析助手")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("版本 1.0")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                    }
                    
                    // 功能介绍 - 更大更易读
                    VStack(alignment: .leading, spacing: 20) {
                        Text("主要功能")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.horizontal)
                            .padding(.top, 5)
                        
                        FeatureRow(icon: "camera.fill", color: .blue, title: "拍照识别", description: "自动识别拍摄的食物")
                        
                        FeatureRow(icon: "fork.knife", color: .green, title: "饮食建议", description: "提供适合的饮食建议")
                        
                        FeatureRow(icon: "speaker.wave.2.fill", color: .orange, title: "语音播报", description: "支持语音播报分析结果")
                        
                        FeatureRow(icon: "clock.fill", color: .purple, title: "历史记录", description: "保存历史分析结果")
                    }
                    .padding(.vertical, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // 底部信息
                    VStack(spacing: 12) {
                        Text("食物分析助手")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("© 2025 Zigao Wang 王子高")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 35)
                }
            }
            .tabItem {
                Label("关于", systemImage: "info.circle.fill")
            }
            .tag("about")
        }
        .onAppear {
            // 增加标签栏字体大小
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)], for: .normal)
        }
    }
}

// 功能介绍行 - 更易读
struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                
                Text(description)
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}

// 为了在预览中能使用 analysisResult
extension FoodAnalysisResponse.FoodAnalysisData: Identifiable {
    public var id: String { foodName }
}

#Preview {
    ContentView()
}
