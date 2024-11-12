import SwiftUI

struct PlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var audioService: AudioService
    @State private var hasStartedPlaying = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                ScrollView {
                    Text(audioService.debugMessage)
                        .font(.system(.footnote, design: .monospaced))
                        .padding()
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                }
                .frame(height: 200)
                
                Image(systemName: "waveform")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                
                Text("Your 5-Minute News Digest")
                    .font(.title2)
                    .fontWeight(.bold)
                
                AudioPlayerControls(audioService: audioService)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Now Playing")
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
