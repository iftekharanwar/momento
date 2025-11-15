//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import Combine

struct JoinHeartView: View {
    @Binding var isPresented: Bool
    var userName: String
    var onHeartJoined: (String, String) -> Void
    
    @State private var enteredCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
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
                
                ZStack {
                    Circle()
                        .stroke(Color(hex: "FFB3C6"), lineWidth: 4)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: "FFB3C6"))
                }
                
                Text("Join Heart")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Enter the invite code from your partner")
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                VStack(spacing: 12) {
                    TextField("", text: $enteredCode, prompt: Text("Enter Code").foregroundColor(.gray.opacity(0.3)))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(hex: "FFB3C6"))
                        .multilineTextAlignment(.center)
                        .textCase(.uppercase)
                        .autocorrectionDisabled()
                        .onChange(of: enteredCode) { _, newValue in
                            enteredCode = newValue.uppercased().prefix(6).filter { $0.isLetter || $0.isNumber }.map { String($0) }.joined()
                            errorMessage = ""
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 30)
                        .background(Color(hex: "F5F5F5"))
                        .cornerRadius(15)
                    
                    Text("\(enteredCode.count)/6")
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.5))
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
                    joinHeart()
                }) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    } else {
                        Text("Join Heart")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    }
                }
                .background(
                    enteredCode.count == 6 && !isLoading ? Color(hex: "9B8DBA") : Color.gray.opacity(0.3)
                )
                .cornerRadius(15)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .disabled(enteredCode.count != 6 || isLoading)
            }
        }
    }
    
    private func joinHeart() {
        isLoading = true
        errorMessage = ""
        
        FirebaseManager.shared.joinHeart(code: enteredCode, partnerName: userName) { result in
            isLoading = false
            switch result {
            case .success(let heartData):
                onHeartJoined(heartData.name, enteredCode)
                isPresented = false
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    JoinHeartView(isPresented: .constant(true), userName: "Sarah") { _, _ in }
}
