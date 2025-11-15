//
//  Created by Iftekhar Anwar on 12/11/25.
//

import SwiftUI
import Combine

struct ProfileView: View {
    @EnvironmentObject var pairingViewModel: PairingViewModel
    @State private var showEditHeartName = false
    @State private var showHeartCode = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("Profile")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color(hex: "8B7355"))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    if pairingViewModel.isPaired {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            
                            Text("Paired")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(20)
                    } else {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                            
                            Text("Waiting for partner")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    HeartCardView(
                        pairingViewModel: pairingViewModel,
                        showEditHeartName: $showEditHeartName
                    )
                    .padding(.horizontal, 20)

                    if !pairingViewModel.isPaired {
                        HeartCodeSection(
                            heartCode: pairingViewModel.heartCode,
                            onShowCode: {
                                showHeartCode = true
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    ImportantDatesSection()
                        .padding(.horizontal, 20)
                    
                    Spacer(minLength: 80)
                }
            }
        }
        .sheet(isPresented: $showEditHeartName) {
            EditHeartNameSheet(
                pairingViewModel: pairingViewModel,
                isPresented: $showEditHeartName
            )
        }
        .sheet(isPresented: $showHeartCode) {
            HeartCodeSheet(
                heartCode: pairingViewModel.heartCode,
                isPresented: $showHeartCode
            )
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(pairingViewModel)
        }
    }
}

struct HeartCardView: View {
    @ObservedObject var pairingViewModel: PairingViewModel
    @Binding var showEditHeartName: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(pairingViewModel.heartName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Button(action: {
                    showEditHeartName = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "8B7355"))
                }
            }
            
            HStack(spacing: 0) {
                VStack(spacing: 12) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color(hex: "6B4E3D"))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            )
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "8B7355"))
                            )
                            .offset(x: 5, y: 5)
                    }
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Text(pairingViewModel.currentUserName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "8B7355"))
                    .padding(.horizontal, 20)
                
                Spacer()
                
                VStack(spacing: 12) {
                    if pairingViewModel.isPaired && !pairingViewModel.partnerName.isEmpty {
                        Circle()
                            .fill(Color(hex: "9B8DBA"))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Text(pairingViewModel.partnerName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    } else {
                        Circle()
                            .fill(Color(hex: "9B8DBA"))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Text("Partner")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 30)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

struct HeartCodeSection: View {
    let heartCode: String
    let onShowCode: () -> Void
    @State private var showCopiedAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Share Your Heart")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black.opacity(0.5))
            
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FFB3C6"))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Waiting for Partner")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("Share your heart code to connect")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    Spacer()
                }
                
                VStack(spacing: 4) {
                    Text("Heart Code")
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(heartCode)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "FFB3C6"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .background(Color(hex: "FFE5EC"))
                .cornerRadius(15)
                
                HStack(spacing: 12) {
                    Button(action: {
                        UIPasteboard.general.string = heartCode
                        showCopiedAlert = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCopiedAlert = false
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.on.doc.fill")
                                .font(.system(size: 16))
                            Text("Copy Code")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "FFB3C6"))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        let activityVC = UIActivityViewController(
                            activityItems: ["Join my heart on Momento! Use code: \(heartCode)"],
                            applicationActivities: nil
                        )
                        
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            rootVC.present(activityVC, animated: true)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16))
                            Text("Share")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "9B8DBA"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "F0ECFF"))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
        .overlay(
            Group {
                if showCopiedAlert {
                    VStack {
                        Text("Copied!")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(20)
                    }
                    .transition(.opacity)
                }
            }
        )
    }
}

struct ImportantDatesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Important Dates")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black.opacity(0.5))
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "8B7355").opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "8B7355"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Manage Important Dates")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Add anniversaries and special moments")
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.black.opacity(0.3))
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
    }
}

struct EditHeartNameSheet: View {
    @ObservedObject var pairingViewModel: PairingViewModel
    @Binding var isPresented: Bool
    @State private var newName: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                VStack(spacing: 20) {
                    Text("Edit Heart Name")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    
                    TextField("Enter name", text: $newName)
                        .font(.system(size: 18))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !newName.isEmpty {
                            pairingViewModel.updateHeartName(newName)
                        }
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            newName = pairingViewModel.heartName
        }
    }
}

struct HeartCodeSheet: View {
    let heartCode: String
    @Binding var isPresented: Bool
    @State private var showCopiedAlert = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.black.opacity(0.6))
                    .padding()
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFB3C6"))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                Text("Your Heart Code")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                Text(heartCode)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(hex: "FFB3C6"))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 30)
                    .background(Color(hex: "FFE5EC"))
                    .cornerRadius(20)
                
                Button(action: {
                    UIPasteboard.general.string = heartCode
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
                }
                .padding(.horizontal, 40)
                
                Spacer()
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

#Preview {
    ProfileView()
        .environmentObject(PairingViewModel())
}
