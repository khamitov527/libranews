import SwiftUI

struct PlayerView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var audioService: AudioService
    @State private var hasStartedPlaying = false
    @State private var showingVoiceError = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                if audioService.isGenerating {
                    generatingContent
                } else {
                    mainContent
                }
            }
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
        }
    }
    
    // MARK: - Views
    private var generatingContent: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Preparing audio...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("This may take a moment")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
    
    private var mainContent: some View {
        VStack {
            Spacer()
            AudioPlayerControls(audioService: audioService)
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Methods
    private func handleOnAppear() {
        if !hasStartedPlaying {
            audioService.startNewPlayback()
            hasStartedPlaying = true
        }
    }
}
