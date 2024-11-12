import SwiftUI

struct SourceSelectionView: View {
    @EnvironmentObject private var userPreferences: UserPreferences
    @ObservedObject var newsService: NewsService
    @Binding var selectedSource: NewsSource?
    
    var sourcesByCategory: [String: [NewsSource]] {
        Dictionary(grouping: newsService.availableSources) { $0.category }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Source")
                .font(.headline)
            
            if newsService.isLoading {
                ProgressView()
            } else if let error = newsService.error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
            } else {
                List {
                    ForEach(sourcesByCategory.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category.capitalized)) {
                            ForEach(sourcesByCategory[category] ?? []) { source in
                                SourceCell(source: source, isSelected: source == selectedSource) {
                                    selectedSource = source
                                    newsService.fetchNews(sourceId: source.id)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .frame(height: 300)
            }
        }
    }
}

struct SourceCell: View {
    let source: NewsSource
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(source.name)
                        .font(.headline)
                    Text(source.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
