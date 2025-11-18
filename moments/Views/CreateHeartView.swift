//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import Combine

struct CreateHeartView: View {
    @Binding var isPresented: Bool
    var userName: String
    var onHeartCreated: (String, String) -> Void
    
    @State private var heartName = ""
    @State private var generatedCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showCode = false
    @State private var showCopiedAlert = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if !showCode {
                VStack(spacing: 30) {
                    HStack {
                        Spacer()
                        Button("Cancel") {
                            isPresented = false
                        }
                        .foregroundColor(.black.opacity(0.6))
                        .padding()
                    }
                    
                    Spacer()
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 70))
                        .foregroundColor(Color(hex: "FFB3C6"))
                    
                    Text("Create Your Heart")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("This will create a shared heart for you and your partner")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Heart Name")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.6))
                        
                        TextField("", text: $heartName, prompt: Text("e.g., Me & Maaryah").foregroundColor(.gray.opacity(0.4)))
                            .padding()
                            .background(Color(hex: "F5F5F5"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        createHeart()
                    }) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        } else {
                            Text("Create Heart")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                    }
                    .background(
                        heartName.isEmpty || isLoading ? Color.gray.opacity(0.3) : Color(hex: "9B8DBA")
                    )
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .disabled(heartName.isEmpty || isLoading)
                }
            } else {
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
                    
                    Text("Heart Created!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Share this code with your partner")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.6))
                    
                    VStack(spacing: 16) {
                        Text(generatedCode)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(hex: "FFB3C6"))
                            .padding(.horizontal, 40)
                            .padding(.vertical, 30)
                            .background(Color(hex: "FFE5EC"))
                            .cornerRadius(20)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            UIPasteboard.general.string = generatedCode
                            showCopiedAlert = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopiedAlert = false
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.on.doc.fill")
                                    .font(.system(size: 16))
                                Text("Copy Code")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(hex: "FFB3C6"))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                        
                        Button(action: {
                            onHeartCreated(heartName, generatedCode)
                            isPresented = false
                        }) {
                            Text("Next")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(hex: "9B8DBA"))
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                .overlay(
                    Group {
                        if showCopiedAlert {
                            VStack {
                                Spacer()
                                Text("Copied!")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(20)
                                    .padding(.bottom, 100)
                            }
                            .transition(.opacity)
                        }
                    }
                )
            }
        }
    }
    
    private func createHeart() {
        isLoading = true
        errorMessage = ""
        
        FirebaseManager.shared.createHeart(name: heartName, creatorName: userName) { result in
            isLoading = false
            switch result {
            case .success(let code):
                generatedCode = code
                withAnimation {
                    showCode = true
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    CreateHeartView(isPresented: .constant(true), userName: "John") { _, _ in }
}
