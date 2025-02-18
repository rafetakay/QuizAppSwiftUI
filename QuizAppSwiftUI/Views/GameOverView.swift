//
//  GameOverView.swift
//  QuizAppSwiftUI
//
//  Created by Rafet Can AKAY on 11.02.2025.
//

import Foundation
import SwiftUI

struct GameOverView: View {
    let score: Int
    let totalQuestions: Int
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Your score: \(score)/\(totalQuestions)")
                .font(.title2)
                .foregroundColor(.black)
            
            Button(action: onRestart) {
                Text("Play Again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(12)
                    .foregroundColor(.black)
            }
        }
    }
}
