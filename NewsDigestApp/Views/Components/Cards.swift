import SwiftUI

struct TopicCard: View {
    let topic: Topic
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) { // Reduced spacing
                Image(systemName: topic.icon)
                    .font(.system(size: 20)) // Slightly smaller icon
                    .foregroundColor(isSelected ? .white : .appBlue)
                
                Text(topic.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80) // Fixed height for consistency
            .padding(.vertical, 8) // Reduced padding
            .background(isSelected ? Color.appBlue : Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.appBlue : Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct SourceCard: View {
    let source: NewsSource
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Source Icon (first letter in a circle)
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.appBlue : Color.secondary.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Text(source.name.prefix(1))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(source.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(source.category.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.appBlue : Color.clear, lineWidth: 2)
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
                    .foregroundColor(isSelected ? .white : .appBlue)
                
                Text(timeRange.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .padding(.vertical, 8)
            .background(isSelected ? Color.appBlue : Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.appBlue : Color.gray.opacity(0.1), lineWidth: 1)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

struct ArticleDebugCard: View {
    let article: Article
    let index: Int
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header (always visible)
            Button(action: onTap) {
                HStack {
                    Text("Article \(index)")
                        .font(.headline)
                        .foregroundColor(.appBlue)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(article.title)
                        .font(.body)
                }
                
                // Description
                if let description = article.description {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(description)
                            .font(.body)
                    }
                }
                
                // Content
                if let content = article.content {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(content)
                            .font(.body)
                    }
                }
                
                // Source
                VStack(alignment: .leading, spacing: 8) {
                    Text("Source:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(article.source.name)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
