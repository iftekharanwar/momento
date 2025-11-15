//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

class LoveQuestionsViewModel: ObservableObject {
    @Published var answers: [QuestionAnswer] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    
    func startListening(heartCode: String) {
        listener?.remove()
        
        listener = db.collection("questionAnswers")
            .whereField("heartCode", isEqualTo: heartCode)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.answers = documents.compactMap { doc -> QuestionAnswer? in
                    let data = doc.data()
                    guard let heartCode = data["heartCode"] as? String,
                          let questionId = data["questionId"] as? String,
                          let question = data["question"] as? String,
                          let userId = data["userId"] as? String,
                          let userName = data["userName"] as? String,
                          let answer = data["answer"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp else {
                        return nil
                    }
                    
                    return QuestionAnswer(
                        id: doc.documentID,
                        heartCode: heartCode,
                        questionId: questionId,
                        question: question,
                        userId: userId,
                        userName: userName,
                        answer: answer,
                        createdAt: timestamp.dateValue()
                    )
                }
            }
    }
    
    func submitAnswer(heartCode: String, questionId: String, question: String, answer: String, userName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Not authenticated"
            completion(false)
            return
        }
        
        isLoading = true
        
        let answerData: [String: Any] = [
            "heartCode": heartCode,
            "questionId": questionId,
            "question": question,
            "userId": userId,
            "userName": userName,
            "answer": answer,
            "createdAt": Timestamp()
        ]
        
        db.collection("questionAnswers").addDocument(data: answerData) { [weak self] error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func getAnswersForQuestion(questionId: String) -> [QuestionAnswer] {
        return answers.filter { $0.questionId == questionId }
    }
    
    func hasUserAnswered(questionId: String, userId: String) -> Bool {
        return answers.contains { $0.questionId == questionId && $0.userId == userId }
    }
}
