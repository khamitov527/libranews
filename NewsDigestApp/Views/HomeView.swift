import SwiftUI

struct HomeView: View {
    @StateObject private var audioService = AudioService()
    @StateObject private var newsService = NewsService()
    @State private var showingPlayer = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Welcome Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Daily")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("News Digest")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Topics Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Your Interests")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Topic.available) { topic in
                                TopicCard(
                                    topic: topic,
                                    isSelected: newsService.selectedTopics.contains(topic)
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if newsService.selectedTopics.contains(topic) {
                                            newsService.selectedTopics.remove(topic)
                                        } else {
                                            newsService.selectedTopics.insert(topic)
                                        }
                                        newsService.selectedSource = nil
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sources Selection
                    if !newsService.selectedTopics.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select News Source")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(newsService.filteredSources) { source in
                                        SourceCard(
                                            source: source,
                                            isSelected: source == newsService.selectedSource
                                        ) {
                                            newsService.selectedSource = source
                                            newsService.fetchNews(sourceId: source.id)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Headlines Preview
                    if !newsService.articles.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Latest Headlines")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            ForEach(newsService.articles.prefix(3)) { article in
                                HeadlineCard(article: article)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Listen Now Button
                    if newsService.selectedSource != nil {
                        Button(action: {
                            if !showingPlayer {
                                audioService.setArticles(newsService.articles)
                            }
                            showingPlayer = true
                        }) {
                            HStack {
                                Text("Listen Now")
                                    .fontWeight(.semibold)
                                Image(systemName: "headphones")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(28)
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
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
