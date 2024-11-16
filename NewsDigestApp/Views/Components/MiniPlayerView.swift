import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var audioService: AudioService
    @Binding var showingPlayer: Bool
    
    private var currentSegment: ArticleAudioSegment? {
        audioService.audioQueue.first(where: { !$0.isPlayed })
    }
    
    var body: some View {
        Button(action: { showingPlayer = true }) {
            HStack {
                // Waveform icon and article info
                HStack(spacing: 12) {
                    Image(systemName: "waveform")
                        .font(.title3)
                        .foregroundColor(.appBlue)
                    
                    if let segment = currentSegment {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(segment.article.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            HStack(spacing: 4) {
                                if let author = segment.article.author {
                                    Text(author)
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                                
                                if segment.article.author != nil && segment.article.source.name != "" {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                
                                if segment.article.source.name != "" {
                                    Text(segment.article.source.name)
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                            }
                        }
                    } else {
                        Text("News Digest")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                Button(action: handlePlayPause) {
                    Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundColor(.appBlue)
                }
                .disabled(audioService.isGenerating)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func handlePlayPause() {
        if audioService.isPlaying {
            audioService.pauseDigest()
        } else if let player = audioService.audioPlayer {
            audioService.resumeDigest()
        }
    }
}
