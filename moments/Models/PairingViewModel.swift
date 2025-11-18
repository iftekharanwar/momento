//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import FirebaseFirestore
import Combine
import WidgetKit
import FirebaseAuth

class PairingViewModel: ObservableObject {
    @Published var currentUserName: String = ""
    @Published var partnerName: String = ""
    @Published var heartName: String = ""
    @Published var heartCode: String = ""
    @Published var isPaired: Bool = false
    @Published var isCreator: Bool = false
    @Published var needsRepairing: Bool = false
    
    private let userDefaultsKey = "momentoUserData"
    private var heartListener: ListenerRegistration?
    
    init() {
        loadUserData()
    }
    
    deinit {
        heartListener?.remove()
    }
    
    func setupHeart(name: String, code: String, userName: String, isCreator: Bool) {
        //print("💝 PairingViewModel: Setting up heart")
        //print("   - Name: \(name)")
        //print("   - Code: \(code)")
        //print("   - UserName: \(userName)")
        //print("   - IsCreator: \(isCreator)")
        
        self.heartName = name
        self.heartCode = code
        self.currentUserName = userName
        self.isCreator = isCreator
        self.needsRepairing = false
        
        saveUserData()
        updateWidgetData()
        startListeningToHeart()
    }
    
    func startListeningToHeart() {
        guard !heartCode.isEmpty else { return }
        
        heartListener?.remove()
        
        heartListener = FirebaseManager.shared.listenToHeartUpdates(code: heartCode) { [weak self] heartData in
            guard let self = self, let heartData = heartData else { return }
            
            DispatchQueue.main.async {
                self.heartName = heartData.name
                self.isPaired = heartData.isPaired
                
                if self.isCreator {
                    self.partnerName = heartData.partnerName
                } else {
                    self.partnerName = heartData.creatorName
                }
                
                self.saveUserData()
                self.updateWidgetData()
            }
        }
    }
    
    func updateHeartName(_ name: String) {
        heartName = name
        saveUserData()
        updateWidgetData()
    }
    
    func unpair() {
        heartListener?.remove()
        heartName = ""
        heartCode = ""
        partnerName = ""
        isPaired = false
        needsRepairing = true
        saveUserData()
        updateWidgetData()
        
        if let userId = FirebaseManager.shared.currentUser?.uid {
            let db = Firestore.firestore()
            db.collection("users").document(userId).updateData([
                "heartCode": "",
                "heartRole": ""
            ])
        }
    }
    
    private func saveUserData() {
        let data = UserSessionData(
            currentUserName: currentUserName,
            partnerName: partnerName,
            heartName: heartName,
            heartCode: heartCode,
            isPaired: isPaired,
            isCreator: isCreator
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUserData() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode(UserSessionData.self, from: data) else {
            return
        }
        
        currentUserName = decoded.currentUserName
        partnerName = decoded.partnerName
        heartName = decoded.heartName
        heartCode = decoded.heartCode
        isPaired = decoded.isPaired
        isCreator = decoded.isCreator
        
        if !heartCode.isEmpty {
            updateWidgetData()
            startListeningToHeart()
        }
    }
    
    private func updateWidgetData() {
        SharedDataManager.shared.updatePairingInfo(
            heartName: heartName,
            partnerName: partnerName,
            isPaired: isPaired
        )
    }
}

struct UserSessionData: Codable {
    var currentUserName: String
    var partnerName: String
    var heartName: String
    var heartCode: String
    var isPaired: Bool
    var isCreator: Bool
}
