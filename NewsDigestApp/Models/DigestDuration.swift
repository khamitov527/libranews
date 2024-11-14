import Foundation

struct DigestDuration: Identifiable, Hashable {
    let id = UUID()
    let minutes: Int
    let articleRange: ClosedRange<Int>
    let timePerArticle: ClosedRange<Int>
    let icon: String
    
    static let available: [DigestDuration] = [
        DigestDuration(
            minutes: 2,
            articleRange: 2...3,
            timePerArticle: 30...40,
            icon: "timer"
        ),
        DigestDuration(
            minutes: 5,
            articleRange: 4...6,
            timePerArticle: 50...75,
            icon: "clock"
        ),
        DigestDuration(
            minutes: 10,
            articleRange: 7...10,
            timePerArticle: 60...90,
            icon: "hourglass"
        )
    ]
}
