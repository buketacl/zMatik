import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ZikirSession.timestamp, order: .forward) private var sessions: [ZikirSession]
    
    @State private var selectedTimeframe: Timeframe = .daily
    
    enum Timeframe: String, CaseIterable, Identifiable {
        case daily = "Günlük"
        case weekly = "Haftalık"
        case monthly = "Aylık"
        case yearly = "Yıllık"
        var id: String { rawValue }
    }
    
    struct ChartData: Identifiable {
        let id = UUID()
        let period: String
        let totalCount: Int
    }
    
    var aggregatedData: [ChartData] {
        let calendar = Calendar.current
        var dataDict: [String: Int] = [:]
        
        let formatter = DateFormatter()
        
        for session in sessions {
            let key: String
            switch selectedTimeframe {
            case .daily:
                formatter.dateFormat = "dd MMM"
                key = formatter.string(from: session.timestamp)
            case .weekly:
                let weekYear = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: session.timestamp)
                key = "Hafta \(weekYear.weekOfYear ?? 0)"
            case .monthly:
                formatter.dateFormat = "MMM yyyy"
                key = formatter.string(from: session.timestamp)
            case .yearly:
                formatter.dateFormat = "yyyy"
                key = formatter.string(from: session.timestamp)
            }
            
            dataDict[key, default: 0] += session.count
        }
        
        return dataDict.map { ChartData(period: $0.key, totalCount: $0.value) }
            .sorted { $0.period < $1.period } // simple string sort for display
    }
    
    var averageCount: Int {
        let data = aggregatedData
        guard !data.isEmpty else { return 0 }
        let total = data.reduce(0) { $0 + $1.totalCount }
        return total / data.count
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Zaman Dilimi", selection: $selectedTimeframe) {
                    ForEach(Timeframe.allCases) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if aggregatedData.isEmpty {
                    Spacer()
                    Text("Henüz veri yok")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    VStack(alignment: .leading) {
                        Text("Ortalama: \(averageCount)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart(aggregatedData) { data in
                            BarMark(
                                x: .value("Zaman", data.period),
                                y: .value("Zikir Sayısı", data.totalCount)
                            )
                            .cornerRadius(4)
                            .foregroundStyle(Color.accentColor.gradient)
                        }
                        .frame(height: 300)
                        .padding()
                    }
                    Spacer()
                }
            }
            .navigationTitle("İstatistikler")
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: ZikirSession.self, inMemory: true)
}
