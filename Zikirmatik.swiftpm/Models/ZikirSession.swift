import Foundation
import SwiftData

@Model
final class ZikirSession {
    var timestamp: Date
    var count: Int
    
    init(timestamp: Date = Date(), count: Int = 0) {
        self.timestamp = timestamp
        self.count = count
    }
}
