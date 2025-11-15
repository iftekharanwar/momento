//
//  Created by Iftekhar Anwar on 15/11/25.
//

import SwiftUI
import FirebaseAuth
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pairingViewModel: PairingViewModel
    @State private var showLogoutConfirmation = false
    @State private var showUnpairConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Account")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black.opacity(0.5))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "FFB3C6").opacity(0.2))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(hex: "FFB3C6"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(pairingViewModel.currentUserName)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                        
                                        if let email = FirebaseManager.shared.currentUser?.email {
                                            Text(email)
                                                .font(.system(size: 14))
                                                .foregroundColor(.black.opacity(0.6))
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        if pairingViewModel.isPaired {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Relationship")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.5))
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 12) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: "9B8DBA").opacity(0.2))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: "heart.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(Color(hex: "9B8DBA"))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(pairingViewModel.heartName)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.black)
                                            
                                            Text("Paired with \(pairingViewModel.partnerName)")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black.opacity(0.6))
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    
                                    Button(action: {
                                        showUnpairConfirmation = true
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "heart.slash.fill")
                                                .font(.system(size: 20))
                                            
                                            Text("Unpair from \(pairingViewModel.partnerName)")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("App Settings")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black.opacity(0.5))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "8B7355").opacity(0.2))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(hex: "8B7355"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Notifications")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                        
                                        Text("Manage notification preferences")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.black.opacity(0.3))
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                                
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "FFB3C6").opacity(0.2))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "square.grid.2x2.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(hex: "FFB3C6"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Widgets")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                        
                                        Text("Customize your home screen widgets")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.black.opacity(0.3))
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black.opacity(0.5))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "hand.raised.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.black.opacity(0.6))
                                        .frame(width: 50)
                                    
                                    Text("Privacy Policy")
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.black.opacity(0.3))
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.black.opacity(0.6))
                                        .frame(width: 50)
                                    
                                    Text("Terms of Service")
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.black.opacity(0.3))
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.black.opacity(0.6))
                                        .frame(width: 50)
                                    
                                    Text("Version")
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("1.0.0")
                                        .font(.system(size: 14))
                                        .foregroundColor(.black.opacity(0.5))
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 20))
                                
                                Text("Log Out")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "FFB3C6"))
                }
            }
        }
        .confirmationDialog("Log Out", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
            Button("Log Out", role: .destructive) {
                FirebaseManager.shared.signOut()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out?")
        }
        .confirmationDialog("Unpair", isPresented: $showUnpairConfirmation, titleVisibility: .visible) {
            Button("Unpair", role: .destructive) {
                pairingViewModel.unpair()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to unpair from \(pairingViewModel.partnerName)? This action cannot be undone.")
        }
    }
}



#Preview {
    SettingsView()
        .environmentObject(PairingViewModel())
}
