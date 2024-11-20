import Foundation

struct Topic: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let icon: String
    let category: String
    
    // Your existing static available topics
    static let available: [Topic] = [
        Topic(id: "world", name: "World", icon: "globe", category: "news"),
        Topic(id: "business", name: "Business", icon: "briefcase", category: "news"),
        Topic(id: "technology", name: "Technology", icon: "laptopcomputer", category: "news"),
        Topic(id: "science", name: "Science", icon: "atom", category: "news"),
        Topic(id: "health", name: "Health", icon: "heart", category: "news"),
        Topic(id: "sports", name: "Sports", icon: "sportscourt", category: "news"),
        Topic(id: "entertainment", name: "Entertainment", icon: "film", category: "news"),
        Topic(id: "politics", name: "Politics", icon: "building.columns", category: "news"),
        Topic(id: "environment", name: "Environment", icon: "leaf", category: "news")
    ]
}
