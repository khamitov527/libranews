import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    @StateObject private var audioService = AudioService()
    @StateObject private var newsService = NewsService()
    @State private var showingPlayer = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    welcomeSection
                    topicsSection
                    if !newsService.selectedTopics.isEmpty {
                        sourcesSection
                    }
                    if !newsService.articles.isEmpty {
                        headlinesSection
                    }
                    if newsService.selectedSource != nil {
                        listenButton
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPlayer) {
                PlayerView(audioService: audioService)
            }
            .onAppear(perform: loadInitialData)
        }
    }
    
    // MARK: - Views
    private var welcomeSection: some View {
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
    }
    
    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Select Your Interests")
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Topic.available) { topic in
                    TopicCard(
                        topic: topic,
                        isSelected: newsService.selectedTopics.contains(topic)
                    ) {
                        handleTopicSelection(topic)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Select News Source")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(newsService.filteredSources) { source in
                        SourceCard(
                            source: source,
                            isSelected: source == newsService.selectedSource
                        ) {
                            handleSourceSelection(source)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var headlinesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Latest Headlines")
            
            ForEach(newsService.articles.prefix(3)) { article in
                HeadlineCard(article: article)
            }
        }
        .padding(.horizontal)
    }
    
    private var listenButton: some View {
        Button(action: handleListenButtonTap) {
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
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.secondary)
    }
    
    // MARK: - Methods
    private func loadInitialData() {
        if newsService.availableSources.isEmpty {
            newsService.fetchSources()
        }
    }
    
    private func handleTopicSelection(_ topic: Topic) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if newsService.selectedTopics.contains(topic) {
                newsService.selectedTopics.remove(topic)
            } else {
                newsService.selectedTopics.insert(topic)
            }
            newsService.selectedSource = nil
        }
    }
    
    private func handleSourceSelection(_ source: NewsSource) {
        newsService.selectedSource = source
        newsService.fetchNews(sourceId: source.id)
    }
    
    private func handleListenButtonTap() {
        audioService.setArticles(newsService.articles)
        if !showingPlayer {
            audioService.startNewPlayback()
        }
        showingPlayer = true
    }
}
