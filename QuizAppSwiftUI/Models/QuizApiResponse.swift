//
//  QuizApiResponse.swift
//  QuizAppSwiftUI
//
//  Created by Rafet Can AKAY on 11.02.2025.
//

import Foundation

struct QuizApiResponse: Codable {
    let responseCode : Int
    let results: [QuizQuestion]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct QuizQuestion: Codable {
    let category : String
    let type : String
    let difficulty : String
    let question : String
    let correctAnswer : String
    let incorrectAnswers : [String]
    
    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}
