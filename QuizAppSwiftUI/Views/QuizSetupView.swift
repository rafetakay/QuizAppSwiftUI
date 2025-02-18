//
//  QuizSetupView.swift
//  QuizAppSwiftUI
//
//  Created by Rafet Can AKAY on 11.02.2025.
//

import Foundation
import SwiftUI
import Foundation
import SwiftUI

struct QuizSetupView: View {
    
    
    @ObservedObject var viewModel: QuizViewModel
    @State private var selectedCategory: String? = nil
    @State private var selectedLevel: String? = nil

    let categories = ["Select a category", "Mathematics", "Science", "History","Philosophy"]
    let levels = ["Select a difficulty", "Easy", "Medium", "Hard"]

    var body: some View {
        VStack {
            Text("Select Category")
                .font(.title2)
                .padding()
            
            Picker("Category", selection: Binding(
                get: { selectedCategory ?? "Select a category" },
                set: { newValue in
                    selectedCategory = newValue == "Select a category" ? nil : newValue
                }
            )) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category as String?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            Text("Select Difficulty")
                .font(.title2)
                .padding()

            Picker("Difficulty", selection: Binding(
                get: { selectedLevel ?? "Select a difficulty" },
                set: { newValue in
                    selectedLevel = newValue == "Select a difficulty" ? nil : newValue
                }
            )) {
                ForEach(levels, id: \.self) { level in
                    Text(level).tag(level as String?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            Button(action: {
                if let category = selectedCategory, let level = selectedLevel {
                    print("category \(category)")
                    print("level \(level)")
                    viewModel.selectedCategory = category
                    viewModel.selectedLevel = level
                    viewModel.fetchQuestions(random: false)
                } else {
                    viewModel.errorMessage = "Please select both a category and a difficulty level."
                }
            }) {
                Text("Start Quiz")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Text("Or")
                .font(.title2)
                .padding()

            
            // Random Quiz Button
            Button(action: {
                print("Starting a Random Quiz")
                viewModel.fetchQuestions(random: true)
            }) {
                Text("Random Quiz")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .allowsHitTesting(true)
    }
}
