import Foundation

struct UserPreferences: Codable {
    var topicIds: Set<String>
    var userId: String
    var lastUpdated: Date
    
    init(topicIds: Set<String> = [], userId: String = "", lastUpdated: Date = Date()) {
        self.topicIds = topicIds
        self.userId = userId
        self.lastUpdated = lastUpdated
    }
}
