import SwiftUI

struct PlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var audioService: AudioService
    @State private var hasStartedPlaying = false
    @State private var showingVoiceError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress indicator for loading state
                if audioService.isGenerating {
                    Text("Preparing your news digest...")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                
                Spacer()
                
                // Article Info
                if let currentSegment = audioService.audioQueue.first(where: { !$0.isPlayed }) {
                    VStack(spacing: 8) {
                        Text("Now Playing")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(currentSegment.article.title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(Color.appBlue)
                            .frame(width: geometry.size.width * audioService.progress, height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal)
                
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
                
                // Queue info
                Text("\(audioService.audioQueue.filter { $0.isPlayed }.count)/\(audioService.audioQueue.count) Articles")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Audio Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
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
                if !hasStartedPlaying && audioService.audioQueue.isEmpty {
                    Task {
                        await audioService.startPlayback()
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
                audioService.resumeDigest()
            } else {
                Task {
                    await audioService.startPlayback()
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
