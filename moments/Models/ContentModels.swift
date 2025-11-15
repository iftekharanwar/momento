//
//  Created by Iftekhar Anwar on 13/11/25.
//

import Foundation

struct LoveLetter: Identifiable, Codable {
    var id: String = UUID().uuidString
    let heartCode: String
    let senderId: String
    let senderName: String
    let content: String
    let createdAt: Date
    var read: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, heartCode, senderId, senderName, content, createdAt, read
    }
}

struct LoveQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let category: String
    
    static let predefinedQuestions: [LoveQuestion] = [
        LoveQuestion(id: "1", question: "What's your favorite memory of us?", category: "Memories"),
        LoveQuestion(id: "2", question: "What made you fall in love with me?", category: "Love"),
        LoveQuestion(id: "3", question: "Where do you see us in 5 years?", category: "Future"),
        LoveQuestion(id: "4", question: "What's one thing I do that makes you smile?", category: "Happiness"),
        LoveQuestion(id: "5", question: "What's your dream date with me?", category: "Romance"),
        LoveQuestion(id: "6", question: "What's something new you'd like to try together?", category: "Adventure"),
        LoveQuestion(id: "7", question: "What song reminds you of us?", category: "Music"),
        LoveQuestion(id: "8", question: "What's your favorite thing about our relationship?", category: "Love"),
        LoveQuestion(id: "9", question: "How do you want me to show you love?", category: "Love Languages"),
        LoveQuestion(id: "10", question: "What's a small thing I do that means a lot to you?", category: "Appreciation")
    ]
}

struct QuestionAnswer: Identifiable, Codable {
    var id: String = UUID().uuidString
    let heartCode: String
    let questionId: String
    let question: String
    let userId: String
    let userName: String
    let answer: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, heartCode, questionId, question, userId, userName, answer, createdAt
    }
}

struct CheckIn: Identifiable, Codable {
    var id: String = UUID().uuidString
    let heartCode: String
    let userId: String
    let userName: String
    let mood: String
    let note: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, heartCode, userId, userName, mood, note, createdAt
    }
    
    static let moodOptions = ["😊", "😍", "😢", "😴", "😤", "🤗", "🥰", "😔"]
}

struct MusicTrack: Identifiable, Codable {
    var id: String = UUID().uuidString
    let heartCode: String
    let userId: String
    let userName: String
    let trackName: String
    let artistName: String
    let message: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, heartCode, userId, userName, trackName, artistName, message, createdAt
    }
}
