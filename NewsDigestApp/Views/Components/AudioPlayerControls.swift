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
                Text(formatTime(currentTime))
                Spacer()
                Text(formatTime(totalTime))
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
    
    private var currentTime: Double {
        let durationInMinutes = 2.0
        return audioService.progress * (durationInMinutes * 60)
    }

    private var totalTime: Double {
        Double(2) * 60
    }
    
    private func handlePlayPause() {
        if audioService.isPlaying {
            audioService.pauseDigest()
        } else if audioService.progress > 0 {
            audioService.resumeDigest()
        } else {
            audioService.startNewPlayback()
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
