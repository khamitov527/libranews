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
                // Playback controls
                HStack(spacing: 40) {
                    // Rewind button
                    Button(action: handleRewind) {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 32))
                            .foregroundColor(audioService.isGenerating ? .gray : .primary)
                    }
                    .disabled(audioService.isGenerating)
                    
                    // Play/Pause button
                    Button(action: handlePlayPause) {
                        Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(audioService.isGenerating ? .gray : .appBlue)
                    }
                    .disabled(audioService.isGenerating)
                    
                    // Forward button
                    Button(action: handleForward) {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 32))
                            .foregroundColor(audioService.isGenerating ? .gray : .primary)
                    }
                    .disabled(audioService.isGenerating)
                }
                .padding()
                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Audio Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        // Don't stop playback on dismiss
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
                if !hasStartedPlaying && audioService.audioPlayer == nil {
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
