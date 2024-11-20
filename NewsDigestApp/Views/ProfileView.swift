import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @StateObject private var preferencesService = UserPreferencesService()
    @State private var isPreferencesExpanded = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // User Info Section
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.user?.email ?? "User")
                                .font(.headline)
                            Text("Member since \(formattedDate)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Preferences Section
                Section {
                    DisclosureGroup(
                        isExpanded: $isPreferencesExpanded,
                        content: {
                            ForEach(Topic.available) { topic in
                                Button(action: {
                                    Task {
                                        do {
                                            try await preferencesService.toggleTopic(topic.id)
                                        } catch {
                                            errorMessage = error.localizedDescription
                                            showingError = true
                                        }
                                    }
                                }) {
                                    HStack {
                                        Label(topic.name, systemImage: topic.icon)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        if preferencesService.preferences.topicIds.contains(topic.id) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.appBlue)
                                        }
                                    }
                                }
                            }
                        },
                        label: {
                            Label("Default Topics", systemImage: "text.bookmark")
                                .foregroundColor(.primary)
                        }
                    )
                }
                
                // Account Section
                Section("Account") {
                    Button(role: .destructive) {
                        authManager.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "arrow.right.circle")
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                if let userId = authManager.user?.uid {
                    do {
                        preferencesService.setUserId(userId)
                        try await preferencesService.loadPreferences(for: userId)
                    } catch {
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {
                    showingError = false
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var formattedDate: String {
        let date = authManager.user?.metadata.creationDate ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
