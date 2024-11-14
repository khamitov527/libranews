import Foundation

struct TimeRange: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let days: Int
    
    static let available: [TimeRange] = [
        TimeRange(title: "Latest News", icon: "clock.arrow.2.circlepath", days: 0),
        TimeRange(title: "Yesterday", icon: "clock.arrow.circlepath", days: 1),
        TimeRange(title: "Past Week", icon: "calendar", days: 7)
    ]
}
