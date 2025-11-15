//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine
import WidgetKit

class MusicViewModel: ObservableObject {
    @Published var tracks: [MusicTrack] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    
    func startListening(heartCode: String) {
        listener?.remove()
        
        listener = db.collection("musicTracks")
            .whereField("heartCode", isEqualTo: heartCode)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.tracks = documents.compactMap { doc -> MusicTrack? in
                    let data = doc.data()
                    guard let heartCode = data["heartCode"] as? String,
                          let userId = data["userId"] as? String,
                          let userName = data["userName"] as? String,
                          let trackName = data["trackName"] as? String,
                          let artistName = data["artistName"] as? String,
                          let message = data["message"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp else {
                        return nil
                    }
                    
                    return MusicTrack(
                        id: doc.documentID,
                        heartCode: heartCode,
                        userId: userId,
                        userName: userName,
                        trackName: trackName,
                        artistName: artistName,
                        message: message,
                        createdAt: timestamp.dateValue()
                    )
                }
                
                self.updateWidget()
            }
    }
    
    func shareTrack(heartCode: String, trackName: String, artistName: String, message: String, userName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Not authenticated"
            completion(false)
            return
        }
        
        isLoading = true
        
        let trackData: [String: Any] = [
            "heartCode": heartCode,
            "userId": userId,
            "userName": userName,
            "trackName": trackName,
            "artistName": artistName,
            "message": message,
            "createdAt": Timestamp()
        ]
        
        db.collection("musicTracks").addDocument(data: trackData) { [weak self] error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    private func updateWidget() {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        let partnerTracks = tracks.filter { $0.userId != currentUserId }
        
        if let latestTrack = partnerTracks.first {
            let widgetMusicData = WidgetMusicData(
                trackName: latestTrack.trackName,
                artistName: latestTrack.artistName,
                senderName: latestTrack.userName,
                message: latestTrack.message,
                date: latestTrack.createdAt
            )
            
            SharedDataManager.shared.updateLatestTrack(widgetMusicData)
        }
    }
}
