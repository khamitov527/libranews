import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var audioService: AudioService
    @Binding var showingPlayer: Bool
    
    var body: some View {
        Button(action: { showingPlayer = true }) {
            HStack {
                // Waveform icon and title
                HStack(spacing: 12) {
                    Image(systemName: "waveform")
                        .font(.title3)
                        .foregroundColor(.blue)
                    
                    Text("News Digest")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Play/Pause button
                Button(action: handlePlayPause) {
                    Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .disabled(audioService.isGenerating)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(.systemGray4))
                    .opacity(0.5),
                alignment: .top
            )
        }
    }
    
    private func handlePlayPause() {
        if audioService.isPlaying {
            audioService.pauseDigest()
        } else if let player = audioService.audioPlayer {
            // Resume from last position
            audioService.resumeDigest()
        }
    }
}
