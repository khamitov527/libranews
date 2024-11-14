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
    
    private let durationColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
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
                    if !newsService.selectedSources.isEmpty {
                        durationSection
                    }
                    if !newsService.articles.isEmpty {
                        headlinesSection
                    }
                    if !newsService.selectedSources.isEmpty && newsService.selectedDuration != nil {
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
            HStack {
                sectionHeader("Select News Sources")
                Spacer()
                
                // All Sources Toggle
                Button(action: {
                    if newsService.hasAllSourcesSelected {
                        newsService.clearSelectedSources()
                    } else {
                        newsService.selectAllSourcesForCurrentTopics()
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(newsService.hasAllSourcesSelected ? "Clear All" : "Select All")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: newsService.hasAllSourcesSelected ? "xmark.circle.fill" : "checkmark.circle.fill")
                    }
                    .foregroundColor(.blue)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(newsService.filteredSources) { source in
                        SourceCard(
                            source: source,
                            isSelected: newsService.selectedSources.contains(source)
                        ) {
                            newsService.toggleSourceSelection(source)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Select Duration")
            
            LazyVGrid(columns: durationColumns, spacing: 12) {
                ForEach(DigestDuration.available, id: \.id) { duration in
                    DurationCard(
                        duration: duration,
                        isSelected: newsService.selectedDuration?.minutes == duration.minutes
                    ) {
                        handleDurationSelection(duration)
                    }
                }
            }
        }
        .padding(.horizontal)
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
        Button(action: { handleListenButtonTap() }) {
            HStack {
                if audioService.isGenerating {
                    ProgressView()
                        .tint(.white)
                        .padding(.trailing, 4)
                }
                
                Text(audioService.isGenerating ? "Generating..." : "Listen Now")
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
        .disabled(audioService.isGenerating)
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
            newsService.selectedSources.removeAll()
            newsService.selectedDuration = nil
        }
    }

    private func handleSourceSelection(_ source: NewsSource) {
        newsService.toggleSourceSelection(source)
    }
    
    private func handleDurationSelection(_ duration: DigestDuration) {
        withAnimation {
            if newsService.selectedDuration?.minutes == duration.minutes {
                newsService.selectedDuration = nil
            } else {
                newsService.selectedDuration = duration
            }
            // Refresh articles to match new duration
            if !newsService.selectedSources.isEmpty {
                newsService.fetchNewsForSelectedSources()
            }
        }
    }
    
    private func handleListenButtonTap() {
        audioService.setArticles(newsService.articles, duration: newsService.selectedDuration)
        if !showingPlayer {
            Task {
                await audioService.generateAndPlayDigest(duration: newsService.selectedDuration)
            }
        }
        showingPlayer = true
    }
}
