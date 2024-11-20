import SwiftUI

struct ArticleCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Article Image
            if let urlString = article.urlToImage, let url = URL(string: urlString) {
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

struct TopicCard: View {
    let topic: Topic
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: topic.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .appBlue : .primary)
                
                Text(topic.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .appBlue : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.appBlue : Color.gray.opacity(0.1), lineWidth: 2)
            )
        }
    }
}

struct SourceCard: View {
    let source: NewsSource
    let isSelected: Bool
    let action: () -> Void

    private var faviconURL: URL? {
        if let domain = source.url?.host {
            return URL(string: "https://www.google.com/s2/favicons?domain=\(domain)&sz=128")
        }
        return nil
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Larger logo
                AsyncImage(url: faviconURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                } placeholder: {
                    ZStack {
                        Circle()
                            .fill(Color.secondary.opacity(0.1))
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color.appBlue : Color.clear, lineWidth: 2)
                            )
                            .frame(width: 40, height: 40)

                        Text(source.name.prefix(1))
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(isSelected ? .appBlue : .primary)
                    }
                }

                // Text with smaller size
                VStack(spacing: 2) {
                    Text(source.name)
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .appBlue : .primary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(source.category.capitalized)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .multilineTextAlignment(.center)
            }
            .frame(width: 144, height: 90)
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.appBlue : Color.gray.opacity(0.1), lineWidth: 2)
                    .padding(1) // Ensures outline is fully visible
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

struct TimeRangeCard: View {
    let timeRange: TimeRange
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: timeRange.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .appBlue : .primary)
                
                Text(timeRange.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .appBlue : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.appBlue : Color.gray.opacity(0.1), lineWidth: 2)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}
