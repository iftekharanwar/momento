//
//  Created by Iftekhar Anwar on 13/11/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Combine

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated = false
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    private init() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isAuthenticated = user != nil
        }
    }

    func signUp(email: String, password: String, name: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let userId = result?.user.uid else { return }
            
            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "createdAt": Timestamp(),
                "heartCode": "",
                "heartRole": ""
            ]
            
            self?.db.collection("users").document(userId).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(userId))
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let userId = result?.user.uid {
                completion(.success(userId))
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
    
    func getUserName(completion: @escaping (String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let name = data["name"] as? String {
                completion(name)
            } else {
                completion(nil)
            }
        }
    }
    
    func getUserHeartCode(completion: @escaping (String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let heartCode = data["heartCode"] as? String,
               !heartCode.isEmpty {
                completion(heartCode)
            } else {
                completion(nil)
            }
        }
    }
    
    func createHeart(name: String, creatorName: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let code = generateCode()
        
        let heartData: [String: Any] = [
            "name": name,
            "code": code,
            "creatorId": userId,
            "creatorName": creatorName,
            "partnerId": "",
            "partnerName": "",
            "createdAt": Timestamp(),
            "isPaired": false
        ]
        
        db.collection("hearts").document(code).setData(heartData) { [weak self] error in
            if let error = error {
                completion(.failure(error))
            } else {
                self?.db.collection("users").document(userId).updateData([
                    "heartCode": code,
                    "heartRole": "creator"
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(code))
                    }
                }
            }
        }
    }
    
    func joinHeart(code: String, partnerName: String, completion: @escaping (Result<HeartData, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let heartRef = db.collection("hearts").document(code)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let heartDocument: DocumentSnapshot
            do {
                try heartDocument = transaction.getDocument(heartRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let data = heartDocument.data(),
                  let heartName = data["name"] as? String,
                  let creatorId = data["creatorId"] as? String,
                  let creatorName = data["creatorName"] as? String,
                  let isPaired = data["isPaired"] as? Bool else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid heart code"])
                errorPointer?.pointee = error
                return nil
            }
            
            if isPaired {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Heart already paired"])
                errorPointer?.pointee = error
                return nil
            }
            
            if creatorId == userId {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot join your own heart"])
                errorPointer?.pointee = error
                return nil
            }
            
            transaction.updateData([
                "partnerId": userId,
                "partnerName": partnerName,
                "isPaired": true,
                "pairedAt": Timestamp()
            ], forDocument: heartRef)
            
            let userRef = self.db.collection("users").document(userId)
            transaction.updateData([
                "heartCode": code,
                "heartRole": "partner"
            ], forDocument: userRef)
            
            return ["heartName": heartName, "creatorName": creatorName]
        }) { (object, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let result = object as? [String: String],
               let heartName = result["heartName"],
               let creatorName = result["creatorName"] {
                let heartData = HeartData(
                    name: heartName,
                    code: code,
                    creatorName: creatorName,
                    partnerName: partnerName,
                    isPaired: true
                )
                completion(.success(heartData))
            }
        }
    }
    
    func getHeartData(code: String, completion: @escaping (Result<HeartData, Error>) -> Void) {
        db.collection("hearts").document(code).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let name = data["name"] as? String,
                  let code = data["code"] as? String,
                  let creatorName = data["creatorName"] as? String,
                  let isPaired = data["isPaired"] as? Bool else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Heart not found"])))
                return
            }
            
            let partnerName = data["partnerName"] as? String ?? ""
            
            let heartData = HeartData(
                name: name,
                code: code,
                creatorName: creatorName,
                partnerName: partnerName,
                isPaired: isPaired
            )
            completion(.success(heartData))
        }
    }
    
    func listenToHeartUpdates(code: String, completion: @escaping (HeartData?) -> Void) -> ListenerRegistration {
        return db.collection("hearts").document(code).addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data(),
                  let name = data["name"] as? String,
                  let code = data["code"] as? String,
                  let creatorName = data["creatorName"] as? String,
                  let isPaired = data["isPaired"] as? Bool else {
                completion(nil)
                return
            }
            
            let partnerName = data["partnerName"] as? String ?? ""
            
            let heartData = HeartData(
                name: name,
                code: code,
                creatorName: creatorName,
                partnerName: partnerName,
                isPaired: isPaired
            )
            completion(heartData)
        }
    }
    
    func sendNote(heartCode: String, content: String, type: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let noteData: [String: Any] = [
            "heartCode": heartCode,
            "senderId": userId,
            "content": content,
            "type": type,
            "createdAt": Timestamp(),
            "read": false
        ]
        
        db.collection("notes").addDocument(data: noteData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func listenToNotes(heartCode: String, completion: @escaping ([NoteData]) -> Void) -> ListenerRegistration {
        return db.collection("notes")
            .whereField("heartCode", isEqualTo: heartCode)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let notes = documents.compactMap { doc -> NoteData? in
                    let data = doc.data()
                    guard let senderId = data["senderId"] as? String,
                          let content = data["content"] as? String,
                          let type = data["type"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp else {
                        return nil
                    }
                    
                    return NoteData(
                        id: doc.documentID,
                        senderId: senderId,
                        content: content,
                        type: type,
                        createdAt: timestamp.dateValue(),
                        read: data["read"] as? Bool ?? false
                    )
                }
                
                completion(notes)
            }
    }
    
    private func generateCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}

struct HeartData {
    let name: String
    let code: String
    let creatorName: String
    let partnerName: String
    let isPaired: Bool
}

struct NoteData: Identifiable {
    let id: String
    let senderId: String
    let content: String
    let type: String
    let createdAt: Date
    let read: Bool
}
