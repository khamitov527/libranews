import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userPreferences: UserPreferences
    @StateObject private var audioService = AudioService()
    @StateObject private var newsService = NewsService()
    @State private var showingPlayer = false
    @State private var selectedSource: NewsSource?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Source Selection
                    SourceSelectionView(newsService: newsService, selectedSource: $selectedSource)
                    
                    // Preview of fetched headlines
                    if !newsService.articles.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Latest Headlines")
                                .font(.headline)
                            
                            ForEach(newsService.articles.prefix(3)) { article in
                                Text("• \(article.title)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        if !showingPlayer {
                            // Only update articles if player isn't showing
                            audioService.setArticles(newsService.articles)
                        }
                        showingPlayer = true
                    }) {
                        Text("Generate Digest")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedSource != nil ? Color.blue : Color.secondary)
                            .cornerRadius(12)
                    }
                    .disabled(selectedSource == nil)
                }
                .padding()
            }
            .navigationTitle("News Digest")
            .sheet(isPresented: $showingPlayer) {
                PlayerView(audioService: audioService)
            }
            .onAppear {
                if newsService.availableSources.isEmpty {
                    newsService.fetchSources()
                }
            }
        }
    }
}
