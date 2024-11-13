import SwiftUI

struct TopicCard: View {
    let topic: Topic
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: topic.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(topic.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.blue : Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
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
                        .fill(isSelected ? Color.blue : Color.secondary.opacity(0.1))
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
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

struct HeadlineCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
            
            if let description = article.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text(article.source.name)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// Preview Provider for the cards
struct Cards_Previews: PreviewProvider {
    static let sampleArticleJSON = """
    {
        "title": "Sample Headline",
        "description": "This is a sample description for the article preview",
        "content": "Sample content for the article",
        "source": {
            "name": "Reuters"
        }
    }
    """.data(using: .utf8)!
    
    static var sampleArticle: Article {
        try! JSONDecoder().decode(Article.self, from: sampleArticleJSON)
    }
    
    static var previews: some View {
        VStack(spacing: 20) {
            // Topic Card Preview
            TopicCard(
                topic: Topic(name: "Business", icon: "dollarsign.circle", category: "business"),
                isSelected: true
            ) {}
            
            // Source Card Preview
            SourceCard(
                source: NewsSource(id: "1", name: "Reuters", description: "News Agency", language: "en", country: "us", category: "general"),
                isSelected: true
            ) {}
            
            // Headline Card Preview
            HeadlineCard(article: sampleArticle)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}