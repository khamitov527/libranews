import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningUp = false
    
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
                
                // Form Fields
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(isSigningUp ? .newPassword : .password)
                }
                .padding(.horizontal)
                
                // Sign In/Up Button
                Button {
                    Task {
                        if isSigningUp {
                            await authManager.signUp(email: email, password: password)
                        } else {
                            await authManager.signIn(email: email, password: password)
                        }
                    }
                } label: {
                    Text(isSigningUp ? "Sign Up" : "Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Toggle Sign In/Up
                Button {
                    isSigningUp.toggle()
                } label: {
                    Text(isSigningUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                
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
