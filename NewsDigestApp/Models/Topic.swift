import Foundation

struct Topic: Identifiable, Codable {
    let id = UUID()
    let name: String
    let icon: String // SF Symbol name
    
    static let available: [Topic] = [
        Topic(name: "Finance", icon: "dollarsign.circle"),
        Topic(name: "Technology", icon: "laptopcomputer"),
        Topic(name: "Media", icon: "play.tv"),
        Topic(name: "Sports", icon: "sportscourt"),
        Topic(name: "Science", icon: "flask")
    ]
}
