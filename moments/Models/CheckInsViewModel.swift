//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

class CheckInsViewModel: ObservableObject {
    @Published var checkIns: [CheckIn] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    
    func startListening(heartCode: String) {
        listener?.remove()
        
        listener = db.collection("checkIns")
            .whereField("heartCode", isEqualTo: heartCode)
            .order(by: "createdAt", descending: true)
            .limit(to: 30)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.checkIns = documents.compactMap { doc -> CheckIn? in
                    let data = doc.data()
                    guard let heartCode = data["heartCode"] as? String,
                          let userId = data["userId"] as? String,
                          let userName = data["userName"] as? String,
                          let mood = data["mood"] as? String,
                          let note = data["note"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp else {
                        return nil
                    }
                    
                    return CheckIn(
                        id: doc.documentID,
                        heartCode: heartCode,
                        userId: userId,
                        userName: userName,
                        mood: mood,
                        note: note,
                        createdAt: timestamp.dateValue()
                    )
                }
            }
    }
    
    func submitCheckIn(heartCode: String, mood: String, note: String, userName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Not authenticated"
            completion(false)
            return
        }
        
        isLoading = true
        
        let checkInData: [String: Any] = [
            "heartCode": heartCode,
            "userId": userId,
            "userName": userName,
            "mood": mood,
            "note": note,
            "createdAt": Timestamp()
        ]
        
        db.collection("checkIns").addDocument(data: checkInData) { [weak self] error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func getTodayCheckIn(userId: String) -> CheckIn? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return checkIns.first { checkIn in
            checkIn.userId == userId &&
            calendar.isDate(checkIn.createdAt, inSameDayAs: today)
        }
    }
}
