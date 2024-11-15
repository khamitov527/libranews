import SwiftUI

@main
struct NewsDigestApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .tint(Color.appBlue)
        }
    }
}
