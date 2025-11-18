//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine
import WidgetKit

class LettersViewModel: ObservableObject {
    @Published var letters: [LoveLetter] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    
    func startListening(heartCode: String) {
        //print("📮 LettersViewModel: Starting listener for heartCode: \(heartCode)")
        listener?.remove()
        
        listener = db.collection("letters")
            .whereField("heartCode", isEqualTo: heartCode)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    //print("❌ LettersViewModel Error: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.letters = documents.compactMap { doc -> LoveLetter? in
                    let data = doc.data()
                    guard let heartCode = data["heartCode"] as? String,
                          let senderId = data["senderId"] as? String,
                          let senderName = data["senderName"] as? String,
                          let content = data["content"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp else {
                        //print("⚠️ LettersViewModel: Invalid letter data in document \(doc.documentID)")
                        return nil
                    }
                    
                    return LoveLetter(
                        id: doc.documentID,
                        heartCode: heartCode,
                        senderId: senderId,
                        senderName: senderName,
                        content: content,
                        createdAt: timestamp.dateValue(),
                        read: data["read"] as? Bool ?? false
                    )
                }
                
                //print("✅ LettersViewModel: Parsed \(self.letters.count) valid letters")
                self.updateWidget()
            }
    }
    
    func sendLetter(heartCode: String, content: String, senderName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            //print("❌ sendLetter: User not authenticated")
            errorMessage = "Not authenticated"
            completion(false)
            return
        }
        
        //print("📤 Sending letter from \(senderName) (userId: \(userId)) to heartCode: \(heartCode)")
        isLoading = true
        
        let letterData: [String: Any] = [
            "heartCode": heartCode,
            "senderId": userId,
            "senderName": senderName,
            "content": content,
            "createdAt": Timestamp(),
            "read": false
        ]
        
        //print("📝 Letter data: \(letterData)")
        db.collection("letters").addDocument(data: letterData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    //print("❌ Failed to send letter: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    //print("✅ Letter sent successfully!")
                    completion(true)
                }
            }
        }
    }
    
    func markAsRead(letterId: String) {
        db.collection("letters").document(letterId).updateData([
            "read": true
        ])
    }
    
    private func updateWidget() {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        let partnerLetters = letters.filter { $0.senderId != currentUserId }
        
        if let latestLetter = partnerLetters.first {
            let widgetLetterData = WidgetLetterData(
                content: latestLetter.content,
                senderName: latestLetter.senderName,
                date: latestLetter.createdAt
            )
            
            SharedDataManager.shared.updateLatestLetter(widgetLetterData)
        }
    }
}
