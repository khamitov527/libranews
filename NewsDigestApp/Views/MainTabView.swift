import SwiftUI

struct MainTabView: View {
    @StateObject private var audioService = AudioService()
    @State private var showingPlayer = false
    @State private var selectedTab = 0
    
    init() {
        // Make UITabBar translucent
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
        
        // Keep the same colors but with transparency
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        
        // Apply to both standard and scrolled appearances
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationView {
                    HomeView(audioService: audioService, showingPlayer: $showingPlayer)
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(1)
            }
            
            // Mini player overlay at bottom
            VStack(spacing: 0) {
                if audioService.audioPlayer != nil {
                    MiniPlayerView(audioService: audioService, showingPlayer: $showingPlayer)
                        .transition(.move(edge: .bottom))
                        .background(
                            // Add blur effect to mini player
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .edgesIgnoringSafeArea(.all)
                        )
                }
                
                // Invisible spacer matching tab bar height
                Color.clear
                    .frame(height: 49) // Standard tab bar height
            }
        }
        .sheet(isPresented: $showingPlayer) {
            PlayerView(audioService: audioService)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("Profile Content")
                .navigationTitle("Profile")
        }
    }
}
