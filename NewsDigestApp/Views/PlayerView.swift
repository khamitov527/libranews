import SwiftUI

struct PlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var audioService: AudioService
    @State private var hasStartedPlaying = false
    @State private var selectedArticleIndex: Int? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Current Article Display
                    VStack(spacing: 16) {
                        Image(systemName: "waveform")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Now Playing (\(audioService.displayArticleIndex)/\(audioService.articles.count))")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(audioService.currentArticleTitle)
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .animation(.easeInOut, value: audioService.currentArticleIndex)
                        
                        HStack(spacing: 8) {
                            ForEach(0..<audioService.articles.count, id: \.self) { index in
                                Circle()
                                    .fill(index == audioService.currentArticleIndex ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut, value: audioService.currentArticleIndex)
                            }
                        }
                    }
                    .padding(.top)
                    
                    // Articles Debug View
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Articles Detail")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(Array(audioService.articles.enumerated()), id: \.element.id) { index, article in
                            ArticleDebugCard(
                                article: article,
                                index: index, 
                                isExpanded: selectedArticleIndex == index,
                                onTap: {
                                    withAnimation {
                                        if selectedArticleIndex == index {
                                            selectedArticleIndex = nil
                                        } else {
                                            selectedArticleIndex = index
                                        }
                                    }
                                }
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // Audio Controls
                    AudioPlayerControls(audioService: audioService)
                        .padding(.bottom)
                }
                .padding()
            }
            .navigationTitle("News Digest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        audioService.pauseDigest()
                        dismiss()
                    }
                }
            }
            .onAppear {
                if !hasStartedPlaying {
                    audioService.playDigest()
                    hasStartedPlaying = true
                }
            }
        }
    }
}

struct ArticleDebugCard: View {
    let article: Article
    let index: Int
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header (always visible)
            Button(action: onTap) {
                HStack {
                    Text("Article \(index + 1)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(article.title)
                        .font(.body)
                }
                
                // Description
                if let description = article.description {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(description)
                            .font(.body)
                    }
                }
                
                // Content
                if let content = article.content {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(content)
                            .font(.body)
                    }
                }
                
                // Source
                VStack(alignment: .leading, spacing: 8) {
                    Text("Source:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(article.source.name)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
