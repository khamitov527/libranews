import SwiftUI

struct TopicSelectionView: View {
    @EnvironmentObject private var userPreferences: UserPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Topics")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Topic.available) { topic in
                    TopicCell(
                        topic: topic,
                        isSelected: userPreferences.selectedTopics.contains(topic.id)
                    ) {
                        if userPreferences.selectedTopics.contains(topic.id) {
                            userPreferences.selectedTopics.remove(topic.id)
                        } else {
                            userPreferences.selectedTopics.insert(topic.id)
                        }
                    }
                }
            }
        }
    }
}

struct TopicCell: View {
    let topic: Topic
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: topic.icon)
                Text(topic.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.secondary, lineWidth: 1)
            )
        }
        .foregroundColor(.primary)
    }
}
