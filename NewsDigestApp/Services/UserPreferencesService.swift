import Foundation
import FirebaseFirestore

@MainActor
class UserPreferencesService: ObservableObject {
    @Published private(set) var preferences: UserPreferences
    private let db = Firestore.firestore()
    
    init() {
        self.preferences = UserPreferences()
    }
    
    func loadPreferences(for userId: String) async throws {
        let document = try await db.collection("userPreferences").document(userId).getDocument()
        
        if let data = try? document.data(as: UserPreferences.self) {
            self.preferences = data
        } else {
            // Create new preferences if none exist
            self.preferences = UserPreferences(userId: userId)
            try await savePreferences()
        }
    }
    
    func savePreferences() async throws {
        guard !preferences.userId.isEmpty else { return }
        
        preferences.lastUpdated = Date()
        try await db.collection("userPreferences").document(preferences.userId).setData(from: preferences)
    }
    
    func toggleTopic(_ topicId: String) async throws {
        if preferences.topicIds.contains(topicId) {
            preferences.topicIds.remove(topicId)
        } else {
            preferences.topicIds.insert(topicId)
        }
        try await savePreferences()
    }
    
    func setUserId(_ userId: String) {
        preferences.userId = userId
    }
}
