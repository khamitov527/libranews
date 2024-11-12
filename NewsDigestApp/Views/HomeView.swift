import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userPreferences: UserPreferences
    @StateObject private var audioService = AudioService()
    @StateObject private var newsService = NewsService()
    @State private var showingPlayer = false
    @State private var selectedSource: NewsSource?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
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
                    
                    // Source Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Popular Sources")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(newsService.availableSources) { source in
                                    SourceCard(
                                        source: source,
                                        isSelected: source == selectedSource
                                    ) {
                                        selectedSource = source
                                        newsService.fetchNews(sourceId: source.id)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Latest Headlines
                    if !newsService.articles.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Latest Headlines")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(newsService.articles.prefix(4)) { article in
                                    HeadlineCard(article: article)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Generate Button
                    if selectedSource != nil {
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

struct SourceCard: View {
    let source: NewsSource
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Source Icon (first letter in a circle)
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.secondary.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Text(source.name.prefix(1))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(source.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(source.category.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

struct HeadlineCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Text(article.source.name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
