//
//  Question.swift
//  QuizAppSwiftUI
//
//  Created by Rafet Can AKAY on 11.02.2025.
//

import Foundation

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let answers: [String]
    let correctAnswerIndex: Int
    var selectedAnswerIndex: Int?
       
    
    var correctAnswer: String{
        answers[correctAnswerIndex]
    }
}
