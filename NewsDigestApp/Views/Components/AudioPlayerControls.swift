import SwiftUI

struct AudioPlayerControls: View {
    @ObservedObject var audioService: AudioService
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: audioService.progress)
                .tint(.blue)
            
            HStack {
                Text("0:00")
                Spacer()
                Text("5:00")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Button(action: {
                if audioService.isPlaying {
                    audioService.pauseDigest()
                } else if audioService.progress > 0 {
                    audioService.resumeDigest()
                } else {
                    audioService.playDigest()
                }
            }) {
                Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}
