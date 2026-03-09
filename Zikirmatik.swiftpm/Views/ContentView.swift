import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            MainCounterView()
                .tabItem {
                    Label("Zikirmatik", systemImage: "hand.tap.fill")
                }
            
            StatisticsView()
                .tabItem {
                    Label("İstatistikler", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ZikirSession.self, inMemory: true)
}
