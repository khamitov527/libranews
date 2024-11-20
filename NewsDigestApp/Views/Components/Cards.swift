import SwiftUI

struct ArticleCard: View {
    let article: Article
    let audioService: AudioService
    @Binding var showingPlayer: Bool
    @Binding var selectedArticles: Set<Article>
    
    @State private var showActionButtons = false
    @State private var isSelected = false
    
    var body: some View {
        ZStack {
            // Main content
            HStack(alignment: .top, spacing: 12) {
                Button {
                    toggleSelection()
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        // Article Image
                        if let urlString = article.urlToImage, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                        .clipped()
                                case .failure:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                        }
                        
                        // Article Details
                        VStack(alignment: .leading, spacing: 4) {
                            // Title
                            Text(article.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .lineLimit(3)
                            
                            // Description
                            if let description = article.description {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer().frame(height: 4)
                            
                            // Source and Time
                            HStack(spacing: 4) {
                                Text(article.source.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if let publishedAt = article.publishedAt {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text(timeAgo(from: publishedAt))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.appBlue)
                        .font(.title2)
                }
                
                // Three-dot Button
                Button(action: {
                    withAnimation {
                        showActionButtons.toggle()
                    }
                }) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.appBlue : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .swipeActions(edge: .trailing) {
                swipeActionButtons()
            }
            
            // Overlay Action Buttons when three-dot button is pressed
            if showActionButtons {
                Color.black.opacity(0.001) // To capture taps outside
                    .onTapGesture {
                        withAnimation {
                            showActionButtons = false
                        }
                    }
                
                HStack {
                    Spacer()
                    actionButtons()
                        .transition(.move(edge: .trailing))
                }
                .padding(.trailing)
            }
        }
    }
    
    @ViewBuilder
    private func swipeActionButtons() -> some View {
        Button(action: {
            // Play button action
            Task {
                audioService.voiceServiceType = .openai
                showingPlayer = true
                await audioService.playArticle(article)
            }
        }) {
            Label("Play", systemImage: "play.fill")
        }
        .tint(.blue)
        
        Button(action: {
            // Save button action (no action for now)
        }) {
            Label("Save", systemImage: "bookmark")
        }
        .tint(.green)
        
        Button(action: {
            // Download button action (no action for now)
        }) {
            Label("Download", systemImage: "arrow.down.circle")
        }
        .tint(.orange)
    }
    
    @ViewBuilder
    private func actionButtons() -> some View {
        HStack(spacing: 20) {
            Button(action: {
                // Play button action
                Task {
                    audioService.voiceServiceType = .openai
                    showingPlayer = true
                    await audioService.playArticle(article)
                }
                withAnimation {
                    showActionButtons = false
                }
            }) {
                VStack {
                    Image(systemName: "play.fill")
                        .font(.title2)
                    Text("Play")
                        .font(.caption)
                }
            }
            
            Button(action: {
                // Save button action (no action for now)
                withAnimation {
                    showActionButtons = false
                }
            }) {
                VStack {
                    Image(systemName: "bookmark")
                        .font(.title2)
                    Text("Save")
                        .font(.caption)
                }
            }
            
            Button(action: {
                // Download button action (no action for now)
                withAnimation {
                    showActionButtons = false
                }
            }) {
                VStack {
                    Image(systemName: "arrow.down.circle")
                        .font(.title2)
                    Text("Download")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
    
    private func toggleSelection() {
        isSelected.toggle()
        if isSelected {
            selectedArticles.insert(article)
        } else {
            selectedArticles.remove(article)
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
