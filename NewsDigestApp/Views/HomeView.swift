import SwiftUI
import FirebaseAuth

struct HomeView: View {
    // MARK: - Properties
    @ObservedObject var audioService: AudioService
    @StateObject private var newsService = NewsService()
    @StateObject private var preferencesService = UserPreferencesService()
    @Binding var showingPlayer: Bool
    @State private var selectedTab = 0
    
    // Compute tabs based on default tabs + user preferences
    private var tabs: [String] {
        let defaultTabs = ["Breaking News", "Trending"]
        let topicTabs = Topic.available
            .filter { preferencesService.preferences.topicIds.contains($0.id) }
            .map { $0.name }
        return defaultTabs + topicTabs
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Navigation Bar with App Name and Tabs
                VStack(spacing: 0) {
                    Text("libra news")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.appBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                    
                    // Tab Bar
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 32) {
                                ForEach(0..<tabs.count, id: \.self) { index in
                                    TabLabel(
                                        text: tabs[index],
                                        isSelected: selectedTab == index
                                    )
                                    .id(index) // Assign ID here
                                    .onTapGesture {
                                        withAnimation {
                                            selectedTab = index
                                            proxy.scrollTo(index, anchor: .center)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        // Use a different parameter name to avoid conflict
                        .onChange(of: selectedTab) { newTab in
                            withAnimation {
                                proxy.scrollTo(newTab, anchor: .center)
                            }
                        }
                    }
                    
                    Divider()
                }
                
                // Content
                TabView(selection: $selectedTab) {
                    // Breaking News Page
                    ArticleListView(
                        articles: newsService.breakingArticles,
                        isLoading: newsService.isLoadingBreaking,
                        error: newsService.error,
                        emptyMessage: "No breaking news available",
                        audioService: audioService,
                        showingPlayer: $showingPlayer
                    )
                    .tag(0)
                    
                    // Trending Page
                    ArticleListView(
                        articles: newsService.trendingArticles,
                        isLoading: newsService.isLoadingTrending,
                        error: newsService.error,
                        emptyMessage: "No trending news available",
                        audioService: audioService,
                        showingPlayer: $showingPlayer
                    )
                    .tag(1)
                    
                    // Topic Pages
                    ForEach(2..<tabs.count, id: \.self) { index in
                        ArticleListView(
                            articles: newsService.topicArticles[tabs[index]] ?? [],
                            isLoading: newsService.isLoadingTopic,
                            error: newsService.error,
                            emptyMessage: "No articles available for \(tabs[index])",
                            audioService: audioService,
                            showingPlayer: $showingPlayer
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
            .miniPlayerPadding(audioService)
            .task {
                // Load user preferences
                if let userId = Auth.auth().currentUser?.uid {
                    try? await preferencesService.loadPreferences(for: userId)
                }
            }
            .onChange(of: selectedTab) { newTab in
                loadArticlesForTab(newTab)
            }
        }
    }
    
    private func loadArticlesForTab(_ tab: Int) {
        if tab == 0 {
            newsService.fetchBreakingNews()
        } else if tab == 1 {
            newsService.fetchTrendingNews()
        } else if tab < tabs.count {
            let topic = tabs[tab]
            newsService.fetchArticlesForTopic(topic)
        }
    }
}

// Article List View to reduce duplication
struct ArticleListView: View {
    let articles: [Article]
    let isLoading: Bool
    let error: Error?
    let emptyMessage: String
    let audioService: AudioService
    @Binding var showingPlayer: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let error = error {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .padding()
                } else if articles.isEmpty {
                    Text(emptyMessage)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(articles, id: \.url) { article in
                        ArticleCard(
                            article: article,
                            audioService: audioService,
                            showingPlayer: $showingPlayer
                        )
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private func handleListenButtonTap() {
        Task {
            audioService.reset()
            audioService.voiceServiceType = .openai
            audioService.setArticles(articles)
            showingPlayer = true
            await audioService.startPlayback()
        }
    }
}

// Custom Tab Label styled like CNN app
struct TabLabel: View {
    let text: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Text(text)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .primary : .secondary)
            
            // Indicator line
            Rectangle()
                .fill(isSelected ? Color.appBlue : Color.clear)
                .frame(height: 2)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

extension View {
    func miniPlayerPadding(_ audioService: AudioService) -> some View {
        self.padding(.bottom, audioService.currentSegment != nil ? 58 : 0)
    }
}
