//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import FirebaseAuth

struct LoveQuestionsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pairingViewModel: PairingViewModel
    @StateObject private var viewModel = LoveQuestionsViewModel()
    @State private var selectedQuestion: LoveQuestion?
    @State private var showAnswerSheet = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Love Questions")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(LoveQuestion.predefinedQuestions) { question in
                            QuestionCard(
                                question: question,
                                answers: viewModel.getAnswersForQuestion(questionId: question.id),
                                hasUserAnswered: viewModel.hasUserAnswered(
                                    questionId: question.id,
                                    userId: Auth.auth().currentUser?.uid ?? ""
                                ),
                                onTap: {
                                    selectedQuestion = question
                                    showAnswerSheet = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .sheet(isPresented: $showAnswerSheet) {
            if let question = selectedQuestion {
                AnswerQuestionView(
                    question: question,
                    heartCode: pairingViewModel.heartCode,
                    userName: pairingViewModel.currentUserName,
                    viewModel: viewModel,
                    existingAnswers: viewModel.getAnswersForQuestion(questionId: question.id)
                )
            }
        }
        .onAppear {
            if !pairingViewModel.heartCode.isEmpty {
                viewModel.startListening(heartCode: pairingViewModel.heartCode)
            }
        }
    }
}


struct BackgroundView: View {

    var body: some View {

        LinearGradient(

            colors: [

                Color(red: 0.80, green: 0.93, blue: 1.0),

                Color(red: 0.93, green: 0.97, blue: 1.0)

            ],

            startPoint: .top,

            endPoint: .bottom

        )

        .ignoresSafeArea()

    }

}

struct QuestionCard: View {
    let question: LoveQuestion
    let answers: [QuestionAnswer]
    let hasUserAnswered: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(question.category)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "9B8DBA"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "F0ECFF"))
                        .cornerRadius(12)
                    
                    Spacer()
                    
                    if hasUserAnswered {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "FFB3C6"))
                    }
                }
                
                Text(question.question)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                if !answers.isEmpty {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12))
                        Text("\(answers.count) answer\(answers.count == 1 ? "" : "s")")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.black.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
    }
}

struct AnswerQuestionView: View {
    @Environment(\.dismiss) var dismiss
    let question: LoveQuestion
    let heartCode: String
    let userName: String
    @ObservedObject var viewModel: LoveQuestionsViewModel
    let existingAnswers: [QuestionAnswer]
    
    @State private var answerText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    var hasUserAnswered: Bool {
        existingAnswers.contains { $0.userId == currentUserId }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Question
                        VStack(spacing: 12) {
                            Text(question.category)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "9B8DBA"))
                            
                            Text(question.question)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        if !existingAnswers.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Answers")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.6))
                                
                                ForEach(existingAnswers) { answer in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(answer.userName)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color(hex: "FFB3C6"))
                                        
                                        Text(answer.answer)
                                            .font(.system(size: 16))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(16)
                                    .background(Color(hex: "F5F5F5"))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        if !hasUserAnswered {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Answer")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.6))
                                
                                ZStack(alignment: .topLeading) {
                                    if answerText.isEmpty {
                                        Text("Share your thoughts...")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 16)
                                    }
                                    
                                    TextEditor(text: $answerText)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 12)
                                        .focused($isTextFieldFocused)
                                }
                                .frame(height: 150)
                                .background(Color(hex: "F5F5F5"))
                                .cornerRadius(15)
                                
                                Button(action: submitAnswer) {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                    } else {
                                        Text("Submit Answer")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                    }
                                }
                                .background(
                                    answerText.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "9B8DBA")
                                )
                                .cornerRadius(15)
                                .disabled(answerText.isEmpty || viewModel.isLoading)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if !hasUserAnswered {
                    isTextFieldFocused = true
                }
            }
        }
    }
    
    private func submitAnswer() {
        viewModel.submitAnswer(
            heartCode: heartCode,
            questionId: question.id,
            question: question.question,
            answer: answerText,
            userName: userName
        ) { success in
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    LoveQuestionsView()
        .environmentObject(PairingViewModel())
}
