//
//  Created by Iftekhar Anwar on 08/11/25.
//

import SwiftUI
import FirebaseCore
import Combine


@main
struct momentsApp: App {
    @StateObject private var pairingViewModel = PairingViewModel()
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var showAuthentication = true
    @State private var showCreateOrJoin = false
    @State private var showCreateHeart = false
    @State private var showJoinHeart = false
    @State private var userName = ""
    @State private var isCheckingHeart = false
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !firebaseManager.isAuthenticated {
                    AuthenticationView { name in
                        userName = name
                        showAuthentication = false
                        checkForExistingHeart()
                    }
                } else if isCheckingHeart {
                    LoadingView()
                } else if showCreateOrJoin || pairingViewModel.needsRepairing {
                    CreateOrJoinHeartView(
                        showCreateHeart: $showCreateHeart,
                        showJoinHeart: $showJoinHeart
                    )
                } else {
                    ContentView()
                        .environmentObject(pairingViewModel)
                }
            }
            .sheet(isPresented: $showCreateHeart) {
                CreateHeartView(
                    isPresented: $showCreateHeart,
                    userName: userName.isEmpty ? pairingViewModel.currentUserName : userName
                ) { heartName, code in
                    pairingViewModel.setupHeart(
                        name: heartName,
                        code: code,
                        userName: userName.isEmpty ? pairingViewModel.currentUserName : userName,
                        isCreator: true
                    )
                    showCreateOrJoin = false
                }
            }
            .sheet(isPresented: $showJoinHeart) {
                JoinHeartView(
                    isPresented: $showJoinHeart,
                    userName: userName.isEmpty ? pairingViewModel.currentUserName : userName
                ) { heartName, code in
                    pairingViewModel.setupHeart(
                        name: heartName,
                        code: code,
                        userName: userName.isEmpty ? pairingViewModel.currentUserName : userName,
                        isCreator: false
                    )
                    showCreateOrJoin = false
                }
            }
            .onAppear {
                if firebaseManager.isAuthenticated {
                    showAuthentication = false
                    checkForExistingHeart()
                }
            }
        }
    }
    
    private func checkForExistingHeart() {
        if !pairingViewModel.heartCode.isEmpty {
            showCreateOrJoin = false
            return
        }
        
        isCheckingHeart = true
        
        FirebaseManager.shared.getUserName { name in
            if let name = name {
                userName = name
                pairingViewModel.currentUserName = name
            }
            
            FirebaseManager.shared.getUserHeartCode { code in
                isCheckingHeart = false
                
                if let code = code {
                    FirebaseManager.shared.getHeartData(code: code) { result in
                        switch result {
                        case .success(let heartData):
                            let isCreator = heartData.creatorName == userName
                            pairingViewModel.setupHeart(
                                name: heartData.name,
                                code: code,
                                userName: userName,
                                isCreator: isCreator
                            )
                            showCreateOrJoin = false
                        case .failure:
                            showCreateOrJoin = true
                        }
                    }
                } else {
                    showCreateOrJoin = true
                }
            }
        }
    }
}

struct LoadingView: View {
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
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color(hex: "FFB3C6"))
                
                Text("Loading...")
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(0.6))
            }
        }
    }
}
