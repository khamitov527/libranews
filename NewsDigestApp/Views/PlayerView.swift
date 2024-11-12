import SwiftUI

struct PlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var audioService: AudioService
    @State private var hasStartedPlaying = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Current Article Display
                VStack(spacing: 16) {
                    Image(systemName: "waveform")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Now Playing")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(audioService.currentArticleTitle)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Debug Info (collapsed by default)
                DisclosureGroup("Debug Info") {
                    ScrollView {
                        Text(audioService.debugMessage)
                            .font(.system(.footnote, design: .monospaced))
                            .padding()
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(8)
                    }
                    .frame(height: 200)
                }
                .padding()
                
                Spacer()
                
                // Audio Controls
                AudioPlayerControls(audioService: audioService)
                    .padding(.bottom)
            }
            .navigationTitle("News Digest")
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
