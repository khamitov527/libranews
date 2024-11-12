import Foundation

struct Article: Identifiable, Codable {
    var id = UUID()
    let title: String
    let source: ArticleSource
    
    enum CodingKeys: String, CodingKey {
        case source
        case title
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.source = try container.decode(ArticleSource.self, forKey: .source)
        self.id = UUID()
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
