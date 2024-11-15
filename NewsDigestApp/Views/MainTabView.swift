import SwiftUI

struct MainTabView: View {
    @StateObject private var audioService = AudioService()
    @State private var showingPlayer = false
    @State private var selectedTab = 0
    
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
            
            // Mini player
            if audioService.audioPlayer != nil {
                MiniPlayerView(audioService: audioService, showingPlayer: $showingPlayer)
                    .transition(.move(edge: .bottom))
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
