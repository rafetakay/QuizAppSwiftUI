//
//  QuestionView.swift
//  QuizAppSwiftUI
//
//  Created by Rafet Can AKAY on 11.02.2025.
//

import Foundation
import SwiftUI

struct QuestionView: View {
    let question: Question
    let questionNumber: Int
    let totalQuestions: Int
    let onAnswerSelected: (Int) -> Void
    
    let onTimeUp: () -> Void
    @State private var timeRemaining = 20
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            
            HStack {
                Text("⏳ \(timeRemaining) second")
                    .font(.headline)
                    .foregroundColor(timeRemaining > 5 ? timerTextColor : timerLastSecTextColor)
                Spacer()
            }
            .padding(.horizontal)
            
            ProgressView(value: Double(questionNumber), total: Double(totalQuestions))
                .tint(.yellow)
            
            Text("Question \(questionNumber) of \(totalQuestions)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(question.text)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                ForEach(question.answers.indices, id: \.self) { index in
                    AnswerButton(
                        answer: question.answers[index],
                        isSelected: question.selectedAnswerIndex == index,
                        isCorrect: index == question.correctAnswerIndex,
                        showResult: question.selectedAnswerIndex != nil,
                        action: {
                            stopTimer() // Stop timer when an answer is selected
                            onAnswerSelected(index)
                        }
                    )
                    .disabled(question.selectedAnswerIndex != nil)
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer() // Stop timer when view disappears
        }
        .onChange(of: questionNumber) {
            startTimer() // Restart timer when a new question appears
        }

    }
    
    private func startTimer() {
        stopTimer() // Stop any existing timer
        timeRemaining = 20

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                onTimeUp()
            }
        }
    }
    
    private func stopTimer() {
           timer?.invalidate()
           timer = nil
       }
}


struct AnswerButton: View {
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool
    let showResult: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        guard showResult else {
            return answerButtonDefaultBgColor
        }
        
        if isSelected {
            return isCorrect ? .green : .red
        }
        if isCorrect {
            return .green
        }
        return answerButtonDefaultBgColor
    }
    
    var body: some View {
        Button(action: action) {
            Text(answer)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(15)
        }
    }
}
