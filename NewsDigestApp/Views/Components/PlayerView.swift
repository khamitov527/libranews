import SwiftUI
import SafariServices

struct PlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var audioService: AudioService
    @State private var hasStartedPlaying = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingURLConfirmation = false
    @State private var selectedURL: URL? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if audioService.isGenerating {
                    loadingView
                }
                
                Spacer()
                
                if let currentSegment = audioService.currentSegment {
                    articleInfoView(currentSegment)
                }
                
                progressBar
                controlsView
                
                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Audio Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            .alert("Playback Issue", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingURLConfirmation) {
                if let url = selectedURL {
                    SafariView(url: url)
                }
            }
            .onAppear(perform: handleOnAppear)
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        Text("Preparing your news digest...")
            .foregroundColor(.secondary)
            .font(.subheadline)
    }
    
    private func articleInfoView(_ segment: ArticleAudioSegment) -> some View {
        VStack(spacing: 8) {
            // Article image
            if let imageUrlString = segment.article.urlToImage,
               let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                    case .failure:
                        Color.gray.opacity(0.1)
                            .frame(height: 200)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.horizontal)
            }
            
            // Article title (clickable if URL exists)
            if let urlString = segment.article.url, let url = URL(string: urlString) {
                Button(action: {
                    selectedURL = url
                    showingURLConfirmation = true
                }) {
                    HStack {
                        Text(segment.article.title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appBlue)
                        Image(systemName: "link")
                            .foregroundColor(.appBlue)
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(ArticleTitleButtonStyle())
            } else {
                Text(segment.article.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Author and source info
            HStack(spacing: 4) {
                if let author = segment.article.author {
                    Text(author)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                
                if segment.article.author != nil && segment.article.source.name != "" {
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                
                if segment.article.source.name != "" {
                    Text(segment.article.source.name)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(Color.appBlue)
                    .frame(width: geometry.size.width * audioService.progress, height: 4)
            }
        }
        .frame(height: 4)
        .padding(.horizontal)
    }
    
    private var controlsView: some View {
        HStack(spacing: 40) {
            // Previous
            Button(action: handlePrevious) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 32))
                    .foregroundColor(canGoToPrevious ? .primary : .gray)
            }
            .disabled(!canGoToPrevious)
            
            // Play/Pause
            Button(action: handlePlayPause) {
                Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(audioService.isGenerating ? .gray : .appBlue)
            }
            .disabled(audioService.isGenerating)
            
            // Next
            Button(action: handleNext) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 32))
                    .foregroundColor(canGoToNext ? .primary : .gray)
            }
            .disabled(!canGoToNext)
        }
        .padding()
    }
    
    // MARK: - Actions
    private func handleOnAppear() {
        hasStartedPlaying = true
    }
    
    private func handlePlayPause() {
        if audioService.isPlaying {
            audioService.pauseDigest()
        } else if audioService.audioPlayer != nil {
            audioService.resumeDigest()
        } else {
            Task {
                await audioService.startPlayback()
            }
        }
    }
    
    // Add computed properties for button states
    private var canGoToPrevious: Bool {
        !audioService.audioQueue.isEmpty && audioService.currentSegmentIndex > 0
    }
    
    private var canGoToNext: Bool {
        !audioService.audioQueue.isEmpty &&
        audioService.currentSegmentIndex < audioService.audioQueue.count - 1
    }
    
    // Add new action handlers
    private func handlePrevious() {
        guard canGoToPrevious else { return }
        audioService.playPreviousSegment()
    }
    
    private func handleNext() {
        guard canGoToNext else { return }
        audioService.playNextSegment()
    }
}

struct ArticleTitleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}
