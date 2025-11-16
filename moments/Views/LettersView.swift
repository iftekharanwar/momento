//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import FirebaseAuth

struct LettersView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pairingViewModel: PairingViewModel
    @StateObject private var viewModel = LettersViewModel()
    @State private var showCompose = false
    @State private var selectedTab = 0 // 0 = Received, 1 = Sent
    
    var receivedLetters: [LoveLetter] {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        return viewModel.letters.filter { $0.senderId != currentUserId }
    }
    
    var sentLetters: [LoveLetter] {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        return viewModel.letters.filter { $0.senderId == currentUserId }
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Love Letters")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: { showCompose = true }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "FFB3C6"))
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                HStack(spacing: 0) {
                    Button(action: { selectedTab = 0 }) {
                        VStack(spacing: 8) {
                            Text("Received")
                                .font(.system(size: 16, weight: selectedTab == 0 ? .semibold : .regular))
                                .foregroundColor(selectedTab == 0 ? Color(hex: "FFB3C6") : .black.opacity(0.5))
                            
                            if selectedTab == 0 {
                                Rectangle()
                                    .fill(Color(hex: "FFB3C6"))
                                    .frame(height: 2)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: { selectedTab = 1 }) {
                        VStack(spacing: 8) {
                            Text("Sent")
                                .font(.system(size: 16, weight: selectedTab == 1 ? .semibold : .regular))
                                .foregroundColor(selectedTab == 1 ? Color(hex: "FFB3C6") : .black.opacity(0.5))
                            
                            if selectedTab == 1 {
                                Rectangle()
                                    .fill(Color(hex: "FFB3C6"))
                                    .frame(height: 2)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                TabView(selection: $selectedTab) {
                    LettersListView(
                        letters: receivedLetters,
                        emptyMessage: "No letters received yet",
                        emptyDescription: "When your partner sends you a letter, it will appear here"
                    )
                    .tag(0)
                    
                    LettersListView(
                        letters: sentLetters,
                        emptyMessage: "No letters sent yet",
                        emptyDescription: "Send your first love letter"
                    )
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .sheet(isPresented: $showCompose) {
            ComposeLetterView(
                heartCode: pairingViewModel.heartCode,
                senderName: pairingViewModel.currentUserName,
                viewModel: viewModel
            )
        }
        .onAppear {
            if !pairingViewModel.heartCode.isEmpty {
                viewModel.startListening(heartCode: pairingViewModel.heartCode)
            }
        }
    }
}

struct LettersListView: View {
    let letters: [LoveLetter]
    let emptyMessage: String
    let emptyDescription: String
    
    var body: some View {
        if letters.isEmpty {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "envelope.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "FFB3C6").opacity(0.3))
                
                Text(emptyMessage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black.opacity(0.6))
                
                Text(emptyDescription)
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(letters) { letter in
                        LetterCard(
                            letter: letter,
                            isFromMe: letter.senderId == Auth.auth().currentUser?.uid
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
    }
}

struct LetterCard: View {
    let letter: LoveLetter
    let isFromMe: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isFromMe ? "You" : letter.senderName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isFromMe ? Color(hex: "FFB3C6") : Color(hex: "9B8DBA"))
                
                Spacer()
                
                Text(letter.createdAt, style: .relative)
                    .font(.system(size: 12))
                    .foregroundColor(.black.opacity(0.5))
            }
            
            Text(letter.content)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .lineSpacing(4)
            
            if !letter.read && !isFromMe {
                HStack {
                    Spacer()
                    Text("New")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(hex: "FFB3C6"))
                        .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

struct ComposeLetterView: View {
    @Environment(\.dismiss) var dismiss
    let heartCode: String
    let senderName: String
    @ObservedObject var viewModel: LettersViewModel
    
    @State private var letterContent = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FFE5EC"))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: "FFB3C6"))
                    }
                    .padding(.top, 20)
                    
                    Text("Write a Love Letter")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)

                    ZStack(alignment: .topLeading) {
                        if letterContent.isEmpty {
                            Text("Pour your heart out...")
                                .font(.system(size: 16))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                        }
                        
                        TextEditor(text: $letterContent)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                            .focused($isTextFieldFocused)
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color(hex: "F5F5F5"))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    
                    Button(action: sendLetter) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        } else {
                            Text("Send Letter")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                    }
                    .background(
                        letterContent.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "FFB3C6")
                    )
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .disabled(letterContent.isEmpty || viewModel.isLoading)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    private func sendLetter() {
        viewModel.sendLetter(heartCode: heartCode, content: letterContent, senderName: senderName) { success in
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    LettersView()
        .environmentObject(PairingViewModel())
}
