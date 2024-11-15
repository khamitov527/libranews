import SwiftUI

struct PlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var audioService: AudioService
    @State private var hasStartedPlaying = false
    @State private var showingVoiceError = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                // Single play/pause button
                Button(action: handlePlayPause) {
                    Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(audioService.isGenerating ? .gray : .blue)
                }
                .disabled(audioService.isGenerating)
                .padding()
                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Audio Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        audioService.pauseDigest()
                        dismiss()
                    }
                }
            }
            .alert("Playback Issue", isPresented: $showingVoiceError) {
                Button("OK") { }
            } message: {
                Text("There was an issue with the text-to-speech system. Try closing and reopening the app, or test on a physical device.")
            }
            .onChange(of: audioService.debugMessage) { newValue in
                if newValue.contains("Unable to list voice folder") {
                    showingVoiceError = true
                }
            }
            .onAppear {
                if !hasStartedPlaying {
                    Task {
                        await audioService.generateAndPlayDigest()
                    }
                    hasStartedPlaying = true
                }
            }
        }
    }
    
    private func handlePlayPause() {
        if audioService.isPlaying {
            audioService.pauseDigest()
        } else {
            if audioService.audioPlayer != nil {
                if audioService.progress > 0 {
                    audioService.resumeDigest()
                } else {
                    audioService.startNewPlayback()
                }
            } else {
                Task {
                    await audioService.generateAndPlayDigest()
                }
            }
        }
    }
}
