import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Logo/Title Area
                VStack {
                    Text("News Digest")
                        .font(.largeTitle)
                        .bold()
                    Text("Your Daily News Companion")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 40)
                
                // Google Sign In Button
                Button {
                    Task {
                        await authManager.signInWithGoogle()
                    }
                } label: {
                    HStack {
                        Image("google_logo") // You'll need to add this image to your assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("Sign in with Google")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .alert("Error", isPresented: .constant(authManager.errorMessage != nil)) {
                Button("OK") {
                    authManager.errorMessage = nil
                }
            } message: {
                Text(authManager.errorMessage ?? "")
            }
        }
    }
}
