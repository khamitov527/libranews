import SwiftUI

struct PlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var audioService: AudioService
    @State private var hasStartedPlaying = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Loading State
                if audioService.isGenerating {
                    loadingView
                }
                
                Spacer()
                
                // Current Article
                if let currentSegment = audioService.audioQueue.first(where: { !$0.isPlayed }) {
                    articleInfoView(currentSegment)
                }
                
                // Progress Bar
                progressBar
                
                // Controls
                controlsView
                
                // Queue Status
                queueStatusView
                
                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Audio Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Playback Issue", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
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
            Text("Now Playing")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(segment.article.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
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
            // Rewind
            Button(action: handleRewind) {
                Image(systemName: "gobackward.10")
                    .font(.system(size: 32))
                    .foregroundColor(audioService.isGenerating ? .gray : .primary)
            }
            .disabled(audioService.isGenerating)
            
            // Play/Pause
            Button(action: handlePlayPause) {
                Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(audioService.isGenerating ? .gray : .appBlue)
            }
            .disabled(audioService.isGenerating)
            
            // Forward
            Button(action: handleForward) {
                Image(systemName: "goforward.10")
                    .font(.system(size: 32))
                    .foregroundColor(audioService.isGenerating ? .gray : .primary)
            }
            .disabled(audioService.isGenerating)
        }
        .padding()
    }
    
    private var queueStatusView: some View {
        Text("\(audioService.audioQueue.filter { $0.isPlayed }.count)/\(audioService.audioQueue.count) Articles")
            .font(.caption)
            .foregroundColor(.secondary)
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
    
    private func handleRewind() {
        guard let player = audioService.audioPlayer else { return }
        let newTime = max(0, player.currentTime - 10)
        player.currentTime = newTime
        audioService.progress = newTime / player.duration
    }
    
    private func handleForward() {
        guard let player = audioService.audioPlayer else { return }
        let newTime = min(player.duration, player.currentTime + 10)
        player.currentTime = newTime
        audioService.progress = newTime / player.duration
    }
}
