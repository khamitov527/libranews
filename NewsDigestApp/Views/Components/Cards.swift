import SwiftUI

struct ArticleCard: View {
    let article: Article
    let audioService: AudioService
    @Binding var showingPlayer: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Article Image with Play Button Overlay
            if let urlString = article.urlToImage, let url = URL(string: urlString) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    // Play Button
                    Button {
                        Task {
                            audioService.voiceServiceType = .openai
                            showingPlayer = true
                            await audioService.playArticle(article)
                        }
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(16)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Source and Time
                HStack {
                    Text(article.source.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.appBlue)
                    
                    if let publishedAt = article.publishedAt {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(timeAgo(from: publishedAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Small Play Button
                    Button {
                        Task {
                            audioService.voiceServiceType = .openai
                            showingPlayer = true
                            await audioService.playArticle(article)
                        }
                    } label: {
                        Image(systemName: "headphones.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.appBlue)
                    }
                }
                
                // Title
                Text(article.title)
                    .font(.headline)
                    .lineLimit(3)
                
                // Description
                if let description = article.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
