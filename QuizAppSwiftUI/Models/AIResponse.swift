//
//  AIResponse.swift
//  QuizAppSwiftUI
//
//  Created by Rafet Can AKAY on 11.02.2025.
//

import Foundation

struct AIResponse: Decodable {
    let choices: [AIChoice]
}

struct AIChoice: Decodable {
    let message: AIMessage
}

struct AIMessage: Decodable {
    let content: String
}

struct AIQuestion: Decodable {
    let question: String
    let answers: [String]
    let correctAnswerIndex: Int
}
