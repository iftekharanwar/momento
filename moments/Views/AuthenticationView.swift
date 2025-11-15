//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import Combine

struct AuthenticationView: View {
    @State private var isSignUp = true
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var onAuthenticated: (String) -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "FFE5EC"),
                    Color(hex: "FFF0F5")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFB3C6"))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                Text("lovelee")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.black)
                
                VStack(spacing: 16) {
                    if isSignUp {
                        TextField("", text: $name, prompt: Text("Name").foregroundColor(.gray.opacity(0.5)))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                    
                    TextField("", text: $email, prompt: Text("Email").foregroundColor(.gray.opacity(0.5)))
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    HStack {
                        if showPassword {
                            TextField("", text: $password, prompt: Text("Password").foregroundColor(.gray.opacity(0.5)))
                        } else {
                            SecureField("", text: $password, prompt: Text("Password").foregroundColor(.gray.opacity(0.5)))
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 30)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal, 30)
                }
                
                Button(action: {
                    authenticate()
                }) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    } else {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .background(
                    isFormValid ? Color(hex: "FFB3C6") : Color.gray.opacity(0.3)
                )
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 30)
                .disabled(!isFormValid || isLoading)
                
                Button(action: {
                    isSignUp.toggle()
                    errorMessage = ""
                }) {
                    HStack(spacing: 4) {
                        Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            .foregroundColor(.black.opacity(0.6))
                        Text(isSignUp ? "Sign In" : "Create Account")
                            .foregroundColor(Color(hex: "FFB3C6"))
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 16))
                }
                
                Spacer()
            }
        }
    }
    
    private var isFormValid: Bool {
        if isSignUp {
            return !name.isEmpty && !email.isEmpty && !password.isEmpty && password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func authenticate() {
        isLoading = true
        errorMessage = ""
        
        if isSignUp {
            FirebaseManager.shared.signUp(email: email, password: password, name: name) { result in
                isLoading = false
                switch result {
                case .success(let userId):
                    onAuthenticated(name)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        } else {
            FirebaseManager.shared.signIn(email: email, password: password) { result in
                isLoading = false
                switch result {
                case .success:
                    onAuthenticated(name.isEmpty ? "User" : name)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    AuthenticationView { _ in }
}
