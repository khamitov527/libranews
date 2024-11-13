import Foundation

struct Topic: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let category: String
    
    static let available: [Topic] = [
        Topic(name: "Business", icon: "dollarsign.circle", category: "business"),
        Topic(name: "Technology", icon: "laptopcomputer", category: "technology"),
        Topic(name: "Entertainment", icon: "play.tv", category: "entertainment"),
        Topic(name: "Sports", icon: "sportscourt", category: "sports"),
        Topic(name: "Science", icon: "flask", category: "science"),
        Topic(name: "Health", icon: "heart", category: "health"),
        Topic(name: "Politics", icon: "building.columns", category: "politics")
    ]
}
