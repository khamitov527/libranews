import Foundation

class UserPreferences: ObservableObject {
    @Published var selectedTopics: Set<UUID> = [] {
        didSet {
            savePreferences()
        }
    }
    
    @Published var selectedSources: Set<UUID> = [] {
        didSet {
            savePreferences()
        }
    }
    
    private let preferencesKey = "userPreferences"
    
    init() {
        loadPreferences()
    }
    
    private func savePreferences() {
        let preferences = PreferencesData(
            selectedTopicIds: Array(selectedTopics),
            selectedSourceIds: Array(selectedSources)
        )
        
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }
    
    private func loadPreferences() {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey),
              let preferences = try? JSONDecoder().decode(PreferencesData.self, from: data)
        else { return }
        
        selectedTopics = Set(preferences.selectedTopicIds)
        selectedSources = Set(preferences.selectedSourceIds)
    }
}

private struct PreferencesData: Codable {
    let selectedTopicIds: [UUID]
    let selectedSourceIds: [UUID]
}
