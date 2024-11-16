import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    @ObservedObject var audioService: AudioService
    @StateObject private var newsService = NewsService()
    @Binding var showingPlayer: Bool
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private let timeRangeColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    topicsSection
                    if !newsService.selectedTopics.isEmpty {
                        sourcesSection
                    }
                    if !newsService.selectedSources.isEmpty {
                        timeRangeSection
                    }
                    if !newsService.selectedSources.isEmpty {
                        listenButton
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("libra news")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.appBlue)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .miniPlayerPadding(audioService)
            .onAppear(perform: loadInitialData)
        }
    }
    
    // MARK: - Views
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
                    .foregroundColor(.appBlue)
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
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.vertical, 8) // Optional for better spacing
                .frame(maxWidth: .infinity) // Ensures the HStack fills the ScrollView
            }
            .edgesIgnoringSafeArea(.horizontal) // Prevents safe area padding on the sides
        }
        .padding(.horizontal, 16) // Aligns with other sections
    }
    
    private var timeRangeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Select Time Period")
            
            LazyVGrid(columns: timeRangeColumns, spacing: 12) {
                ForEach(TimeRange.available, id: \.id) { timeRange in
                    TimeRangeCard(
                        timeRange: timeRange,
                        isSelected: newsService.selectedTimeRange.days == timeRange.days
                    ) {
                        handleTimeRangeSelection(timeRange)
                    }
                }
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
            .background(Color.appBlue)
            .foregroundColor(.white)
            .cornerRadius(28)
            .shadow(color: .appBlue.opacity(0.3), radius: 8, x: 0, y: 4)
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
        }
    }

    private func handleSourceSelection(_ source: NewsSource) {
        newsService.toggleSourceSelection(source)
    }
    
    private func handleTimeRangeSelection(_ timeRange: TimeRange) {
        withAnimation {
            newsService.selectedTimeRange = timeRange
            if !newsService.selectedSources.isEmpty {
                newsService.fetchNewsForSelectedSources()
            }
        }
    }
    
    private func handleListenButtonTap() {
        Task {
            // Reset everything first
            audioService.reset()
            
            // Set new articles and voice type
            audioService.voiceServiceType = .openai
            audioService.setArticles(newsService.articles)
            
            // Show player first, then start playback
            showingPlayer = true
            await audioService.startPlayback()
        }
    }
}

struct ContentPaddingModifier: ViewModifier {
    let audioService: AudioService
    
    func body(content: Content) -> some View {
        content.padding(.bottom, audioService.audioPlayer != nil ? 50 : 0)
    }
}

extension View {
    func miniPlayerPadding(_ audioService: AudioService) -> some View {
        self.padding(.bottom, audioService.currentSegment != nil ? 58 : 0)
    }
}
