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
                        .foregroundColor(.appBlue)
                    
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
                        .foregroundColor(.appBlue)
                }
                .disabled(audioService.isGenerating)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(
                Color(.systemBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func handlePlayPause() {
        if audioService.isPlaying {
            audioService.pauseDigest()
        } else if let player = audioService.audioPlayer {
            audioService.resumeDigest()
        }
    }
}
