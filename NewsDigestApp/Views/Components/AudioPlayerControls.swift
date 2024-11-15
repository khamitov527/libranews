import SwiftUI

struct AudioPlayerControls: View {
    @ObservedObject var audioService: AudioService
    
    var body: some View {
        Button(action: handlePlayPause) {
            Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)
        }
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
}
