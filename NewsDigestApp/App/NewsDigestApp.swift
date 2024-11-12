import SwiftUI

@main
struct NewsDigestApp: App {
    @StateObject private var userPreferences = UserPreferences()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(userPreferences)
        }
    }
}
