import SwiftUI

struct MainTabView: View {
    @StateObject private var audioService = AudioService()
    @State private var showingPlayer = false
    @State private var selectedTab = 0
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        
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
            
            // Mini player overlay
            if let _ = audioService.currentSegment {
                VStack(spacing: 0) {
                    MiniPlayerView(audioService: audioService, showingPlayer: $showingPlayer)
                        .background(Color(.systemBackground))
                        .transition(.move(edge: .bottom))
                    
                    // Added to ensure MiniPlayer appears above TabBar
                    Spacer()
                        .frame(height: 49) // TabBar height
                }
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
