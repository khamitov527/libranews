import Foundation

struct Article: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String?
    let content: String?
    let source: ArticleSource
    let publishedAt: Date?
    let author: String?
    let url: String?
    let urlToImage: String?
    
    enum CodingKeys: String, CodingKey {
        case source
        case title
        case description
        case content
        case publishedAt
        case author
        case url
        case urlToImage
    }
    
    // uncomment init to test with dummy data
    init(source: ArticleSource, author: String?, title: String, description: String?, url: String?, urlToImage: String?, publishedAt: Date?, content: String?) {
        self.source = source
        self.author = author
        self.title = title
        self.description = description
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.content = content
    }
    //
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.title = try container.decode(String.self, forKey: .title)
//        self.description = try container.decodeIfPresent(String.self, forKey: .description)
//        self.content = try container.decodeIfPresent(String.self, forKey: .content)
//        self.source = try container.decode(ArticleSource.self, forKey: .source)
//        self.author = try container.decodeIfPresent(String.self, forKey: .author)
//        self.url = try container.decodeIfPresent(String.self, forKey: .url)
//        self.urlToImage = try container.decodeIfPresent(String.self, forKey: .urlToImage)
//        
//        // Parse the date string
//        if let dateString = try container.decodeIfPresent(String.self, forKey: .publishedAt) {
//            let dateFormatter = ISO8601DateFormatter()
//            self.publishedAt = dateFormatter.date(from: dateString)
//        } else {
//            self.publishedAt = nil
//        }
//    }
    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(title, forKey: .title)
//        try container.encode(source, forKey: .source)
//        try container.encodeIfPresent(description, forKey: .description)
//        try container.encodeIfPresent(content, forKey: .content)
//        try container.encodeIfPresent(author, forKey: .author)
//        try container.encodeIfPresent(url, forKey: .url)
//        try container.encodeIfPresent(urlToImage, forKey: .urlToImage)
//        if let publishedAt = publishedAt {
//            let dateFormatter = ISO8601DateFormatter()
//            try container.encode(dateFormatter.string(from: publishedAt), forKey: .publishedAt)
//        }
//    }
}

struct ArticleSource: Codable {
    let name: String
}

struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}
