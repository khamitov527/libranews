import SwiftUI

// MARK: - PlayerView
struct PlayerView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var audioService: AudioService
    @State private var hasStartedPlaying = false
    @State private var selectedArticleIndex: Int? = nil
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    nowPlayingSection
                    articlesSection
                    Spacer()
                    playerControls
                }
                .padding()
            }
            .navigationTitle("News Digest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { navigationButtons }
            .onAppear(perform: handleOnAppear)
        }
    }
    
    // MARK: - Views
    private var nowPlayingSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Now Playing (\(audioService.displayArticleIndex)/\(audioService.totalArticles))")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(audioService.currentArticleTitle)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .animation(.easeInOut, value: audioService.currentArticleIndex)
            
            // Progress indicators
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
    }
    
    private var articlesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Articles")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(Array(audioService.articles.enumerated()), id: \.element.id) { index, article in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Article \(index + 1)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(article.title)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    if let description = article.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(index == audioService.currentArticleIndex ? Color.blue : Color.clear, lineWidth: 1)
                )
            }
        }
    }
    
    private var playerControls: some View {
        AudioPlayerControls(audioService: audioService)
            .padding(.bottom)
    }
    
    private var navigationButtons: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Done") {
                audioService.pauseDigest()
                dismiss()
            }
        }
    }
    
    // MARK: - Methods
    private func handleOnAppear() {
        if !hasStartedPlaying {
            audioService.startNewPlayback()
            hasStartedPlaying = true
        }
    }
    
    private func handleArticleTap(_ index: Int) {
        withAnimation {
            if selectedArticleIndex == index {
                selectedArticleIndex = nil
            } else {
                selectedArticleIndex = index
            }
        }
    }
}
