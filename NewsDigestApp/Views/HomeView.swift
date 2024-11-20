import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    @ObservedObject var audioService: AudioService
    @StateObject private var newsService = NewsService()
    @Binding var showingPlayer: Bool
    @State private var selectedTab = 0
    
    private let tabs = ["Breaking News", "Trending"]
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text("libra news")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.appBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 32) {
                            ForEach(0..<tabs.count, id: \.self) { index in
                                TabLabel(
                                    text: tabs[index],
                                    isSelected: selectedTab == index
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = index
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    
                    Divider()
                }
                
                // Content
                TabView(selection: $selectedTab) {
                    // Breaking News Page
                    ScrollView {
                        VStack(spacing: 16) {
                            if newsService.isLoadingBreaking {
                                ProgressView()
                                    .padding()
                            } else if let error = newsService.error {
                                Text(error.localizedDescription)
                                    .foregroundColor(.red)
                                    .padding()
                            } else if newsService.breakingArticles.isEmpty {
                                Text("No breaking news available")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(newsService.breakingArticles, id: \.url) { article in
                                    ArticleCard(article: article)
                                }
                                listenButton
                                    .padding(.top)
                            }
                        }
                        .padding(.vertical)
                    }
                    .tag(0)
                    
                    // Trending Page
                    ScrollView {
                        VStack(spacing: 16) {
                            if newsService.isLoadingTrending {
                                ProgressView()
                                    .padding()
                            } else if let error = newsService.error {
                                Text(error.localizedDescription)
                                    .foregroundColor(.red)
                                    .padding()
                            } else if newsService.trendingArticles.isEmpty {
                                Text("No trending news available")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(newsService.trendingArticles, id: \.url) { article in
                                    ArticleCard(article: article)
                                }
                                listenButton
                                    .padding(.top)
                            }
                        }
                        .padding(.vertical)
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
            .miniPlayerPadding(audioService)
            .onAppear {
                newsService.fetchBreakingNews()
                newsService.fetchTrendingNews()
            }
            .onChange(of: selectedTab) { newTab in
                // Refresh the selected tab's content
                if newTab == 0 {
                    newsService.fetchBreakingNews()
                } else {
                    newsService.fetchTrendingNews()
                }
            }
        }
    }
    
    // MARK: - Views
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
    
    // MARK: - Methods
    private func handleListenButtonTap() {
        Task {
            audioService.reset()
            audioService.voiceServiceType = .openai
            let articles = selectedTab == 0 ? newsService.breakingArticles : newsService.trendingArticles
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
