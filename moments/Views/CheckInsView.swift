//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import FirebaseAuth

struct CheckInsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pairingViewModel: PairingViewModel
    @StateObject private var viewModel = CheckInsViewModel()
    @State private var showCheckInSheet = false
    
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    var hasCheckedInToday: Bool {
        viewModel.getTodayCheckIn(userId: currentUserId) != nil
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
                    
                    Text("Check-Ins")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: { showCheckInSheet = true }) {
                        Image(systemName: hasCheckedInToday ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(hasCheckedInToday ? Color.green : Color(hex: "FFB3C6"))
                            .frame(width: 44, height: 44)
                    }
                    .disabled(hasCheckedInToday)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                if viewModel.checkIns.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "FFB3C6").opacity(0.3))
                        
                        Text("No check-ins yet")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black.opacity(0.6))
                        
                        Text("Share how you're feeling")
                            .font(.system(size: 16))
                            .foregroundColor(.black.opacity(0.4))
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.checkIns) { checkIn in
                                CheckInCard(
                                    checkIn: checkIn,
                                    isFromMe: checkIn.userId == currentUserId
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showCheckInSheet) {
            CreateCheckInView(
                heartCode: pairingViewModel.heartCode,
                userName: pairingViewModel.currentUserName,
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

struct CheckInCard: View {
    let checkIn: CheckIn
    let isFromMe: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text(checkIn.mood)
                .font(.system(size: 44))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(isFromMe ? "You" : checkIn.userName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isFromMe ? Color(hex: "FFB3C6") : Color(hex: "9B8DBA"))
                    
                    Spacer()
                    
                    Text(checkIn.createdAt, style: .relative)
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.5))
                }
                
                if !checkIn.note.isEmpty {
                    Text(checkIn.note)
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

struct CreateCheckInView: View {
    @Environment(\.dismiss) var dismiss
    let heartCode: String
    let userName: String
    @ObservedObject var viewModel: CheckInsViewModel
    
    @State private var selectedMood = "😊"
    @State private var note = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 12) {
                        Text(selectedMood)
                            .font(.system(size: 80))
                        
                        Text("How are you feeling?")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.top, 20)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                        ForEach(CheckIn.moodOptions, id: \.self) { mood in
                            Button(action: {
                                selectedMood = mood
                            }) {
                                Text(mood)
                                    .font(.system(size: 44))
                                    .frame(width: 60, height: 60)
                                    .background(
                                        selectedMood == mood ?
                                        Color(hex: "FFE5EC") : Color(hex: "F5F5F5")
                                    )
                                    .cornerRadius(15)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add a note (optional)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black.opacity(0.6))
                        
                        TextField("What's on your mind?", text: $note, axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color(hex: "F5F5F5"))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button(action: submitCheckIn) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        } else {
                            Text("Check In")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                    }
                    .background(Color(hex: "FFB3C6"))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .disabled(viewModel.isLoading)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func submitCheckIn() {
        viewModel.submitCheckIn(
            heartCode: heartCode,
            mood: selectedMood,
            note: note,
            userName: userName
        ) { success in
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    CheckInsView()
        .environmentObject(PairingViewModel())
}
