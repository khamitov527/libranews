import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @Environment(\.colorScheme) private var colorScheme
    
    private let spacing = (
        tiny: 8.0,
        small: 13.0,
        medium: 21.0,
        large: 34.0,
        xlarge: 55.0
    )
    
    var body: some View {
        NavigationView {
            VStack(spacing: spacing.medium) {
                Spacer()
                    .frame(height: spacing.xlarge)
                
                // App Logo/Title Area
                VStack(spacing: spacing.large) {
                    Text("libra news")
                        .font(.system(size: 55, weight: .bold))
                        .foregroundColor(.appBlue)
                    
                    Text("Stay informed with personalized audio news.")
                        .font(.system(size: 21, weight: .light))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, spacing.large)
                        .lineSpacing(spacing.tiny)
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.85) : Color.black.opacity(0.7))
                        .frame(maxWidth: 320)
                }
                
                Spacer()
                
                // Sign In Button and Terms
                VStack(spacing: spacing.medium) {
                    Button {
                        Task {
                            await authManager.signInWithGoogle()
                        }
                    } label: {
                        HStack(spacing: spacing.small) {
                            Image("google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 21, height: 21)
                            
                            Text("Continue with Google")
                                .font(.system(size: 17, weight: .medium)) // Changed to medium for better legibility
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 34)
                                .fill(colorScheme == .dark ? Color.black : .white)
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 34)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, spacing.medium)
                    
                    Text("By continuing you agree to our Terms of Service and acknowledge that you have read our Privacy Policy to learn how we collect and use your data")
                        .font(.system(size: 13, weight: .light)) // Changed to light for better readability of small text
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, spacing.large)
                        .padding(.bottom, spacing.medium)
                        .frame(maxWidth: 320) // Constrain width for better line length
                }
                .padding(.bottom, spacing.large)
            }
            .alert("Error", isPresented: .constant(authManager.errorMessage != nil)) {
                Button("OK") {
                    authManager.errorMessage = nil
                }
            } message: {
                Text(authManager.errorMessage ?? "")
            }
        }
        .navigationBarHidden(true)
    }
}
