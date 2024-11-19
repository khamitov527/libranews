import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // User Info Section
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    Text(authManager.user?.email ?? "User")
                        .font(.title2)
                }
                .padding(.top, 40)
                
                // Settings/Options could go here
                List {
                    // Add your profile settings here
                    Section("Account") {
                        Button(role: .destructive) {
                            authManager.signOut()
                        } label: {
                            Label("Sign Out", systemImage: "arrow.right.circle")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
