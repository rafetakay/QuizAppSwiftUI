//
//  QuizView.swift
//  QuizAppSwiftUI
//
//  Created by Rafet Can AKAY on 11.02.2025.

import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()

    var mainbackgroundColor: Color {
        if viewModel.isGameOver {
            return mainbgColorForGameOver
        }
        return mainbgColorForQuiz
    }

    var subviewbackgroundColor: Color {
        if viewModel.isGameOver {
            return subviewbgColorForGameOver
        }
        return subviewbgColorForQuiz
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    if viewModel.isGameOver {
                        GameOverView(
                            score: viewModel.score,
                            totalQuestions: viewModel.questions.count,
                            onRestart: viewModel.resetQuiz
                        )
                    }else if viewModel.isLoading {
                        ProgressView("Loading questions...")
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                            Button("Try Again") {
                                viewModel.resetQuiz()
                            }
                            .buttonStyle(.bordered)
                        }
                    } else if viewModel.selectedCategory == nil &&
                                viewModel.selectedLevel == nil && viewModel.randomQuestionsReceived == false{
                        QuizSetupView(viewModel: viewModel)  // Show selection screen at start or game over
                    }else if viewModel.questions.isEmpty {
                        Text("No questions available")
                    } else {
                        QuestionView(
                            question: viewModel.currentQuestion,
                            questionNumber: viewModel.currentQuestionIndex + 1,
                            totalQuestions: viewModel.questions.count,
                            onAnswerSelected: viewModel.answerSelected,
                            onTimeUp: viewModel.timeUp
                        )
                    }
                }
                .padding()
                .background(subviewbackgroundColor) // Background color for inner content
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .navigationTitle("Question Generator App")
                .navigationBarTitleDisplayMode(.inline)
                Spacer()
            }
            .background(mainbackgroundColor)
            .edgesIgnoringSafeArea(.all)
        }
    }
}
