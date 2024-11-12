import Foundation

struct Article: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String?
    let content: String?
    let source: ArticleSource
    
    enum CodingKeys: String, CodingKey {
        case source
        case title
        case description
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.source = try container.decode(ArticleSource.self, forKey: .source)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(source, forKey: .source)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(content, forKey: .content)
    }
}

struct ArticleSource: Codable {
    let name: String
}

struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}
