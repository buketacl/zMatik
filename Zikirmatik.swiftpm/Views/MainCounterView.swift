import SwiftUI
import SwiftData

struct MainCounterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ZikirSession.timestamp, order: .reverse) private var sessions: [ZikirSession]
    
    @State private var currentCount: Int = 0
    @State private var currentSession: ZikirSession?
    
    // Calculates total count for today
    var todayTotal: Int {
        let calendar = Calendar.current
        return sessions
            .filter { calendar.isDateInToday($0.timestamp) }
            .reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack {
                // Top bar with Daily Total
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Bugün")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(todayTotal)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding()
                }
                
                Spacer()
                
                // Current Session Counter
                Text("\(currentCount)")
                    .font(.system(size: 100, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal)
                
                Spacer()
                
                // Tap Area Info
                Text("Ekrana Dokun")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 50)
            }
        }
        // Entire screen acts as a button
        .contentShape(Rectangle())
        .onTapGesture {
            incrementCounter()
        }
        .onAppear {
            startNewSession()
        }
    }
    
    private func incrementCounter() {
        // Haptic Feedback
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        currentCount += 1
        
        // Update current session in SwiftData
        if let session = currentSession {
            session.count = currentCount
            try? modelContext.save()
        } else {
            startNewSession()
        }
    }
    
    private func startNewSession() {
        currentCount = 0
        let newSession = ZikirSession()
        modelContext.insert(newSession)
        currentSession = newSession
        try? modelContext.save()
    }
}

#Preview {
    MainCounterView()
        .modelContainer(for: ZikirSession.self, inMemory: true)
}
