import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: FoodAnalysisViewModel
    @State private var selectedItem: HistoryItem?
    @State private var showingDetail = false
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.historyItems.isEmpty {
                    Text("暂无历史记录")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.historyItems) { item in
                        HistoryItemRow(item: item)
                            .onTapGesture {
                                selectedItem = item
                                showingDetail = true
                            }
                    }
                }
            }
            .navigationTitle("历史记录")
            .toolbar {
                if !viewModel.historyItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingClearAlert = true
                        }) {
                            Text("清空")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingDetail, onDismiss: {
                selectedItem = nil
            }) {
                if let item = selectedItem {
                    ResultView(
                        result: item.analysisData,
                        image: item.image,
                        viewModel: viewModel
                    )
                }
            }
            .alert("确认删除", isPresented: $showingClearAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    viewModel.clearHistory()
                }
            } message: {
                Text("确定要清空所有历史记录吗？此操作无法撤销。")
            }
        }
    }
}

struct HistoryItemRow: View {
    let item: HistoryItem
    
    var body: some View {
        HStack {
            Image(uiImage: item.image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.foodName)
                    .font(.headline)
                
                Text(formattedDate(item.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
} 