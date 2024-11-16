import Foundation

struct NewsSource: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let language: String
    let country: String
    let category: String
    let url: URL? 
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: NewsSource, rhs: NewsSource) -> Bool {
        lhs.id == rhs.id
    }
}

struct SourcesResponse: Codable {
    let status: String
    let sources: [NewsSource]
}
