import SwiftUI

struct AudioPlayerControls: View {
    @ObservedObject var audioService: AudioService
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress bar
            ProgressView(value: audioService.progress)
                .tint(.blue)
            
            // Time labels
            HStack {
                Text(formatTime(audioService.progress * 300)) // 5 minutes = 300 seconds
                Spacer()
                Text("5:00")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            // Play/Pause button
            Button(action: handlePlayPause) {
                Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
    
    private func handlePlayPause() {
        if audioService.isPlaying {
            audioService.pauseDigest()
        } else if audioService.progress > 0 {
            audioService.resumeDigest()
        } else {
            audioService.playDigest()
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
